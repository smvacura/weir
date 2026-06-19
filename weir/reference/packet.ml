open Parser.Network_types

type t = {
  src_ip    : int32;
  dest_ip   : int32;
  src_port  : int;
  dest_port : int;
  protocol  : protocol;
}
[@@deriving show]

let make ~src_ip ~dest_ip ~src_port ~dest_port ~protocol =
  { src_ip; dest_ip; src_port; dest_port; protocol }

let to_u64 (x : int32) = Int64.logand (Int64.of_int32 x) 0xFFFFFFFFL

let ip_in_cidr ip cidr =
  let (lo, hi) = CIDR.get_interval cidr in
  let u = to_u64 ip and l = to_u64 lo and h = to_u64 hi in
  Int64.compare l u <= 0 && Int64.compare u h <= 0
