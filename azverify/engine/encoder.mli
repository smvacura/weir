open Parser.Network_types

open Bdd

val encode_nsg : Effective_nsg.t -> manager -> bdd

val encode_route_cidrs : manager -> offset:int -> CIDR.t list -> bdd

val encode_interval : manager -> width:int -> offset:int -> int -> int -> bdd

val encode_effective_route : manager -> (int * int) list -> bdd