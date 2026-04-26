open Parser.Azure_types
open Parser.Network_types
open Parser.Tf_types

module Route = struct
  
  type t = {
    name : string;
    address_prefix : CIDR.t;
    next_hop : next_hop;
    next_hop_in_ip_address : IPv4.t option;
  }

  let make ~name ~address_prefix ~next_hop ~next_hop_in_ip_address =
    { name; address_prefix; next_hop; next_hop_in_ip_address }

  let get_prefix route =
    route.address_prefix

  let compare r1 r2 = 
    compare 
    (Parser.Network_types.CIDR.get_mask r1.address_prefix)
    (Parser.Network_types.CIDR.get_mask r2.address_prefix)
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