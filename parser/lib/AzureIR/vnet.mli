
module Id : sig
    type t

    val compare : t -> t -> int

    val of_strings : string -> string -> string -> t
end


type t

val get_name : t -> string

val get_name_string : t -> string

val get_name_string : t -> string

val get_rg : t -> Rg.t

val get_id : t -> Id.t

val make_vnet : string -> string -> string -> Parser.Azure_types.azure_location -> Rg.t -> Parser.Network_types.CIDR.t list -> t

val show : t -> string

val pp : Format.formatter -> t -> unit

module Map : Map.S with type key = Id.t 

val show_vnet_map : t Map.t -> string