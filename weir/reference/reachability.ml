open Terraform_ir
open Parser.Tf_types
open Parser.Network_types
open Parser.Azure_types

(* This module is the ground truth: it encodes Azure semantics directly, from
   the spec, and depends on nothing in engine/. The HSA engine is never consulted
   here — that would defeat the point of an independent oracle. *)

type node = {
  address   : string;
  vnet      : string;            (* owning VNet address — delivery is intra-VNet only *)
  vnet_cidrs : CIDR.t list;      (* the VNet's address space (the "VirtualNetwork" tag) *)
  cidr      : CIDR.t option;
  nsg       : Nsg.t option;
  routes    : Route_table.Route.t list;
}

(* A NIC a VirtualAppliance route can name as its next hop. [forwards] mirrors
   the NIC's ip_forwarding_enabled: Azure drops at a NIC that does not forward,
   so an appliance without it black-holes everything routed through it. *)
type appliance = {
  subnet_address : string;
  forwards       : bool;
}

(* Routes name an appliance either by IP (StaticAppliance) or by NIC address
   (DynamicNic / ApplianceSet), so it is indexed both ways, once per graph. *)
type graph = {
  nodes            : (string, node) Hashtbl.t;
  appliance_by_nic : appliance AddressMap.t;
  appliance_by_ip  : appliance IPMap.t;
}

(* --- effective routes, built independently (no Effective_route_table) --- *)

let cidr_exn s = Option.get (CIDR.of_string_opt s)

let system_route name prefix next_hop =
  Route_table.Route.make ~name ~address_prefix:prefix ~next_hop
    ~next_hop_in_ip_address:Unresolved ~source:System

let mask_u64 cidr = Int64.logand (Int64.of_int32 (CIDR.get_mask cidr)) 0xFFFFFFFFL

(* inner ⊆ outer: outer's prefix is no longer than inner's, and inner's base
   address falls inside outer. *)
let cidr_covers ~outer inner =
  Int64.compare (mask_u64 outer) (mask_u64 inner) <= 0
  && Packet.ip_in_cidr (fst (CIDR.get_interval inner)) outer

(* Azure's implicit routes: the VNet address space delivers locally
   (VirtualNetwork), the default route goes to the Internet, and the reserved
   private ranges you don't own are dropped. A UDR with the same prefix as a
   system route overrides it; otherwise longest-prefix match decides.

   A reserved drop route disappears when the VNet's address space covers it:
   "If you assign an address range ... that includes, but isn't the same as,
   one of the four reserved address prefixes, Azure removes the route for the
   prefix." For the equal case the docs instead flip the next hop from None to
   Virtual network — which the VnetLocal route at the same prefix already
   provides, so one containment filter implements both clauses. *)
let default_routes vnet_cidrs =
  let covered route =
    List.exists
      (fun v -> cidr_covers ~outer:v (Route_table.Route.get_prefix route))
      vnet_cidrs
  in
  let reserved_drops =
    [ system_route "PrivateA"           (cidr_exn "10.0.0.0/8")    Drop;
      system_route "PrivateB"           (cidr_exn "172.16.0.0/12") Drop;
      system_route "PrivateC"           (cidr_exn "192.168.0.0/16") Drop;
      system_route "CarrierGradeNat"    (cidr_exn "100.64.0.0/10") Drop ]
    |> List.filter (fun r -> not (covered r))
  in
  List.map (fun c -> system_route "VnetLocal" c VirtualNetwork) vnet_cidrs
  @ system_route "Internet" (cidr_exn "0.0.0.0/0") Internet :: reserved_drops

let same_prefix a b =
  CIDR.compare (Route_table.Route.get_prefix a) (Route_table.Route.get_prefix b) = 0

let effective_routes vnet_cidrs rt_opt =
  let udrs = match rt_opt with Some rt -> Route_table.get_routes rt | None -> [] in
  let system = List.filter (fun s -> not (List.exists (same_prefix s) udrs)) (default_routes vnet_cidrs) in
  udrs @ system

let appliance_of_ipconfig nic ipconfig =
  match Nic.IpConfiguration.get_subnet ipconfig with
  | None -> None
  | Some subnet ->
    Some { subnet_address = Subnet.get_address subnet;
           forwards = Nic.get_ip_forwarding_enabled nic }

let index_appliance_by_nic nics =
  AddressMap.fold
    (fun addr nic acc ->
      match List.filter_map (appliance_of_ipconfig nic) (Nic.get_ipconfigs nic) with
      | a :: _ -> AddressMap.add addr a acc
      | [] -> acc)
    nics
    AddressMap.empty

(* Only statically-allocated NICs land here: a dynamic NIC has no address until
   Azure assigns one, which is why the parser resolves those to a NIC address
   instead of an IP. *)
let index_appliance_by_ip nics =
  let add_ipconfig nic acc ipconfig =
    match Nic.IpConfiguration.get_private_ip ipconfig, appliance_of_ipconfig nic ipconfig with
    | Some ip, Some a -> IPMap.add ip a acc
    | _ -> acc
  in
  AddressMap.fold
    (fun _ nic acc -> List.fold_left (add_ipconfig nic) acc (Nic.get_ipconfigs nic))
    nics
    IPMap.empty

let build_nodes (world : World.t) =
  let nodes = Hashtbl.create (AddressMap.cardinal world.subnets) in
  AddressMap.iter
    (fun addr subnet ->
      let vnet_t = Subnet.get_vnet subnet in
      let cidr = match Subnet.get_cidrs subnet with c :: _ -> Some c | [] -> None in
      let nsg = AddressMap.find_opt addr world.assocs.subnet_nsg in
      let routes = effective_routes (Vnet.get_addresses vnet_t)
                     (AddressMap.find_opt addr world.assocs.subnet_rt) in
      Hashtbl.replace nodes addr
        { address = addr; vnet = Vnet.get_address vnet_t;
          vnet_cidrs = Vnet.get_addresses vnet_t; cidr; nsg; routes })
    world.subnets;
  nodes

let build_graph (world : World.t) : graph =
  { nodes            = build_nodes world;
    appliance_by_nic = index_appliance_by_nic world.nics;
    appliance_by_ip  = index_appliance_by_ip world.nics }

let node_in_vnet_owning nodes ~vnet ip =
  Hashtbl.fold
    (fun _ (n : node) acc ->
      match acc, n.cidr with
      | Some _, _ -> acc
      | None, Some c when n.vnet = vnet && Packet.ip_in_cidr ip c -> Some n
      | None, _ -> None)
    nodes
    None

(* --- NSG rule scan with Azure default rules --- *)

let ip_in_any cidrs ip = List.exists (Packet.ip_in_cidr ip) cidrs

(* Service tags whose address set is a fixed constant, so they resolve without
   any deployment context. Internet is everything outside the reserved private
   ranges (the same four the system routes drop, unfiltered by VNet coverage:
   the tag is a fixed set, not a routing decision); AzureLoadBalancer is the
   host VIP where Azure health probes originate. VirtualNetwork is
   deployment-relative and Storage-family needs Azure's published list, so
   neither is resolved here. *)
let internet_excluded_cidrs =
  [ cidr_exn "10.0.0.0/8";     cidr_exn "172.16.0.0/12";
    cidr_exn "192.168.0.0/16"; cidr_exn "100.64.0.0/10" ]

let azure_lb_cidr = cidr_exn "168.63.129.16/32"

let service_tag_allows_ip tag ip =
  match tag with
  | "Internet"          -> not (ip_in_any internet_excluded_cidrs ip)
  | "AzureLoadBalancer" -> Packet.ip_in_cidr ip azure_lb_cidr
  | _                   -> false   (* VirtualNetwork / Storage-family unresolved *)

let endpoint_allows_ip (e : Nsg.SecurityRule.endpoint) ip =
  match e with
  | Any                 -> true
  | Addresses cidrs     -> ip_in_any cidrs ip
  | ServiceTags tags    -> List.exists (fun tag -> service_tag_allows_ip tag ip) tags
  | ApplicationGroups _ -> false   (* ASG membership is not resolved *)

let port_in p (r : port) =
  match r with
  | Single n     -> p = n
  | Range (a, b) -> a <= p && p <= b
  | Any          -> true

let ports_allow p ports = ports = [] || List.exists (port_in p) ports

let protocol_allows (rp : protocol) pp =
  match rp with Any -> true | x -> x = pp

let rule_matches (pkt : Packet.t) rule =
  let open Nsg.SecurityRule in
  protocol_allows (get_protocol rule) pkt.protocol
  && endpoint_allows_ip (get_src_ip rule) pkt.src_ip
  && endpoint_allows_ip (get_dest_ip rule) pkt.dest_ip
  && ports_allow pkt.src_port (get_src_ports rule)
  && ports_allow pkt.dest_port (get_dest_ports rule)

(* Azure's built-in default rules (lowest priority), modelled natively because
   they reference the VirtualNetwork / Internet service tags rather than CIDRs.
   Scope: VirtualNetwork = this VNet's address space only (no peering / on-prem);
   AzureLoadBalancer is not modelled; connection-initiating traffic only. *)
let default_allows vnet_cidrs (dir : Nsg.SecurityRule.direction) (pkt : Packet.t) =
  let src_vnet = ip_in_any vnet_cidrs pkt.src_ip in
  let dst_vnet = ip_in_any vnet_cidrs pkt.dest_ip in
  match dir with
  | Inbound  -> src_vnet && dst_vnet                 (* AllowVNetInBound, else DenyAllInBound *)
  | Outbound -> (src_vnet && dst_vnet) || not dst_vnet  (* AllowVnetOutBound / AllowInternetOutBound *)

(* No NSG attached => no filtering. Otherwise: first user rule (by priority) for
   this direction decides; if none match, fall through to the default rules. *)
let nsg_permits node (dir : Nsg.SecurityRule.direction) pkt =
  match node.nsg with
  | None -> true
  | Some nsg ->
    Nsg.get_rules nsg
    |> List.filter (fun r -> Nsg.SecurityRule.get_direction r = dir)
    |> List.sort Nsg.SecurityRule.compare
    |> List.find_opt (rule_matches pkt)
    |> (function
        | Some r -> Nsg.SecurityRule.get_access r = Nsg.SecurityRule.Allow
        | None -> default_allows node.vnet_cidrs dir pkt)

(* --- longest-prefix match --- *)

let longest_prefix routes ip =
  routes
  |> List.filter (fun r -> Packet.ip_in_cidr ip (Route_table.Route.get_prefix r))
  |> List.fold_left
       (fun best r ->
         match best with
         | None -> Some r
         | Some b ->
           if Int64.compare (mask_u64 (Route_table.Route.get_prefix r))
                            (mask_u64 (Route_table.Route.get_prefix b)) > 0
           then Some r
           else best)
       None

(* --- deterministic forwarding decision --- *)

let open_nsg = Nsg.SecurityRule.Outbound
let in_nsg   = Nsg.SecurityRule.Inbound

(* The parser resolves a route's next-hop IP from the route table's config
   references, which are per-table rather than per-route: a table naming several
   appliance NICs gives every route in it the whole set. A set is therefore a
   candidate list the parser could not narrow, not an Azure concept, so any
   candidate that forwards the packet counts. *)
let appliances_for g ref =
  match ref with
  | Unresolved | Resolved Unresolvable -> []
  | Resolved (StaticAppliance ip) -> Option.to_list (IPMap.find_opt ip g.appliance_by_ip)
  | Resolved (DynamicNic address) -> Option.to_list (AddressMap.find_opt address g.appliance_by_nic)
  | Resolved (ApplianceSet set) ->
    List.filter_map (fun a -> AddressMap.find_opt a g.appliance_by_nic) set

let already_visited visited (node : node) = List.mem node.address visited

let deliver_to_owner g ~vnet pkt =
  match node_in_vnet_owning g.nodes ~vnet pkt.Packet.dest_ip with
  | Some target -> nsg_permits target in_nsg pkt
  | None -> false

(* Azure has no L2 segment inside a subnet: every packet, including same-subnet
   traffic, is matched against the effective routes by LPM. (See the
   "Within-Subnet1" UDR in the docs' routing example — without it, a VNet-wide
   UDR to an appliance captures intra-subnet traffic, and "Azure doesn't create
   default routes for subnet address ranges".) So there is no
   deliver-before-routing shortcut: the egress NSG is scanned, LPM picks one
   route, and only a VirtualNetwork next hop delivers.

   A VirtualAppliance next hop instead hands the packet to the appliance's NIC
   and re-routes from the subnet that hosts it, so forwarding is a walk. The
   packet is not rewritten along the way: a NAT-ing appliance would change the
   header, and modelling that would need appliance-internal semantics Azure
   itself does not define. Revisiting a node ends the walk — the same node makes
   the same LPM decision for the same destination, so a repeat is a routing
   loop, not progress. *)
let rec route_from g ~visited node pkt =
  if already_visited visited node then false
  else
    nsg_permits node open_nsg pkt
    && (match longest_prefix node.routes pkt.Packet.dest_ip with
        | Some route -> follow_hop g ~visited:(node.address :: visited) ~from:node route pkt
        | None -> false)

and follow_hop g ~visited ~from route pkt =
  match Route_table.Route.get_next_hop route with
  | VirtualNetwork -> deliver_to_owner g ~vnet:from.vnet pkt
  | VirtualAppliance ->
    appliances_for g (Route_table.Route.get_next_hop_ip route)
    |> List.exists (fun a -> hop_through_appliance g ~visited a pkt)
  (* Internet / VirtualGateway leave the intra-VNet scope; Drop is a drop. *)
  | Internet | VirtualGateway | Drop -> false

and hop_through_appliance g ~visited appliance pkt =
  match Hashtbl.find_opt g.nodes appliance.subnet_address with
  | None -> false
  | Some node ->
    nsg_permits node in_nsg pkt
    && appliance.forwards
    && route_from g ~visited node pkt

let reachable_in g ~src pkt =
  match Hashtbl.find_opt g.nodes src with
  | None -> false
  | Some cur -> route_from g ~visited:[] cur pkt

let reachable world ~src pkt = reachable_in (build_graph world) ~src pkt
