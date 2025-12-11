
module IPv4 : sig
  type t
  val of_octets : int -> int -> int -> int -> t option
  val of_string : string -> t option
end

module IPv4Mask : sig
  type t
  val mask_of_prefix : t -> int32
end

module CIDR : sig
  type t
end