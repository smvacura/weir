open Parser.Azure_types
open Parser.Network_types

module Id = struct
  
  type t = string

  let compare = String.compare

  let of_string s = s

  let to_string s = s
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

let get_name_string vnet = vnet.name

let get_rg vnet = vnet.resource_group

let make_vnet name id loc rg addresses = { 
  name = name;
  id = id;
  location = loc;
  resource_group = rg;
  addresses = addresses;
  }

let show_address_block addresses =
  let rec aux ell acc =
    match ell with
    | [] -> acc
    | h::t -> aux t ((CIDR.show h)::acc) 
  in
  "[" ^ String.concat "," (aux addresses []) ^ "]"

let show { name; id; location; resource_group; addresses } = 
  Printf.sprintf 
    "{ name = %s; id = %s; location = %s; resource_group = %s; address_space = [%s] }"
    name (Id.to_string id) (Parser.Azure_types.string_of_loc location) (Rg.get_name_string resource_group) (show_address_block addresses)

module Map = Map.Make(Id)

let show_vnet_map m =
  "{" ^ 
  (m
  |> Map.bindings
  |> List.map (fun (k,v) -> k ^ ":" ^ show v)
  |> String.concat ",")
  ^
  "}"