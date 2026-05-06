
module BinaryAssociation : sig

    type ('a, 'b) t

    val make : 'a -> 'b -> string -> ('a, 'b) t

    val get_address : ('a, 'b) t -> string

end