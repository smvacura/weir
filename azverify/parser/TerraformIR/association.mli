open Parser.Tf_types

module BinaryAssociation : sig

    type ('a, 'b) t

    val make : 'a -> 'b -> string -> ('a, 'b) t

    val get_address : ('a, 'b) t -> string

    val get_r1 : ('a, 'b) t -> 'a

    val get_r2 : ('a, 'b) t -> 'b

    val show_assoc_map : ('a, 'b) t AddressMap.t -> string

end