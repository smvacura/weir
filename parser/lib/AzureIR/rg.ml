open Parser.Azure_types

module Id = struct
  type t = string

  let compare = String.compare

  let of_string (s : string) : t = s

  let to_string (id : t) : string = id
end

type t = {
    name : string;
    id : Id.t;
    location : azure_location;
    managed_by : string option;
    tags : tag list
  }

let get_name rg = rg.name

let get_name_string rg = rg.name

let make_rg name id location managed_by tags = {
  name = name;
  id = id;
  location = location;
  managed_by = managed_by;
  tags = tags
}

let show { name; id; location; managed_by; tags } =
  let managed_str = Option.fold ~none:"None" ~some:(fun s -> s) managed_by in
  let tags_str = String.concat ", " (List.map Parser.Azure_types.string_of_tag tags) in
  Printf.sprintf 
    "{ name = %s; id = %s; location = %s; managed_by = %s; tags = [%s] }"
    name (Id.to_string id) (Parser.Azure_types.string_of_loc location) managed_str tags_str

module Map = Map.Make(Id)

let show_rg_map m =
  "{" ^ 
  (m
  |> Map.bindings
  |> List.map (fun (k,v) -> k ^ ":" ^ show v)
  |> String.concat ",")
  ^
  "}"