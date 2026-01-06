open Parser.Azure_types

module Id = struct
  
  type t = string

  let compare = String.compare
end


type t = {
  name : string;
  location : azure_location;
  resource_group : Rg.t;
}

let get_name vnet = vnet.name

let make_vnet name loc rg = { 
  name = name;
  location = loc;
  resource_group = rg;
  }

module Map = Map.Make(Id)