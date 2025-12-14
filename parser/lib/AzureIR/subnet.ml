open Parser.Azure_types
open Parser.Network_types

module Id = struct

  type t = string

  let compare = String.compare

end


type t = {  
    name : string;
    resource_group : azure_resource_group;
    addresses : CIDR.t list
  }

module Map = Map.Make(Id) 