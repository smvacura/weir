open Parser.Azure_types
module Id : sig
    type t

    val compare : t -> t -> int

    val of_strings : string -> string -> string -> t

    val to_strings : t -> (string * string * string)

end


type t

val get_name : t -> string

val get_id : t -> Id.t

val make_rg : string -> string -> string -> azure_location -> string option -> tag list -> t

val show : t -> string

module Map : Map.S with type key = Id.t 

val show_rg_map : t Map.t -> string