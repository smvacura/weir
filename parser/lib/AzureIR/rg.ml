open Parser.Azure_types

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
    managed_by : string option;
    tags : tag list
  }

let get_name rg = rg.name

let get_id rg : Id.t  = 
  (rg.subscription, rg.name, rg.name)


let make_rg name subscription address location managed_by tags = {
  name = name;
  subscription = subscription;
  address = address;
  location = location;
  managed_by = managed_by;
  tags = tags
}

let show { name; subscription; address; location; managed_by; tags } =
  let managed_str = Option.fold ~none:"None" ~some:(fun s -> s) managed_by in
  let tags_str = String.concat ", " (List.map Parser.Azure_types.string_of_tag tags) in
  Printf.sprintf 
    "{ name = %s; subscription = %s; address = %s; location = %s; managed_by = %s; tags = [%s] }"
    name subscription address (Parser.Azure_types.string_of_loc location) managed_str tags_str

module Map = Map.Make(Id)

let show_rg_map m =
  "{" ^ 
  (m
  |> Map.bindings
  |> List.map (fun ((sub, rg, name),v) -> sub ^ rg ^ name ^ ":" ^ show v)
  |> String.concat ",")
  ^
  "}"