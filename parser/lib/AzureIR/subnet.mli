open Parser.Network_types

module Id : sig
    type t

    val compare : t -> t -> int

end


type t

val get_name : t -> Id.t

val make_subnet : string -> Rg.t -> CIDR.t list -> t

module Map : Map.S with type key = Id.t 