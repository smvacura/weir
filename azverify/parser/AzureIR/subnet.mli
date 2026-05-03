open Parser.Network_types
open Parser.Tf_types

type t

val get_name : t -> string

val get_address : t -> string

val get_id : t -> IdKey.t

val get_vnet : t -> Vnet.t

val get_cidrs : t -> CIDR.t list

val make : 
    name:string ->
    subscription:string ->
    address:string ->
    resource_group:Rg.t -> 
    vnet:Vnet.t -> 
    addresses:CIDR.t list -> 
    t

val show : t -> string

val pp : Format.formatter -> t -> unit

val show_subnet_map : t AddressMap.t -> string

val show_subnet_cidr_map : t CIDRMap.t -> string