open Terraform_ir
open Parser.Tf_types
open Parser.Network_types
open Parser.Azure_types

(* This module is the ground truth: it encodes Azure semantics directly, from
   the spec, and depends on nothing in engine/. The HSA engine is never consulted
   here — that would defeat the point of an independent oracle. Where the engine
   happens to solve the same sub-problem (service tags, ASG membership, peering),
   the answer is derived here from the documentation rather than shared, so that
   a wrong answer in one shows up as a crosscheck disagreement instead of
   agreement. *)

(* A NIC ip_configuration with a known address. Delivery to an address that a
   NIC holds also crosses that NIC's own NSG, which is evaluated in addition to
   the subnet's. *)
type host = {
  ip             : IPv4.t;
  subnet_address : string;
  nsg            : Nsg.t option;
}

(* A NIC a VirtualAppliance route can name as its next hop. [forwards] mirrors
   the NIC's ip_forwarding_enabled: Azure drops at a NIC that does not forward,
   so an appliance without it black-holes everything routed through it. [vnet]
   scopes the lookup — a next hop IP must be reachable without transiting a
   gateway, so a NIC in an unpeered VNet is not a candidate at all. *)
type appliance = {
  vnet           : string;
  subnet_address : string;
  forwards       : bool;
  nsg            : Nsg.t option;
}

(* One side of a peering, as seen from the local VNet. [access_allowed] mirrors
   allowVirtualNetworkAccess, which gates the traffic rather than the route:
   Azure installs the peering routes either way. *)
type peer = {
  remote_vnet    : string;
  remote_cidrs   : CIDR.t list;
  access_allowed : bool;
}

type node = {
  address    : string;
  vnet       : string;            (* owning VNet address — delivery scope, with peers *)
  tag_cidrs  : CIDR.t list;       (* the "VirtualNetwork" service tag for this subnet *)
  cidrs      : CIDR.t list;       (* every address prefix of the subnet *)
  nsg        : Nsg.t option;
  routes     : Route_table.Route.t list;
}

(* Routes name an appliance either by IP (StaticAppliance) or by NIC address
   (DynamicNic / ApplianceSet), so it is indexed both ways, once per graph.
   Both indexes hold lists: two VNets may legitimately use the same private
   address, and one NIC may have several ip_configurations. *)
type graph = {
  nodes            : (string, node) Hashtbl.t;
  hosts            : host list IPMap.t;
  appliance_by_nic : appliance list AddressMap.t;
  appliance_by_ip  : appliance list IPMap.t;
  peers            : peer list AddressMap.t;
  asg_cidrs        : CIDR.t list AddressMap.t;
}

(* --- address helpers --- *)

let cidr_exn s = Option.get (CIDR.of_string_opt s)

let mask_u64 cidr = Int64.logand (Int64.of_int32 (CIDR.get_mask cidr)) 0xFFFFFFFFL

let ip_in_any cidrs ip = List.exists (Packet.ip_in_cidr ip) cidrs

let host_cidr ip = CIDR.make ip (IPv4Mask.of_mask_length 32)

(* inner ⊆ outer: outer's prefix is no longer than inner's, and inner's base
   address falls inside outer. *)
let cidr_covers ~outer inner =
  Int64.compare (mask_u64 outer) (mask_u64 inner) <= 0
  && Packet.ip_in_cidr (fst (CIDR.get_interval inner)) outer

let default_prefix = cidr_exn "0.0.0.0/0"

let is_default_prefix cidr = CIDR.compare cidr default_prefix = 0

(* Azure reserves the first four addresses of every subnet (network, gateway,
   Azure DNS, future use) and the last (broadcast), so a /29 has three usable
   hosts. Nothing can be assigned there, which makes a packet aimed at one
   undeliverable rather than delivered to whatever owns the prefix. *)
let host_assignable ip cidr =
  let lo, hi = CIDR.get_interval cidr in
  let u = Packet.to_u64 ip and l = Packet.to_u64 lo and h = Packet.to_u64 hi in
  Int64.compare u (Int64.add l 3L) > 0 && Int64.compare u h < 0

(* --- peering --- *)

let peering_access peering =
  Option.value ~default:true (Vnet_peering.get_allow_virtual_network_access peering)

let peer_of_peering peering =
  match Vnet_peering.get_local_vnet peering, Vnet_peering.get_remote_vnet peering with
  | Resolved local, Resolved remote ->
    Some (Vnet.get_address local,
          { remote_vnet    = Vnet.get_address remote;
            remote_cidrs   = Vnet.get_addresses remote;
            access_allowed = peering_access peering })
  | _ -> None

let add_peer (local, peer) acc =
  let existing = Option.value ~default:[] (AddressMap.find_opt local acc) in
  AddressMap.add local (peer :: existing) acc

let index_peers (world : World.t) =
  AddressMap.fold
    (fun _ peering acc ->
      match peer_of_peering peering with
      | Some entry -> add_peer entry acc
      | None -> acc)
    world.vnet_peerings
    AddressMap.empty

let peers_of peers vnet = Option.value ~default:[] (AddressMap.find_opt vnet peers)

let reachable_peers peers vnet =
  peers_of peers vnet |> List.filter (fun p -> p.access_allowed)

(* --- effective routes, built independently (no Effective_route_table) --- *)

let system_route name prefix next_hop =
  Route_table.Route.make ~name ~address_prefix:prefix ~next_hop
    ~next_hop_in_ip_address:Unresolved ~source:System

(* Every prefix Azure gives a None next hop by default. The four RFC 1918 /
   RFC 6598 ranges are the documented ones; the remaining four appear in the
   default system route table alongside them. *)
let reserved_drop_routes =
  List.map
    (fun (name, prefix) -> system_route name (cidr_exn prefix) Drop)
    [ "PrivateA",        "10.0.0.0/8";
      "PrivateB",        "172.16.0.0/12";
      "PrivateC",        "192.168.0.0/16";
      "CarrierGradeNat", "100.64.0.0/10";
      "Reserved157",     "157.59.0.0/16";
      "Loopback",        "127.0.0.0/8";
      "Reserved104a",    "104.147.0.0/16";
      "Reserved104b",    "104.146.0.0/17" ]

(* A reserved drop route disappears when the VNet's address space covers it:
   "If you assign an address range ... that includes, but isn't the same as,
   one of the four reserved address prefixes, Azure removes the route for the
   prefix." For the equal case the docs instead flip the next hop from None to
   Virtual network — which the VnetLocal route at the same prefix already
   provides, so one containment filter implements both clauses. *)
let covered_by_vnet vnet_cidrs route =
  List.exists
    (fun v -> cidr_covers ~outer:v (Route_table.Route.get_prefix route))
    vnet_cidrs

(* A UDR for 0.0.0.0/0 also deletes them: "Azure removed the routes for the
   10.0.0.0/8, 192.168.0.0/16, and 100.64.0.0/10 address prefixes from the
   Subnet1 route table when the UDR for the 0.0.0.0/0 address prefix was added
   to Subnet1." Without this the drop routes are longer prefixes than the UDR
   and win LPM, so forced tunnelling to an appliance silently black-holes every
   private destination outside the VNet. *)
let surviving_reserved_routes ~vnet_cidrs ~default_overridden =
  if default_overridden then []
  else List.filter (fun r -> not (covered_by_vnet vnet_cidrs r)) reserved_drop_routes

let vnet_local_routes vnet_cidrs =
  List.map (fun c -> system_route "VnetLocal" c VirtualNetwork) vnet_cidrs

(* Peering adds "a route for each address range within the address space of
   each virtual network involved in the peering". The next hop is Virtual
   network peering, which delivers into the remote VNet exactly as VnetLocal
   delivers within this one, so it is modelled as VirtualNetwork and the
   delivery scope carries the peer. *)
let peering_routes peers =
  List.concat_map
    (fun p -> List.map (fun c -> system_route "VnetPeering" c VirtualNetwork) p.remote_cidrs)
    peers

let default_routes ~vnet_cidrs ~peers ~default_overridden =
  vnet_local_routes vnet_cidrs
  @ peering_routes peers
  @ system_route "Internet" default_prefix Internet
    :: surviving_reserved_routes ~vnet_cidrs ~default_overridden

let same_prefix a b =
  CIDR.compare (Route_table.Route.get_prefix a) (Route_table.Route.get_prefix b) = 0

let overrides_default udrs =
  List.exists (fun r -> is_default_prefix (Route_table.Route.get_prefix r)) udrs

let effective_routes ~vnet_cidrs ~peers rt_opt =
  let udrs = match rt_opt with Some rt -> Route_table.get_routes rt | None -> [] in
  let default_overridden = overrides_default udrs in
  let system =
    default_routes ~vnet_cidrs ~peers ~default_overridden
    |> List.filter (fun s -> not (List.exists (same_prefix s) udrs))
  in
  udrs @ system

(* --- graph construction --- *)

let nic_nsg (world : World.t) nic =
  AddressMap.find_opt (Nic.get_address nic) world.assocs.nic_nsg

let host_of_ipconfig world nic ipconfig =
  match Nic.IpConfiguration.get_private_ip ipconfig,
        Nic.IpConfiguration.get_subnet ipconfig with
  | Some ip, Some subnet ->
    Some { ip; subnet_address = Subnet.get_address subnet; nsg = nic_nsg world nic }
  | _ -> None

let add_host host acc =
  let existing = Option.value ~default:[] (IPMap.find_opt host.ip acc) in
  IPMap.add host.ip (host :: existing) acc

let index_hosts (world : World.t) =
  AddressMap.fold
    (fun _ nic acc ->
      Nic.get_ipconfigs nic
      |> List.filter_map (host_of_ipconfig world nic)
      |> List.fold_left (fun a h -> add_host h a) acc)
    world.nics
    IPMap.empty

let appliance_of_ipconfig world nic ipconfig =
  match Nic.IpConfiguration.get_subnet ipconfig with
  | None -> None
  | Some subnet ->
    Some { vnet           = Vnet.get_address (Subnet.get_vnet subnet);
           subnet_address = Subnet.get_address subnet;
           forwards       = Nic.get_ip_forwarding_enabled nic;
           nsg            = nic_nsg world nic }

let appliances_of_nic world nic =
  List.filter_map (appliance_of_ipconfig world nic) (Nic.get_ipconfigs nic)

let index_appliance_by_nic (world : World.t) =
  AddressMap.fold
    (fun addr nic acc ->
      match appliances_of_nic world nic with
      | [] -> acc
      | appliances -> AddressMap.add addr appliances acc)
    world.nics
    AddressMap.empty

(* Only statically-allocated NICs land here: a dynamic NIC has no address until
   Azure assigns one, which is why the parser resolves those to a NIC address
   instead of an IP. *)
let add_appliance_by_ip world nic acc ipconfig =
  match Nic.IpConfiguration.get_private_ip ipconfig,
        appliance_of_ipconfig world nic ipconfig with
  | Some ip, Some appliance ->
    let existing = Option.value ~default:[] (IPMap.find_opt ip acc) in
    IPMap.add ip (appliance :: existing) acc
  | _ -> acc

let index_appliance_by_ip (world : World.t) =
  AddressMap.fold
    (fun _ nic acc ->
      List.fold_left (add_appliance_by_ip world nic) acc (Nic.get_ipconfigs nic))
    world.nics
    IPMap.empty

(* ASG membership is resolved from the members' own addresses. A dynamically
   addressed member has no address in the plan, so it contributes nothing —
   under-approximating rather than standing in the whole subnet for it, which
   would make an ASG rule match every address in the subnet and erase the
   distinction the ASG exists to draw. *)
let asg_member_cidrs nic =
  Nic.get_ipconfigs nic
  |> List.filter_map Nic.IpConfiguration.get_private_ip
  |> List.map host_cidr

let index_asgs (world : World.t) =
  AddressMap.map
    (fun nics -> List.concat_map asg_member_cidrs nics)
    world.assocs.asg_to_nics

(* The host VIP: source of DHCP, Azure DNS and load balancer health probes, and
   a member of both the VirtualNetwork and AzureLoadBalancer tags. *)
let azure_host_vip = cidr_exn "168.63.129.16/32"

let route_table_prefixes rt_opt =
  match rt_opt with
  | None -> []
  | Some rt ->
    Route_table.get_routes rt
    |> List.map Route_table.Route.get_prefix
    (* The tag covers "address prefixes used on user-defined routes". A default
       route is excluded: reading that clause literally would put the whole
       address space in the tag and let AllowVNetInBound admit the internet at
       priority 65000, which is the one direction an oracle must not guess in. *)
    |> List.filter (fun c -> not (is_default_prefix c))

(* "The virtual network address space (all IP address ranges defined for the
   virtual network), all connected on-premises address spaces, peered virtual
   networks, virtual networks connected to a virtual network gateway, the
   virtual IP address of the host, and address prefixes used on user-defined
   routes." On-premises and gateway-connected space is not in the plan. *)
let virtual_network_tag ~vnet_cidrs ~peers ~rt_opt =
  vnet_cidrs
  @ List.concat_map (fun p -> p.remote_cidrs) peers
  @ route_table_prefixes rt_opt
  @ [ azure_host_vip ]

let build_node (world : World.t) peers addr subnet =
  let vnet_t = Subnet.get_vnet subnet in
  let vnet_cidrs = Vnet.get_addresses vnet_t in
  let vnet_peers = peers_of peers (Vnet.get_address vnet_t) in
  let rt_opt = AddressMap.find_opt addr world.assocs.subnet_rt in
  { address   = addr;
    vnet      = Vnet.get_address vnet_t;
    tag_cidrs = virtual_network_tag ~vnet_cidrs ~peers:vnet_peers ~rt_opt;
    cidrs     = Subnet.get_cidrs subnet;
    nsg       = AddressMap.find_opt addr world.assocs.subnet_nsg;
    routes    = effective_routes ~vnet_cidrs ~peers:vnet_peers rt_opt }

let build_nodes (world : World.t) peers =
  let nodes = Hashtbl.create (AddressMap.cardinal world.subnets) in
  AddressMap.iter
    (fun addr subnet -> Hashtbl.replace nodes addr (build_node world peers addr subnet))
    world.subnets;
  nodes

let build_graph (world : World.t) : graph =
  let peers = index_peers world in
  { nodes            = build_nodes world peers;
    hosts            = index_hosts world;
    appliance_by_nic = index_appliance_by_nic world;
    appliance_by_ip  = index_appliance_by_ip world;
    peers;
    asg_cidrs        = index_asgs world }

(* --- ownership and delivery scope --- *)

let node_owns_ip node ip =
  List.exists (fun c -> Packet.ip_in_cidr ip c && host_assignable ip c) node.cidrs

(* A VnetLocal or peering route delivers to the subnet holding the address, in
   this VNet or in one peered to it with virtual network access allowed.
   Peering is not transitive, so the peers of a peer are not in scope. *)
let delivery_vnets g ~vnet =
  vnet :: List.map (fun p -> p.remote_vnet) (reachable_peers g.peers vnet)

let node_owning g ~vnets ip =
  Hashtbl.fold
    (fun _ (n : node) acc ->
      match acc with
      | Some _ -> acc
      | None -> if List.mem n.vnet vnets && node_owns_ip n ip then Some n else None)
    g.nodes
    None

(* Packets carry raw [int32] addresses; the NIC indexes are keyed by the
   abstract [IPv4.t]. *)
let host_in_node g node ip =
  IPMap.find_opt (IPv4.of_int32 ip) g.hosts
  |> Option.value ~default:[]
  |> List.find_opt (fun (h : host) -> h.subnet_address = node.address)

let nic_nsg_at g node ip = Option.bind (host_in_node g node ip) (fun (h : host) -> h.nsg)

(* --- NSG rule scan with Azure default rules --- *)

(* Everything a rule needs beyond the packet: the VirtualNetwork tag for the
   subnet whose NSG is being scanned, and ASG membership. *)
type rule_ctx = {
  tag_cidrs : CIDR.t list;
  asg_cidrs : CIDR.t list AddressMap.t;
}

let ctx_of (g : graph) (node : node) =
  { tag_cidrs = node.tag_cidrs; asg_cidrs = g.asg_cidrs }

(* Neither RFC 1918 nor the other non-routable ranges are "reachable by the
   public internet", and the tag is scoped to space "outside the virtual
   network", so the local VirtualNetwork set is excluded too. Storage-family
   tags need Azure's published prefix list and stay unresolved. *)
let non_internet_cidrs =
  List.map cidr_exn
    [ "10.0.0.0/8"; "172.16.0.0/12"; "192.168.0.0/16"; "100.64.0.0/10";
      "127.0.0.0/8"; "169.254.0.0/16"; "224.0.0.0/4" ]

let service_tag_allows_ip ctx tag ip =
  match tag with
  | "VirtualNetwork"    -> ip_in_any ctx.tag_cidrs ip
  | "Internet"          -> not (ip_in_any non_internet_cidrs ip)
                           && not (ip_in_any ctx.tag_cidrs ip)
  | "AzureLoadBalancer" -> Packet.ip_in_cidr ip azure_host_vip
  | _                   -> false

let asg_allows_ip ctx groups ip =
  List.exists
    (fun g -> ip_in_any (Option.value ~default:[] (AddressMap.find_opt g ctx.asg_cidrs)) ip)
    groups

let endpoint_allows_ip ctx (e : Nsg.SecurityRule.endpoint) ip =
  match e with
  | Any                      -> true
  | Addresses cidrs          -> ip_in_any cidrs ip
  | ServiceTags tags         -> List.exists (fun t -> service_tag_allows_ip ctx t ip) tags
  | ApplicationGroups groups -> asg_allows_ip ctx groups ip

let port_in p (r : port) =
  match r with
  | Single n     -> p = n
  | Range (a, b) -> a <= p && p <= b
  | Any          -> true

(* An empty list is a rule the parser could not give ports to. Matching nothing
   keeps an unreadable rule from silently opening a path. *)
let ports_allow p ports = List.exists (port_in p) ports

let protocol_allows (rp : protocol) pp =
  match rp with Any -> true | x -> x = pp

let rule_matches ctx (pkt : Packet.t) rule =
  let open Nsg.SecurityRule in
  protocol_allows (get_protocol rule) pkt.protocol
  && endpoint_allows_ip ctx (get_src_ip rule) pkt.src_ip
  && endpoint_allows_ip ctx (get_dest_ip rule) pkt.dest_ip
  && ports_allow pkt.src_port (get_src_ports rule)
  && ports_allow pkt.dest_port (get_dest_ports rule)

(* Azure's built-in default rules (lowest priority), modelled natively because
   they reference the VirtualNetwork / AzureLoadBalancer / Internet service tags
   rather than CIDRs. Connection-initiating traffic only: NSGs are stateful, and
   return traffic is out of scope. *)
let default_allows ctx (dir : Nsg.SecurityRule.direction) (pkt : Packet.t) =
  let src_vnet = ip_in_any ctx.tag_cidrs pkt.src_ip in
  let dst_vnet = ip_in_any ctx.tag_cidrs pkt.dest_ip in
  match dir with
  | Inbound ->
    (src_vnet && dst_vnet)                                    (* AllowVnetInBound *)
    || Packet.ip_in_cidr pkt.src_ip azure_host_vip            (* AllowAzureLoadBalancerInBound *)
  | Outbound ->
    (src_vnet && dst_vnet)                                    (* AllowVnetOutBound *)
    || service_tag_allows_ip ctx "Internet" pkt.dest_ip       (* AllowInternetOutBound *)

(* First user rule (by priority) for this direction decides; if none match, fall
   through to the default rules. *)
let nsg_verdict ctx nsg (dir : Nsg.SecurityRule.direction) pkt =
  Nsg.get_rules nsg
  |> List.filter (fun r -> Nsg.SecurityRule.get_direction r = dir)
  |> List.sort Nsg.SecurityRule.compare
  |> List.find_opt (rule_matches ctx pkt)
  |> function
     | Some r -> Nsg.SecurityRule.get_access r = Nsg.SecurityRule.Allow
     | None -> default_allows ctx dir pkt

(* A subnet NSG and a NIC NSG can both be attached. Azure evaluates them in
   sequence — subnet then NIC inbound, NIC then subnet outbound — and both must
   permit, so the verdict is their conjunction. An absent NSG does not filter. *)
let nsgs_permit ctx nsgs dir pkt =
  List.for_all (fun nsg -> nsg_verdict ctx nsg dir pkt) (List.filter_map Fun.id nsgs)

(* --- longest-prefix match --- *)

let longer_prefix a b =
  Int64.compare (mask_u64 (Route_table.Route.get_prefix a))
                (mask_u64 (Route_table.Route.get_prefix b)) > 0

let route_matches ip route = Packet.ip_in_cidr ip (Route_table.Route.get_prefix route)

let keep_longer best route =
  match best with
  | None -> Some route
  | Some b -> if longer_prefix route b then Some route else best

(* Routes are ordered UDRs first, so a UDR wins a tie on prefix length — which
   is the documented precedence for identical prefixes. *)
let longest_prefix routes ip =
  routes |> List.filter (route_matches ip) |> List.fold_left keep_longer None

(* --- deterministic forwarding decision --- *)

let out_nsg = Nsg.SecurityRule.Outbound
let in_nsg  = Nsg.SecurityRule.Inbound

(* The parser resolves a route's next-hop IP from the route table's config
   references, which are per-table rather than per-route: a table naming several
   appliance NICs gives every route in it the whole set. A set is therefore a
   candidate list the parser could not narrow, not an Azure concept, so any
   candidate that forwards the packet counts. *)
let candidate_appliances g ref =
  match ref with
  | Unresolved | Resolved Unresolvable -> []
  | Resolved (StaticAppliance ip) -> Option.value ~default:[] (IPMap.find_opt ip g.appliance_by_ip)
  | Resolved (DynamicNic address) ->
    Option.value ~default:[] (AddressMap.find_opt address g.appliance_by_nic)
  | Resolved (ApplianceSet set) ->
    List.concat_map
      (fun a -> Option.value ~default:[] (AddressMap.find_opt a g.appliance_by_nic))
      set

(* "A next hop private IP address must have direct connectivity without having
   to route through an Azure ExpressRoute gateway or through Azure Virtual WAN."
   A NIC in an unpeered VNet is not directly connected, so naming its address
   is an invalid UDR and the traffic is black-holed rather than delivered. *)
let appliance_reachable g ~vnet (appliance : appliance) =
  appliance.vnet = vnet
  || List.exists (fun p -> p.remote_vnet = appliance.vnet) (reachable_peers g.peers vnet)

let appliances_for g ~vnet ref =
  List.filter (appliance_reachable g ~vnet) (candidate_appliances g ref)

let already_visited visited (node : node) = List.mem node.address visited

let deliver_to_owner g ~vnet pkt =
  match node_owning g ~vnets:(delivery_vnets g ~vnet) pkt.Packet.dest_ip with
  | None -> false
  | Some target ->
    nsgs_permit (ctx_of g target)
      [ target.nsg; nic_nsg_at g target pkt.Packet.dest_ip ] in_nsg pkt

(* Azure has no L2 segment inside a subnet: every packet, including same-subnet
   traffic, is matched against the effective routes by LPM. (See the
   "Within-Subnet1" UDR in the docs' routing example — without it, a VNet-wide
   UDR to an appliance captures intra-subnet traffic, and "Azure doesn't create
   default routes for subnet address ranges".) So there is no
   deliver-before-routing shortcut: the egress NSGs are scanned, LPM picks one
   route, and only a VirtualNetwork next hop delivers.

   [via] is the NIC the packet is leaving through when it was handed here by an
   appliance; at the originating subnet the sender's NIC is found from src_ip
   instead.

   A VirtualAppliance next hop hands the packet to the appliance's NIC and
   re-routes from the subnet that hosts it, so forwarding is a walk. The packet
   is not rewritten along the way: a NAT-ing appliance would change the header,
   and modelling that would need appliance-internal semantics Azure itself does
   not define. Revisiting a node ends the walk — the same node makes the same
   LPM decision for the same destination, so a repeat is a routing loop, not
   progress. *)
let rec route_from g ~visited ~via node pkt =
  if already_visited visited node then false
  else
    let sender_nsg = match via with Some _ -> via | None -> nic_nsg_at g node pkt.Packet.src_ip in
    nsgs_permit (ctx_of g node) [ node.nsg; sender_nsg ] out_nsg pkt
    && (match longest_prefix node.routes pkt.Packet.dest_ip with
        | Some route -> follow_hop g ~visited:(node.address :: visited) ~from:node route pkt
        | None -> false)

and follow_hop g ~visited ~from route pkt =
  match Route_table.Route.get_next_hop route with
  | VirtualNetwork -> deliver_to_owner g ~vnet:from.vnet pkt
  | VirtualAppliance ->
    appliances_for g ~vnet:from.vnet (Route_table.Route.get_next_hop_ip route)
    |> List.exists (fun a -> hop_through_appliance g ~visited a pkt)
  (* Internet / VirtualGateway leave the modelled scope; Drop is a drop. *)
  | Internet | VirtualGateway | Drop -> false

and hop_through_appliance g ~visited (appliance : appliance) pkt =
  match Hashtbl.find_opt g.nodes appliance.subnet_address with
  | None -> false
  | Some node ->
    nsgs_permit (ctx_of g node) [ node.nsg; appliance.nsg ] in_nsg pkt
    && appliance.forwards
    && route_from g ~visited ~via:appliance.nsg node pkt

let reachable_in g ~src pkt =
  match Hashtbl.find_opt g.nodes src with
  | None -> false
  | Some cur -> route_from g ~visited:[] ~via:None cur pkt

let reachable world ~src pkt = reachable_in (build_graph world) ~src pkt
