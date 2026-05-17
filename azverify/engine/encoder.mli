open Parser.Network_types

open Bdd

type header_segment

val encode_nsg : Effective_nsg.t -> manager -> bdd

val encode_route_cidrs : manager -> header_segment -> CIDR.t list -> bdd

val encode_interval : manager -> width:int -> int -> int -> bdd