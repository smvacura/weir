open Parser.Tf_types
open Parser.Azure_types

type t

val get_name : t -> string

val get_address : t -> string

val get_id : t -> IdKey.t

val get_rg : t -> Rg.t

val get_local_vnet : t -> Vnet.t resolvable

val get_remote_vnet : t -> Vnet.t resolvable

val get_allow_virtual_network_access : t -> bool option

val get_allow_forwarded_traffic : t -> bool option

val get_allow_gateway_transit : t -> bool option

val get_use_remote_gateways : t -> bool option

val get_local_subnet_names : t -> string list option

val get_remote_subnet_names : t -> string list option

val get_peer_complete_virtual_networks_enabled : t -> bool option

val resolve_local_vnet : Vnet.t -> t -> t

val resolve_remote_vnet : Vnet.t -> t -> t

val make :
  name:string ->
  subscription:string ->
  address:string ->
  resource_group:Rg.t ->
  local_vnet:Vnet.t resolvable ->
  remote_vnet:Vnet.t resolvable ->
  allow_virtual_network_access:bool option ->
  allow_forwarded_traffic:bool option ->
  allow_gateway_transit:bool option ->
  use_remote_gateways:bool option ->
  local_subnet_names:string list option ->
  remote_subnet_names:string list option ->
  peer_complete_virtual_networks_enabled:bool option ->
  t

val compare : t -> t -> int

val show : t -> string

val pp : Format.formatter -> t -> unit

val show_peering_map : t AddressMap.t -> string
