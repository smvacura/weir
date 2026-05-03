open Parser.Tf_types

type t = {
  subnets : Subnet.t CIDRMap.t;
  routes : Route_table.Route.t CIDRMap.t;
  nics : Nic.t CIDRMap.t;
}

val empty : t

val equal : t -> t -> bool

val show : t -> string
