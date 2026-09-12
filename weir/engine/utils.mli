open Terraform_ir
open Parser.Network_types
open Parser.Tf_types

module VnetMap : Map.S with type key = Vnet.t

type subnet_index = Subnet.t list VnetMap.t

type peer = {
  remote_vnet : Vnet.t;
  access_allowed : bool;
  remote_forwarding_allowed : bool
}

type peering_index = peer list VnetMap.t

type asg_index = CIDR.t list AddressMap.t

val get_subnet_index : World.t -> subnet_index
val get_peering_index : World.t -> peering_index
val get_asg_index : World.t -> asg_index
