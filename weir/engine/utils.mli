open Terraform_ir
open Parser.Network_types

module VnetMap : Map.S with type key = Vnet.t

type subnet_index = Subnet.t list VnetMap.t

(** [(cidr, allow_virtual_network_access)] per peered VNet, keyed by local VNet.
    Filter by [snd] to restrict to entries that expand the VirtualNetwork NSG tag. *)
type peering_index = (CIDR.t * bool) list VnetMap.t

val get_subnet_index : World.t -> subnet_index
val get_peering_index : World.t -> peering_index
