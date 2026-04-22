type 'a resolvable =
| Resolved of 'a
| Unresolved
[@@deriving show]

module IdKey = struct 
  type t = string * string * string
  [@@deriving show]
  let compare = compare

  let of_strings sub rg name : t = (sub, rg, name)

  let to_strings ((sub, rg, name) : t )  = (sub, rg, name)
end

module IdKeyMap = Map.Make(IdKey)

module AddressMap = Map.Make(String)