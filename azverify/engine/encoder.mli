open Parser.Network_types

open Bdd

type header_segment =
| DestIP
| SrcIP
| DestPort
| SrcPort
| Protocol

val get_offset : header_segment -> int

val encode_nsg : Effective_nsg.t -> manager -> bdd

val encode_route_cidrs : manager -> offset:int -> CIDR.t list -> bdd

val encode_interval : manager -> width:int -> offset:int -> int -> int -> bdd

val encode_effective_route : manager -> (int32 * int32) list -> bdd