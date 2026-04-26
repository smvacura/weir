
module IPv4 : sig
  type t
  val of_octets_opt : int -> int -> int -> int -> t option
  val of_string_opt : string -> t option
  val of_int32 : int32 -> t
  val pp : Format.formatter -> t -> unit
  val show : t -> string
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

  val get_interval : t -> int32 * int32

  val get_mask : t -> int32

  val show : t -> string

  val pp : Format.formatter -> t -> unit
end

type ip_type =
 | IPv4
 | IPv6
 [@@deriving show]

val ip_type_of_string_opt : string -> ip_type option

type protocol =
 | Tcp 
 | Udp 
 | Icmp 
 | Any

val protocol_of_string_opt : string -> protocol option

val show_protocol : protocol -> string

val pp_protocol : Format.formatter -> protocol -> unit

type port = 
 | Single of int 
 | Range of int * int 
 | Any

val port_of_string_opt : string -> port option

val port_list_of_string_list_opt : string list -> port list option

val show_port : port -> string

val pp_port : Format.formatter -> port -> unit

type private_ip_assignment =
  | Static of IPv4.t
  | Dynamic
  [@@deriving show]

type public_ip_assignment =
  | Static
  | Dynamic
  [@@deriving show]