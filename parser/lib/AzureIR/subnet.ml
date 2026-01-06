open Parser.Network_types

module Id = struct

  type t = string

  let compare = String.compare

end


type t = {  
    name : string;
    resource_group : Rg.t;
    addresses : CIDR.t list
  }

let get_name subnet = subnet.name

let make_subnet name rg addresses = {
  name = name;
  resource_group = rg;
  addresses = addresses
}

module Map = Map.Make(Id) 