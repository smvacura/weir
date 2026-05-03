open Parser.Azure_types
open Parser.Network_types
open Parser.Tf_types

module IpConfiguration : sig

    type t

    val make : name:string ->
        subscription:string ->
        subnet:Subnet.t resolvable ->
        ip_address_version:ip_type ->
        pip:Pip.t option resolvable ->
        private_address_allocation:private_ip_assignment ->
        primary:bool option -> t

    val get_name : t -> string

    val get_private_ip : t -> IPv4.t option

    val get_private_cidr : t -> CIDR.t list option

    val unresolved_fields : t -> string list

    val resolve : t -> subnet:Subnet.t -> ?pip:Pip.t option -> t

    val resolve_subnet : Subnet.t -> t -> t
end

type t

val get_name : t -> string

val get_address : t -> string

val get_id : t -> IdKey.t

val get_ipconfigs : t -> IpConfiguration.t list

val make : name:string ->
    subscription:string ->
    address:string ->
    location:azure_location ->
    resource_group:Rg.t -> ip_configurations:IpConfiguration.t list -> t

val resolve_ipconfigs : t -> IpConfiguration.t list -> t

val show : t -> string

val pp : Format.formatter -> t -> unit

val show_nic_map : t AddressMap.t -> string

val show_nic_ip_map : t IPMap.t -> string

val show_nic_cidr_map : t CIDRMap.t -> string