open Parser.Azure_types
open Parser.Tf_types

type t

val get_name : t -> string

val get_address : t -> string

val get_id : t -> IdKey.t

val make_rg : string -> string -> string -> azure_location -> string option -> tag list -> t

val show : t -> string

val pp : Format.formatter -> t -> unit

val show_rg_map : t IdKeyMap.t -> string