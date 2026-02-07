open Parser.Network_types

module Id = struct

  type t = string

  let compare = String.compare

  let of_string s = s

  let to_string id = id

end


type t = {  
    name : string;
    id : Id.t;
    resource_group : Rg.t;
    vnet : Vnet.t;
    addresses : CIDR.t list
  }

let get_name subnet = subnet.name

let make_subnet name id rg vnet addresses = {
  name = name;
  id = id;
  resource_group = rg;
  vnet = vnet;
  addresses = addresses
}

let show_address_block addresses =
  let rec aux ell acc =
    match ell with
    | [] -> acc
    | h::t -> aux t ((CIDR.show h)::acc) 
  in
  "[" ^ String.concat "," (aux addresses []) ^ "]"


let show { name; id; resource_group; vnet; addresses } = 
  Printf.sprintf 
    "{ name = %s; id = %s; location = %s; resource_group = %s; address_space = [%s] }"
    name (Id.to_string id) (Rg.get_name_string resource_group) (Vnet.get_name_string vnet) (show_address_block addresses)

module Map = Map.Make(Id) 

let show_subnet_map m =
  "{" ^ 
  (m
  |> Map.bindings
  |> List.map (fun (k,v) -> k ^ ":" ^ show v)
  |> String.concat ",")
  ^
  "}"