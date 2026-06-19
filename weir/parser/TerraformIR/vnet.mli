open Parser.Tf_types
open Parser.Azure_types
open Parser.Network_types

type t

val get_name : t -> string

val get_address : t -> string

val get_id : t -> IdKey.t

val get_rg : t -> Rg.t

val get_addresses : t -> CIDR.t list

val make : 
    name:string ->
    subscription:string ->
    address:string ->
    location:azure_location -> 
    resource_group:Rg.t -> 
    addresses:CIDR.t list -> 
    t

val compare : t -> t -> int

val show : t -> string

val pp : Format.formatter -> t -> unit

val show_vnet_map : t AddressMap.t -> string