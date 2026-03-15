open Parser.Azure_types
open Parser.Tf_types


type t = {
    name : string;
    subscription : string;
    address : string;
    location : azure_location;
    managed_by : string option;
    tags : tag list
  } [@@deriving show]

let get_name rg = rg.name

let get_address rg = rg.address

let get_id rg  = 
  IdKey.of_strings rg.subscription rg.name rg.name


let make ~name:name ~subscription:subscription ~address:address ~location:location ~managed_by:managed_by ~tags:tags = {
  name = name;
  subscription = subscription;
  address = address;
  location = location;
  managed_by = managed_by;
  tags = tags
}

let show { name; subscription; address; location; managed_by; tags } =
  let managed_str = Option.fold ~none:"None" ~some:(fun s -> s) managed_by in
  let tags_str = String.concat ", " (List.map Parser.Azure_types.show_tag tags) in
  Printf.sprintf 
    "{ name = %s; subscription = %s; address = %s; location = %s; managed_by = %s; tags = [%s] }"
    name subscription address (Parser.Azure_types.string_of_loc location) managed_str tags_str

let show_rg_map m =
  "{" ^ 
  (m
  |> IdKeyMap.bindings
  |> List.map (fun (id,v) -> (IdKey.show id) ^ ":" ^ show v)
  |> String.concat ",")
  ^
  "}"