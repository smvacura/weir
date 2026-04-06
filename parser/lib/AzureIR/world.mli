open Parser.Tf_types

type t = {
  resource_groups : Rg.t IdKeyMap.t;
  subnets : Subnet.t AddressMap.t;
  vnets : Vnet.t IdKeyMap.t;
  nsgs : Nsg.t IdKeyMap.t;
  nics : Nic.t IdKeyMap.t;
  pips : Pip.t AddressMap.t;
  route_tables : Route_table.t AddressMap.t;
  route_table_associations : (Route_table.t, Subnet.t) Association.BinaryAssociation.t AddressMap.t
}

val empty : t

val equal : t -> t-> bool

val get_resource_group : t -> string -> string  -> Rg.t option

val show : t -> string