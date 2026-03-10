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
  resource_group : Rg.t;
  location : azure_location;
  allocation : ip_assignment;
} [@@deriving show]

let get_name pip =
  pip.name

let get_id pip = 
  (pip.name, pip.subscription, Rg.get_name pip.resource_group)

let make ~name ~subscription ~resource_group ~location ~allocation =
  { name; subscription; resource_group; location; allocation}

module Map = Map.Make(Id)

let show_pip_map m =
  "{" ^ 
  (m
  |> Map.bindings
  |> List.map (fun ((sub, rg, name),v) -> sub ^ rg ^ name ^ ":" ^ show v)
  |> String.concat ",")
  ^
  "}"