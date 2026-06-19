open Parser.Azure_types
open Parser.Network_types
open Parser.Tf_types

module Route = struct

  type t = {
    name : string;
    address_prefix : CIDR.t;
    next_hop : next_hop;
    next_hop_in_ip_address : appliance_ref resolvable;
    source : route_source;
  }

  let make ~name ~address_prefix ~next_hop ~next_hop_in_ip_address ~source =
    { name; address_prefix; next_hop; next_hop_in_ip_address; source }

  let get_prefix route =
    route.address_prefix

  let get_source route =
    route.source

  let get_next_hop route = 
    route.next_hop

  let get_next_hop_ip route = 
    route.next_hop_in_ip_address

  let compare r1 r2 =
    match Int32.unsigned_compare
      (Parser.Network_types.CIDR.get_mask r1.address_prefix)
      (Parser.Network_types.CIDR.get_mask r2.address_prefix)
    with
    | 0 -> compare r1.source r2.source
    | c -> c

  let next_hop_is_unresolved r =
    match r.next_hop_in_ip_address with
    | Unresolved -> true
    | _ -> false
  
  let resolve_next_hop ?list ?address r = 
    match address with
    | Some address -> { r with next_hop_in_ip_address = Resolved (DynamicNic address)}
    | None -> begin 
    match list with 
    | Some list -> { r with next_hop_in_ip_address = Resolved (ApplianceSet list)}
    | None -> { r with next_hop_in_ip_address = Resolved Unresolvable }
    end 

  let show_next_hop_ip = function
    | Unresolved -> "Unresolved"
    | Resolved r -> show_appliance_ref r

  let show route =
    Printf.sprintf "{ name = %s; prefix = %s; next_hop = %s; next_hop_in_ip_address = %s; source = %s }"
      route.name (CIDR.show route.address_prefix) (show_next_hop route.next_hop)
      (show_next_hop_ip route.next_hop_in_ip_address)
      (show_route_source route.source)

  let pp fmt route = Format.fprintf fmt "%s" (show route)

  let show_cidr_map m =
    "{" ^
    (m
    |> CIDRMap.bindings
    |> List.map (fun (cidr, route) -> (CIDR.show cidr) ^ ":" ^ show route)
    |> String.concat ",")
    ^ "}"
end

type t = {
  name : string;
  subscription : string;
  address : string;
  location : azure_location;
  resource_group : Rg.t;
  bgp_route_propagation_enabled : bool;
  routes : Route.t list;
  tags : tag list;
}

let get_name rt = 
  rt.name

let get_address rt = 
  rt.address

let get_routes rt = rt.routes

let get_all_route_prefixes rt = 
  List.map Route.get_prefix rt.routes

let resolve_routes routes rt = 
  { rt with routes }

let make ~name ~subscription ~address ~location ~resource_group ?(bgp_route_propagation_enabled = true) ~routes ~tags =
  { name; subscription; address; location; resource_group; bgp_route_propagation_enabled; routes; tags }


let empty = {
  name = "EMPTY";
  subscription = "EMPTY";
  address = "EMPTY";
  location = EastUs;
  resource_group = Rg.empty;
  bgp_route_propagation_enabled = false;
  routes = [];
  tags = [];
}

let show rt =
  Printf.sprintf "{ name = %s; subscription = %s; location = %s; rg = %s; bgp_enabled = %s; tags = [%s]; routes = [%s] }"
    rt.name rt.subscription (show_azure_location rt.location)
    (Rg.get_name rt.resource_group)
    (string_of_bool rt.bgp_route_propagation_enabled)
    (rt.tags |> List.map show_tag |> String.concat "; ")
    (rt.routes |> List.map Route.show |> String.concat "; ")

let show_rt_map m =
  "{" ^
  (m
  |> AddressMap.bindings
  |> List.map (fun (addr, rt) -> addr ^ ":" ^ show rt)
  |> String.concat ",")
  ^ "}"