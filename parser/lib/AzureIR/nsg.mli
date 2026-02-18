open Parser.Azure_types
open Parser.Network_types

module Id : sig
    type t

    val compare : t -> t -> int

    val of_strings : string -> string -> string -> t

    val to_strings : t -> (string * string * string)

end

module SecurityRule : sig
  type t
end

type t

val make : string -> string -> string -> azure_location -> Rg.t -> SecurityRule.t list -> tag list -> t

val get_id : t -> Id.t

val show : t -> string

module Map : Map.S with type key = Id.t 

val show_nsg_map : t Map.t -> string