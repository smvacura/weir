open Terraform_ir
open Parser.Azure_types
open Parser.Network_types

type t = { disable_bgp_route_propagation : bool; routes : Route_table.Route.t list }

let get_effective_routes t = t.routes

let construct_vnetlocal_route_from_cidr name cidr =
  Route_table.Route.make
    ~name
    ~address_prefix:cidr
    ~next_hop:VirtualNetwork
    ~next_hop_in_ip_address:None
    ~source:System

let vnetlocal_route_name vnet_name subnet_name =
  "system_route_" ^ subnet_name ^ "_in_" ^ vnet_name

let construct_vnetlocal_route_from_subnet vnet_name subnet =
  let address_blocks = Subnet.get_cidrs subnet in
  List.map (construct_vnetlocal_route_from_cidr (vnetlocal_route_name vnet_name (Subnet.get_name subnet))) address_blocks

let get_decomposed_vnet_routes vnet map =
  let vnet_name = Vnet.get_name vnet in
  match Utils.VnetMap.find_opt vnet map with
  | Some subnets -> Some (List.concat_map (construct_vnetlocal_route_from_subnet vnet_name) subnets)
  | None -> None

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
      ~next_hop_in_ip_address:None
      ~source:System;
    Route_table.Route.make
      ~name:"Internal Class A"
      ~address_prefix:(make_exact_cidr "10.0.0.0" "8")
      ~next_hop:Drop
      ~next_hop_in_ip_address:None
      ~source:System;
    Route_table.Route.make
      ~name:"Internal Class B"
      ~address_prefix:(make_exact_cidr "172.16.0.0" "12")
      ~next_hop:Drop
      ~next_hop_in_ip_address:None
      ~source:System;
    Route_table.Route.make
      ~name:"Internal Class C"
      ~address_prefix:(make_exact_cidr "192.168.0.0" "16")
      ~next_hop:Drop
      ~next_hop_in_ip_address:None
      ~source:System;
    Route_table.Route.make 
      ~name:"Carrier-grade NAT"
      ~address_prefix:(make_exact_cidr "100.64.0.0" "10")
      ~next_hop:Drop
      ~next_hop_in_ip_address:None
      ~source:System
  ]

let filter_routes udrs lower_routes =
  List.filter (fun x -> not (List.exists (fun y -> (Route_table.Route.get_prefix y) = (Route_table.Route.get_prefix x)) udrs)) lower_routes


let enrich_route_table (rt : Route_table.t) (vnet : Vnet.t) (map : Utils.subnet_index) =
  let filtered_system_routes = filter_routes (Route_table.get_routes rt) system_routes in
  let new_routes = match get_decomposed_vnet_routes vnet map with
  | Some routes -> filter_routes (Route_table.get_routes rt) routes @ filtered_system_routes
  | None -> filtered_system_routes
  in
  { disable_bgp_route_propagation = false; routes = Route_table.get_routes rt @ new_routes }

