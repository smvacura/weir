open Parser.Tf_types

type t = {
  resource_groups : Rg.t IdKeyMap.t;
  subnets : Subnet.t IdKeyMap.t;
  vnets : Vnet.t IdKeyMap.t;
  nsgs : Nsg.t IdKeyMap.t;
  nics : Nic.t IdKeyMap.t;
  pips : Pip.t Pip.Map.t
}

val empty : t

val equal : t -> t-> bool

val get_resource_group : t -> string -> string  -> Rg.t option

val show : t -> string