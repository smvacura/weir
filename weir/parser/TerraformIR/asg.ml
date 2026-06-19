open Parser.Azure_types
open Parser.Tf_types

type t = {
  name : string;
  subscription : string;
  address : string;
  location : azure_location;
  resource_group : Rg.t;
  tags : tag list;
} [@@deriving show]

let make ~name ~subscription ~address ~location ~resource_group ~tags =
  { name; subscription; address; location; resource_group; tags }

let get_name asg = asg.name

let get_address asg = asg.address

let get_id asg =
  IdKey.of_strings asg.subscription (Rg.get_name asg.resource_group) asg.name

let show { name; subscription; address; location; resource_group; tags } =
  Printf.sprintf
    "{ name = %s; subscription = %s; address = %s; location = %s; resource_group = %s; tags = [%s] }"
    name subscription address (string_of_loc location)
    (Rg.get_name resource_group)
    (String.concat ", " (List.map show_tag tags))

let show_asg_map m =
  "{" ^
  (m
  |> AddressMap.bindings
  |> List.map (fun (addr, v) -> addr ^ ":" ^ show v)
  |> String.concat ",")
  ^ "}"
