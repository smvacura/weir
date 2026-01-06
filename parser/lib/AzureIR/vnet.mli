
module Id : sig
    type t

    val compare : t -> t -> int

end


type t

val get_name : t -> Id.t

val make_vnet : string -> Parser.Azure_types.azure_location -> Rg.t -> t

module Map : Map.S with type key = Id.t 