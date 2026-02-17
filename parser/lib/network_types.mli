
module IPv4 : sig
  type t
  val of_octets_opt : int -> int -> int -> int -> t option
  val of_string_opt : string -> t option
  val of_int32 : int32 -> t
end

module IPv4Mask : sig
  type t

  val of_string_opt : string -> t option

  val mask_of_prefix : int -> t

  val of_int32 : int32 -> t
end

module CIDR : sig
  type t

  val make : IPv4.t -> IPv4Mask.t -> t

  val of_string_opt : string -> t option

  val of_list_opt_strict : string option list -> t list option

  val show : t -> string
end

type protocol

type port