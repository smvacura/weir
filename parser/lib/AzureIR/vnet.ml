open Parser.Azure_types

module Id = struct
  
  type t = string

  let compare = String.compare

  let of_string s = s
end


type t = {
  name : string;
  id : Id.t;
  location : azure_location;
  resource_group : Rg.t;
}

let get_name vnet = vnet.name

let make_vnet name id loc rg = { 
  name = name;
  id = id;
  location = loc;
  resource_group = rg;
  }

module Map = Map.Make(Id)