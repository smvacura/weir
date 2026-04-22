open Parser.Azure_types
open Parser.Network_types
open Parser.Tf_types

type t = {
  name : string;
  subscription : string;
  address : string;
  resource_group : Rg.t;
  location : azure_location;
  allocation : public_ip_assignment;
} [@@deriving show]

let get_name pip =
  pip.name

let get_address pip =
  pip.address

let get_id pip = 
  IdKey.of_strings pip.name pip.subscription (Rg.get_name pip.resource_group)

let make ~name ~subscription ~address ~resource_group ~location ~allocation =
  { name; subscription; address; resource_group; location; allocation}

let show_pip_map m =
  "{" ^ 
  (m
  |> AddressMap.bindings
  |> List.map (fun (address,pip) -> address ^ ":" ^ show pip)
  |> String.concat ",")
  ^
  "}"