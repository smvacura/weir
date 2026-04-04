open Parser.Azure_types
open Parser.Network_types
open Parser.Tf_types

module Route : sig
  type t

  val make : name:string -> address_prefix:CIDR.t -> next_hop:next_hop -> next_hop_in_ip_address:IPv4.t option -> t
end

type t

val get_name : t -> string

val get_address : t -> string

val make : name:string -> subscription:string -> address:string -> location:azure_location -> resource_group:Rg.t -> ?disable_bgp_route_propagation:bool -> routes:Route.t list -> tags:tag list -> t