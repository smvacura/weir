open Parser.Azure_types
open Parser.Network_types
open Parser.Tf_types

module Route : sig
  type t

  val make :
    name:string ->
    address_prefix:CIDR.t ->
    next_hop:next_hop ->
    next_hop_in_ip_address:appliance_ref resolvable ->
    source:route_source ->
    t

  val get_prefix : t -> CIDR.t

  val get_source : t -> route_source

  val get_next_hop : t -> next_hop

  val get_next_hop_ip : t -> appliance_ref resolvable

  val next_hop_is_unresolved : t -> bool

  val resolve_next_hop : ?list:(string list) -> ?address:string -> t -> t

  val compare : t -> t -> int

  val show : t -> string

  val pp : Format.formatter -> t -> unit

  val show_cidr_map : t CIDRMap.t -> string
end

type t

val get_name : t -> string

val get_address : t -> string

val get_routes : t -> Route.t list

val get_all_route_prefixes : t -> CIDR.t list

val resolve_routes : Route.t list -> t -> t

val make : name:string -> subscription:string -> address:string -> location:azure_location -> resource_group:Rg.t -> ?bgp_route_propagation_enabled:bool -> routes:Route.t list -> tags:tag list -> t

val empty : t

val show_rt_map : t AddressMap.t -> string