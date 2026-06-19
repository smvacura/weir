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

type graph = (string, node) Hashtbl.t

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

let build_graph (world : World.t) : graph =
  let g = Hashtbl.create (AddressMap.cardinal world.subnets) in
  AddressMap.iter
    (fun addr subnet ->
      let vnet_t = Subnet.get_vnet subnet in
      let cidr = match Subnet.get_cidrs subnet with c :: _ -> Some c | [] -> None in
      let nsg = AddressMap.find_opt addr world.assocs.subnet_nsg in
      let routes = effective_routes (Vnet.get_addresses vnet_t)
                     (AddressMap.find_opt addr world.assocs.subnet_rt) in
      Hashtbl.replace g addr
        { address = addr; vnet = Vnet.get_address vnet_t;
          vnet_cidrs = Vnet.get_addresses vnet_t; cidr; nsg; routes })
    world.subnets;
  g

let node_in_vnet_owning g ~vnet ip =
  Hashtbl.fold
    (fun _ (n : node) acc ->
      match acc, n.cidr with
      | Some _, _ -> acc
      | None, Some c when n.vnet = vnet && Packet.ip_in_cidr ip c -> Some n
      | None, _ -> None)
    g
    None

(* --- NSG rule scan with Azure default rules --- *)

let ip_in_any cidrs ip = List.exists (Packet.ip_in_cidr ip) cidrs

let endpoint_allows_ip (e : Nsg.SecurityRule.endpoint) ip =
  match e with
  | Any                 -> true
  | Addresses cidrs     -> ip_in_any cidrs ip
  | ApplicationGroups _ -> false   (* ASG / service-tag membership is not resolved *)

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

(* Azure has no L2 segment inside a subnet: every packet, including
   same-subnet traffic, is matched against the effective routes by LPM. (See
   the "Within-Subnet1" UDR in the docs' routing example — without it, a
   VNet-wide UDR to an appliance captures intra-subnet traffic, and "Azure
   doesn't create default routes for subnet address ranges".) So there is no
   deliver-before-routing shortcut: the egress NSG is scanned, LPM picks one
   route, and only a VirtualNetwork next hop delivers — to whichever subnet of
   this VNet owns the destination, possibly [src] itself, whose ingress NSG is
   then scanned. One LPM decision, one delivery; nothing to walk until
   appliance next hops are resolved. *)
let reachable_in g ~src pkt =
  match Hashtbl.find_opt g src with
  | None -> false
  | Some cur ->
    nsg_permits cur open_nsg pkt
    && (match longest_prefix cur.routes pkt.Packet.dest_ip with
        | Some route ->
          (match Route_table.Route.get_next_hop route with
           | VirtualNetwork ->
             (match node_in_vnet_owning g ~vnet:cur.vnet pkt.Packet.dest_ip with
              | Some target -> nsg_permits target in_nsg pkt
              | None -> false)
           (* VirtualAppliance needs NIC-node resolution (deferred); Internet /
              VirtualGateway leave the intra-VNet scope; Drop is a drop. *)
           | VirtualAppliance | Internet | VirtualGateway | Drop -> false)
        | None -> false)

let reachable world ~src pkt = reachable_in (build_graph world) ~src pkt
