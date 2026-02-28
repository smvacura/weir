open Parser.Azure_types
open Parser.Network_types

module Id : sig
    type t

    val compare : t -> t -> int

    val of_strings : string -> string -> string -> t

    val to_strings : t -> (string * string * string)

end

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
  | Incoming
  | Outgoing
  [@@deriving show]

  val direction_of_string_opt : string -> direction option

  val make : name:string -> description:string option -> protocol:protocol -> source_ports:port list -> destination_ports:port list -> source:endpoint -> destination:endpoint -> access:access -> priority:int -> direction:direction -> t

end

type t

val make : name:string -> subscription:string -> address:string -> location:azure_location -> resource_group:Rg.t -> rule_list:SecurityRule.t list -> tags:tag list -> t

val get_id : t -> Id.t

val show : t -> string

module Map : Map.S with type key = Id.t 

val show_nsg_map : t Map.t -> string