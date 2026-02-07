open Parser.Azure_types
module Id : sig
    type t

    val compare : t -> t -> int

    val of_string : string -> t

end


type t

val get_name : t -> Id.t

val get_name_string : t -> string

val make_rg : string -> Id.t -> azure_location -> string option -> tag list -> t

val show : t -> string

module Map : Map.S with type key = Id.t 

val show_rg_map : t Map.t -> string