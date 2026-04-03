open Parser.Azure_types
open Parser.Network_types
open Parser.Tf_types

module Route = struct
  
  type t = {
    name : string;
    address_prefix : CIDR.t;
    next_hop : next_hop
  }
end

type t = {
  name : string;
  subscription : string;
  address : string;
  location : azure_location;
  resource_group : Rg.t;
  disable_bgp_route_propagation : bool;
  tags : tag list;
}