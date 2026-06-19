open Parser.Network_types

(* A fully concrete point in header space: one IP, one port, one protocol per
   field. This is what gets pinged on real Azure and what an HSA result is
   sampled down to, so it carries no ranges or wildcards. *)
type t = {
  src_ip    : int32;
  dest_ip   : int32;
  src_port  : int;
  dest_port : int;
  protocol  : protocol;
}
[@@deriving show]

val make :
  src_ip:int32 ->
  dest_ip:int32 ->
  src_port:int ->
  dest_port:int ->
  protocol:protocol ->
  t

(* Unsigned membership of an IPv4 address in a CIDR block. IPv4 addresses are
   held as [int32] but ordered as unsigned 32-bit, so comparison goes through
   [int64] to avoid the sign bit flipping order at 128.0.0.0. *)
val ip_in_cidr : int32 -> CIDR.t -> bool
