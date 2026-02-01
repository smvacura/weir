open Parser.Azure_types
open Parser.Network_types

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
  addresses : CIDR.t list
}

let get_name vnet = vnet.name

let get_name_string vnet = vnet.name

let get_rg vnet = vnet.resource_group

let make_vnet name id loc rg addresses = { 
  name = name;
  id = id;
  location = loc;
  resource_group = rg;
  addresses = addresses;
  }

module Map = Map.Make(Id)