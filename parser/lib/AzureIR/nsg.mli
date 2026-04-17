open Parser.Azure_types
open Parser.Network_types
open Parser.Tf_types

module SecurityRule : sig
  
  type t

  type endpoint = 
  | Addresses of CIDR.t list
  | ApplicationGroups of string list
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

end

type t

val make : name:string -> subscription:string -> address:string -> location:azure_location -> resource_group:Rg.t -> rule_list:SecurityRule.t list -> tags:tag list -> t

val get_id : t -> IdKey.t

val get_name : t -> string

val get_address : t -> string

val show : t -> string

val show_nsg_map : t AddressMap.t -> string