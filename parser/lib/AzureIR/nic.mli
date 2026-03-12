open Parser.Azure_types
open Parser.Network_types

module Id : sig
    type t

    val compare : t -> t -> int

    val of_strings : string -> string -> string -> t

    val to_strings : t -> (string * string * string)

end

module IpConfiguration : sig

    type t

    val make : string -> string -> Subnet.t -> [ `Ipv4 | `Ipv6 ] -> Pip.t option -> ip_assignment -> bool -> t
end

type t

val get_name : t -> string

val get_id : t -> Id.t

val make_nic : string -> string -> string -> Rg.t -> IpConfiguration.t list -> t

val show : t -> string

val pp : Format.formatter -> t -> unit

module Map : Map.S with type key = Id.t 

val show_nic_map : t Map.t -> string