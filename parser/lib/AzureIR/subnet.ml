open Parser.Network_types

module Id = struct

  type t = string

  let compare = String.compare

  let of_string s = s

end


type t = {  
    name : string;
    id : Id.t;
    resource_group : Rg.t;
    addresses : CIDR.t list
  }

let get_name subnet = subnet.name

let make_subnet name id rg addresses = {
  name = name;
  id = id;
  resource_group = rg;
  addresses = addresses
}

module Map = Map.Make(Id) 