open Parser.Azure_types
open Parser.Network_types
open Parser.Tf_types

module IpConfiguration : sig

    type t

    val make : string -> string -> Subnet.t -> [ `Ipv4 | `Ipv6 ] -> Pip.t option -> ip_assignment -> bool -> t
end

type t

val get_name : t -> string

val get_address : t -> string

val get_id : t -> IdKey.t

val make : name:string ->
    subscription:string ->
    address:string ->
    location:azure_location ->
    resource_group:Rg.t -> ip_configurations:IpConfiguration.t list -> t

val show : t -> string

val pp : Format.formatter -> t -> unit

val show_nic_map : t IdKeyMap.t -> string