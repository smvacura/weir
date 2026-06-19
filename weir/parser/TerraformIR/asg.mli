open Parser.Azure_types
open Parser.Tf_types

type t

val make :
  name:string ->
  subscription:string ->
  address:string ->
  location:azure_location ->
  resource_group:Rg.t ->
  tags:tag list ->
  t

val get_name : t -> string

val get_address : t -> string

val get_id : t -> IdKey.t

val show : t -> string

val pp : Format.formatter -> t -> unit

val show_asg_map : t AddressMap.t -> string
