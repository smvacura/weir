open Parser.Azure_types
open Parser.Network_types

module Id : sig
    type t

    val compare : t -> t -> int

    val of_strings : string -> string -> string -> t

    val to_strings : t -> (string * string * string)

end

type t

val get_name : t -> string

val get_id : t -> Id.t

val make : string -> string -> Rg.t -> azure_location -> ip_assignment -> t

val show : t -> string

val pp : Format.formatter -> t -> unit