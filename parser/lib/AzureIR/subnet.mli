open Parser.Network_types

module Id : sig
    type t

    val compare : t -> t -> int

    val of_strings : string -> string -> string -> t
    
    val to_strings : t -> string * string * string

    val to_string : t -> string
end


type t

val get_name : t -> string

val get_id : t -> Id.t

val make_subnet : string -> string -> string -> Rg.t -> Vnet.t -> CIDR.t list -> t

val show : t -> string

val pp : Format.formatter -> t -> unit

module Map : Map.S with type key = Id.t 

val show_subnet_map : t Map.t -> string