open Azure_types
open Network_types


module Subnet = struct
  
  type t = {  
    name : string;
    resource_group : azure_resource_group;
    addresses : CIDR.t list
  }

end

module Vnet = struct

type t = {
  name : string;
  location : azure_location;
  resource_group : azure_resource_group;
  subnets : Subnet.t list
}

end

module NSG = struct

  type t = {
    name : string
  }

end