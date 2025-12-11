
module IPv4 : sig
  type t
  val of_octets_opt : int -> int -> int -> int -> t option
  val of_string_opt : string -> t option
end

module IPv4Mask : sig
  type t

  val of_string_opt : string -> t option

  val mask_of_prefix : t -> int32
end

module CIDR : sig
  type t

  val make : IPv4.t -> IPv4Mask.t -> t

  val of_string_opt : string -> t option
end