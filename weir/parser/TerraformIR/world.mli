open Parser.Tf_types

type assocs = {
  subnet_nsg     : Nsg.t AddressMap.t;
  subnet_rt      : Route_table.t AddressMap.t;
  nic_nsg        : Nsg.t AddressMap.t;
  asg_to_nics    : Nic.t list AddressMap.t;
  subnet_to_nics : Nic.t list AddressMap.t;
}

type t = {
  resource_groups : Rg.t AddressMap.t;
  subnets : Subnet.t AddressMap.t;
  vnets : Vnet.t AddressMap.t;
  nsgs : Nsg.t AddressMap.t;
  nics : Nic.t AddressMap.t;
  pips : Pip.t AddressMap.t;
  route_tables : Route_table.t AddressMap.t;
  vnet_peerings : Vnet_peering.t AddressMap.t;
  asgs : Asg.t AddressMap.t;
  assocs : assocs;
}

val empty : t

val equal : t -> t-> bool

val get_resource_group : t -> string -> string  -> Rg.t option

val resource_addresses : t -> string list

val show : t -> string
