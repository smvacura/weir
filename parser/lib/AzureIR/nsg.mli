
module Id : sig
    type t

    val compare : t -> t -> int

end


type t


module Map : Map.S with type key = Id.t 