open Parser.Network_types
open Parser.Tf_types

type t

val get_name : t -> string

val get_address : t -> string

val get_id : t -> IdKey.t

val make_subnet : string -> string -> string -> Rg.t -> Vnet.t -> CIDR.t list -> t

val show : t -> string

val pp : Format.formatter -> t -> unit

val show_subnet_map : t IdKeyMap.t -> string