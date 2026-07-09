open Parser.Azure_types
open Parser.Network_types
open Parser.Tf_types

module SecurityRule : sig
  
  type t

  val compare : t -> t -> int

  type endpoint =
  | Addresses of CIDR.t list
  | ApplicationGroups of string list
  | ServiceTags of string list
  | Any
  [@@deriving show]

  val endpoint_of_list_opt : string option list -> string -> endpoint option

  type access = 
  | Allow
  | Deny
  [@@deriving show]

  val access_of_string_opt : string -> access option

  type direction = 
  | Inbound
  | Outbound
  [@@deriving show]

  val direction_of_string_opt : string -> direction option

  val make : name:string -> description:string option -> protocol:protocol -> source_ports:port list -> destination_ports:port list -> source:endpoint -> destination:endpoint -> access:access -> priority:int -> direction:direction -> t

  val get_protocol : t -> protocol

  val get_src_ip : t -> endpoint

  val get_dest_ip : t -> endpoint

  val get_src_ports : t -> port list

  val get_dest_ports : t -> port list 

  val get_access : t -> access

  val get_direction : t -> direction

  val map_endpoints : (endpoint -> endpoint) -> t -> t

end

type t

val make : name:string -> subscription:string -> address:string -> location:azure_location -> resource_group:Rg.t -> rule_list:SecurityRule.t list -> tags:tag list -> t

val get_id : t -> IdKey.t

val get_name : t -> string

val get_address : t -> string

val get_rules : t -> SecurityRule.t list

val show : t -> string

val show_nsg_map : t AddressMap.t -> string