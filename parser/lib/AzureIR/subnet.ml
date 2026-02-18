open Parser.Network_types

module Id = struct

  type t = string * string * string

  let compare = compare

  let of_strings sub rg name : t = (sub, rg, name)

  let to_strings ((sub, rg, name) : t) = sub, rg, name

  let to_string ((sub, rg, name) : t) = sub ^ rg ^ name 

end


type t = {  
    name : string;
    subscription : string;
    address : string;
    resource_group : Rg.t;
    vnet : Vnet.t;
    addresses : CIDR.t list
  }

let get_name subnet = subnet.name

let get_id subnet : Id.t  = 
  (subnet.subscription, (Rg.get_name (subnet.resource_group)), subnet.name)

let make_subnet name subscription address rg vnet addresses = {
  name = name;
  subscription = subscription;
  address = address;
  resource_group = rg;
  vnet = vnet;
  addresses = addresses;
}

let show_address_block addresses =
  let rec aux ell acc =
    match ell with
    | [] -> acc
    | h::t -> aux t ((CIDR.show h)::acc) 
  in
  "[" ^ String.concat "," (aux addresses []) ^ "]"


let show { name; address; resource_group; vnet; addresses } = 
  Printf.sprintf 
    "{ name = %s; id = %s; location = %s; resource_group = %s; address_space = [%s] }"
    name address (Rg.get_name resource_group) (Vnet.get_name_string vnet) (show_address_block addresses)

module Map = Map.Make(Id) 

let show_subnet_map m =
  "{" ^ 
  (m
  |> Map.bindings
  |> List.map (fun ((sub, rg, name),v) -> sub ^ rg ^ name ^ ":" ^ show v)
  |> String.concat ",")
  ^
  "}"