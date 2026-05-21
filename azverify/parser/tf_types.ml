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

module IPMap = Map.Make(Network_types.IPv4)

module CIDRMap = Map.Make(Network_types.CIDR)

module AddressSet = struct
  include Set.Make(String)

  let pp fmt t =
    Format.fprintf fmt "@[<hov>{%a}@]"
      (Format.pp_print_seq
         ~pp_sep:(fun fmt () -> Format.fprintf fmt ";@ ")
         Format.pp_print_string)
      (to_seq t)
end