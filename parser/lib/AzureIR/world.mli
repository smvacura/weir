
type t = {
  resource_groups : Rg.t Rg.Map.t;
  subnets : Subnet.t Subnet.Map.t;
  vnets : Vnet.t Vnet.Map.t
}

val empty : t

val equal : t -> t-> bool

val get_resource_group : t -> string -> string  -> Rg.t option

val show : t -> string