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

  val compare : t -> t -> int

  val show : t -> string

  val pp : Format.formatter -> t -> unit

  val show_cidr_map : t CIDRMap.t -> string
end

type t

val get_name : t -> string

val get_address : t -> string

val get_routes : t -> Route.t list

val make : name:string -> subscription:string -> address:string -> location:azure_location -> resource_group:Rg.t -> ?disable_bgp_route_propagation:bool -> routes:Route.t list -> tags:tag list -> t