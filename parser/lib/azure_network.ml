open Azure_types


module Subnet = struct
  
  type t = {  
    name : string;
    resource_group : azure_resource_group
  }

end

module Vnet = struct

type t = {
  name : string;
  location : azure_location;
  resource_group : azure_resource_group;

}

end