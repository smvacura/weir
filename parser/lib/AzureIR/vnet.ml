open Parser.Azure_types

module Id = struct
  
  type t = string

  let compare = String.compare
end


type t = {
  name : string;
  location : azure_location;
  resource_group : azure_resource_group;
  subnets : string list
}

module Map = Map.Make(Id)