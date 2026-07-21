open Terraform_ir
open Parser.Azure_types
open Parser.Network_types
open Utils

type t = { bgp_route_propagation_enabled : bool; routes : Route_table.Route.t list }

let get_effective_routes t = t.routes

let construct_vnetlocal_route_from_cidr name cidr =
  Route_table.Route.make
    ~name
    ~address_prefix:cidr
    ~next_hop:VirtualNetwork
    ~next_hop_in_ip_address:Unresolved
    ~source:System

let get_vnet_routes vnet =
  let vnet_name = Vnet.get_name vnet in
  List.map (construct_vnetlocal_route_from_cidr ("system_route_" ^ vnet_name)) (Vnet.get_addresses vnet)

let get_peered_routes vnet peer_idx =
  let vnet_name = Vnet.get_name vnet in
  let peered_cidrs = match VnetMap.find_opt vnet peer_idx with
  | Some entries -> List.map fst entries
  | None -> []
  in
  List.map (construct_vnetlocal_route_from_cidr ("peered_route_" ^ vnet_name)) peered_cidrs

let make_exact_cidr ip mask =
  CIDR.make 
  (Option.get (IPv4.of_string_opt ip))
  (Option.get (IPv4Mask.of_string_opt mask))

let system_routes = 
  [
    Route_table.Route.make
      ~name:"Internet"
      ~address_prefix:(make_exact_cidr "0.0.0.0" "0")
      ~next_hop:Internet
      ~next_hop_in_ip_address:Unresolved
      ~source:System;
    Route_table.Route.make
      ~name:"Internal Class A"
      ~address_prefix:(make_exact_cidr "10.0.0.0" "8")
      ~next_hop:Drop
      ~next_hop_in_ip_address:Unresolved
      ~source:System;
    Route_table.Route.make
      ~name:"Internal Class B"
      ~address_prefix:(make_exact_cidr "172.16.0.0" "12")
      ~next_hop:Drop
      ~next_hop_in_ip_address:Unresolved
      ~source:System;
    Route_table.Route.make
      ~name:"Internal Class C"
      ~address_prefix:(make_exact_cidr "192.168.0.0" "16")
      ~next_hop:Drop
      ~next_hop_in_ip_address:Unresolved
      ~source:System;
    Route_table.Route.make 
      ~name:"Carrier-grade NAT"
      ~address_prefix:(make_exact_cidr "100.64.0.0" "10")
      ~next_hop:Drop
      ~next_hop_in_ip_address:Unresolved
      ~source:System
  ]

let filter_routes udrs lower_routes =
  List.filter (fun x -> not (List.exists (fun y -> (Route_table.Route.get_prefix y) = (Route_table.Route.get_prefix x)) udrs)) lower_routes


let enrich_route_table (rt : Route_table.t) (vnet : Vnet.t) (peer_idx : Utils.peering_index) =
  let filtered_system_routes = filter_routes (Route_table.get_routes rt) system_routes in
  let vnet_routes = filter_routes (Route_table.get_routes rt) (get_vnet_routes vnet) in
  let peered_routes = filter_routes (Route_table.get_routes rt) (get_peered_routes vnet peer_idx) in
  { bgp_route_propagation_enabled = true; routes = Route_table.get_routes rt @ vnet_routes @ peered_routes @ filtered_system_routes }

