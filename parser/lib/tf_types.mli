type 'a resolvable =
| Resolved of 'a
| Unresolved
[@@deriving show]

module IdKey : sig
  type t 
  val compare : t -> t -> int
  val of_strings : string -> string -> string -> t
  val to_strings : t -> string * string * string
  val show : t -> string
  val pp : Format.formatter -> t -> unit
end

module IdKeyMap : Map.S with type key = IdKey.t 