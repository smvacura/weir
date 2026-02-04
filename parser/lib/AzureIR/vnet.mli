
module Id : sig
    type t

    val compare : t -> t -> int

    val of_string : string -> t
end


type t

val get_name : t -> Id.t

val get_name_string : t -> string

val get_rg : t -> Rg.t

val make_vnet : string -> Id.t -> Parser.Azure_types.azure_location -> Rg.t -> Parser.Network_types.CIDR.t list -> t

module Map : Map.S with type key = Id.t 