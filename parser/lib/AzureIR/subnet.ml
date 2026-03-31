open Parser.Network_types
open Parser.Tf_types


type t = {  
    name : string;
    subscription : string;
    address : string;
    resource_group : Rg.t;
    vnet : Vnet.t;
    addresses : CIDR.t list
  } [@@deriving show]

let get_name subnet = subnet.name

let get_address subnet = subnet.address

let get_id subnet  =
  IdKey.of_strings subnet.subscription (Rg.get_name subnet.resource_group) subnet.name

let make ~name:name ~subscription:subscription ~address:address ~resource_group:rg ~vnet:vnet ~addresses:addresses = {
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
    name address (Rg.get_name resource_group) (Vnet.get_name vnet) (show_address_block addresses)

let show_subnet_map m =
  "{" ^ 
  (m
  |> AddressMap.bindings
  |> List.map (fun (id ,s) -> id ^ ":" ^ show s)
  |> String.concat ",")
  ^
  "}"