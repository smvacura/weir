open Parser.Tf_types

type t

val get_name : t -> string

val get_address : t -> string

val get_id : t -> IdKey.t

val get_rg : t -> Rg.t

val make_vnet : string -> string -> string -> Parser.Azure_types.azure_location -> Rg.t -> Parser.Network_types.CIDR.t list -> t

val show : t -> string

val pp : Format.formatter -> t -> unit

val show_vnet_map : t IdKeyMap.t -> string