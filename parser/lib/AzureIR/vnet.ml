open Parser.Azure_types
open Parser.Network_types

module Id = struct
  
  type t = string * string * string

  let compare = compare

  let of_strings sub rg name : t = (sub, rg, name)

  let to_strings ((sub, rg, name) : t )  = (sub, rg, name)
end


type t = {
  name : string;
  subscription : string;
  address : string;
  location : azure_location;
  resource_group : Rg.t;
  addresses : CIDR.t list
} [@@deriving show]

let get_name vnet = vnet.name

let get_name_string vnet = vnet.name

let get_name_string vnet = vnet.name

let get_rg vnet = vnet.resource_group

let make_vnet name subscription address loc rg addresses = { 
  name = name;
  subscription = subscription;
  address = address;
  location = loc;
  resource_group = rg;
  addresses = addresses;
  }

let get_id vnet : Id.t =  
  (vnet.subscription, Rg.get_name (vnet.resource_group), vnet.name)

let show_address_block addresses =
  let rec aux ell acc =
    match ell with
    | [] -> acc
    | h::t -> aux t ((CIDR.show h)::acc) 
  in
  "[" ^ String.concat "," (aux addresses []) ^ "]"

let show { name; address; location; resource_group; addresses } = 
  Printf.sprintf 
    "{ name = %s; id = %s; location = %s; resource_group = %s; address_space = [%s] }"
    name address (Parser.Azure_types.string_of_loc location) (Rg.get_name resource_group) (show_address_block addresses)

module Map = Map.Make(Id)

let show_vnet_map m =
  "{" ^ 
  (m
  |> Map.bindings
  |> List.map (fun ((sub, rg, name),v) -> sub ^ rg ^ name ^ ":" ^ show v)
  |> String.concat ",")
  ^
  "}"