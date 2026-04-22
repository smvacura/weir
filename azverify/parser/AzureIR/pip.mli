open Parser.Azure_types
open Parser.Network_types
open Parser.Tf_types
type t

val get_name : t -> string

val get_address : t -> string

val get_id : t -> IdKey.t

val make : name:string -> subscription:string -> address:string -> resource_group:Rg.t -> location:azure_location -> allocation:public_ip_assignment -> t

val show : t -> string

val pp : Format.formatter -> t -> unit

val show_pip_map : t AddressMap.t -> string