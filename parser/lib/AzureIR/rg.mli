open Parser.Azure_types
open Parser.Tf_types

type t

val get_name : t -> string

val get_address : t -> string

val get_id : t -> IdKey.t

val make : 
    name:string ->
    subscription:string ->
    address:string ->
    location:azure_location -> 
    managed_by:string option -> 
    tags:tag list -> 
    t

val show : t -> string

val pp : Format.formatter -> t -> unit

val show_rg_map : t IdKeyMap.t -> string