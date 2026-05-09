open Parser.Azure_types
open Parser.Network_types
open Parser.Tf_types

module Route = struct

  type t = {
    name : string;
    address_prefix : CIDR.t;
    next_hop : next_hop;
    next_hop_in_ip_address : IPv4.t option;
    source : route_source;
  }

  let make ~name ~address_prefix ~next_hop ~next_hop_in_ip_address ~source =
    { name; address_prefix; next_hop; next_hop_in_ip_address; source }

  let get_prefix route =
    route.address_prefix

  let get_source route =
    route.source

  let compare r1 r2 =
    compare
    (Parser.Network_types.CIDR.get_mask r1.address_prefix)
    (Parser.Network_types.CIDR.get_mask r2.address_prefix)

  let show route =
    Printf.sprintf "{ name = %s; prefix = %s; next_hop = %s; source = %s }"
      route.name (CIDR.show route.address_prefix) (show_next_hop route.next_hop)
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
  disable_bgp_route_propagation : bool;
  routes : Route.t list;
  tags : tag list;
}

let get_name rt = 
  rt.name

let get_address rt = 
  rt.address

let get_routes rt = rt.routes

let make ~name ~subscription ~address ~location ~resource_group ?(disable_bgp_route_propagation = true) ~routes ~tags =
  { name; subscription; address; location; resource_group; disable_bgp_route_propagation; routes; tags } 