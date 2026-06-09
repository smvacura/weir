open Parser.Azure_types
open Parser.Network_types
open Parser.Tf_types

module SecurityRule = struct


  type endpoint = 
  | Addresses of CIDR.t list
  | ApplicationGroups of string list
  | ServiceTags of string list
  | Any
  [@@deriving show]

  (* A service tag (e.g. "Internet", "VirtualNetwork") arrives in the same field
     as CIDRs. Terraform has already validated the value, so any prefix that is
     neither "*" nor a CIDR is a tag. A None element is a missing value: fail. *)
  let service_tags_of_string_list_opt list =
    if List.exists Option.is_none list
    then None
    else Some (ServiceTags (List.filter_map Fun.id list))

  let addresses_of_string_list_opt list =
    if List.mem (Some "*") list
    then Some Any
    else
      match CIDR.of_list_opt_strict list with
      | Some l -> Some (Addresses l)
      | None -> service_tags_of_string_list_opt list

  let endpoint_of_list_opt list kind = 
    match kind with
    | "application" -> 
      if (List.length (List.filter (Option.is_none) list) > 0) 
      then None
      else Some (ApplicationGroups (List.map (Option.value ~default:"") list))
    | "addresses" -> addresses_of_string_list_opt list
    | _ -> None

  type access = 
  | Allow
  | Deny
  [@@deriving show]

  let access_of_string_opt str =
    match str with
    | "Allow" -> Some Allow
    | "Deny" -> Some Deny
    | _ -> None

  type direction = 
  | Inbound
  | Outbound
  [@@deriving show]

  let direction_of_string_opt str = 
    match str with 
    | "Inbound" -> Some Inbound
    | "Outbound" -> Some Outbound
    | _ -> None
  
  type t = {
    name : string;
    description : string option;
    protocol : protocol;
    source_ports : port list;
    destination_ports : port list;
    source : endpoint;
    destination : endpoint;
    access : access;
    priority : int;
    direction : direction;
  } [@@deriving show]

  let compare r1 r2 = compare r1.priority r2.priority

  let make ~name ~description ~protocol ~source_ports ~destination_ports ~source ~destination ~access ~priority ~direction =
    {
      name;
      description;
      protocol;
      source_ports;
      destination_ports;
      source;
      destination;
      access;
      priority;
      direction;
    } 

  let get_protocol rule = rule.protocol

  let get_src_ip rule = rule.source

  let get_dest_ip rule = rule.destination

  let get_src_ports rule = rule.source_ports

  let get_dest_ports rule = rule.destination_ports

  let get_access rule = rule.access

  let get_direction rule = rule.direction

end

type t = {
    name : string;
    subscription : string;
    address : string;
    location : azure_location;
    resource_group : Rg.t;
    rule_list : SecurityRule.t list;
    tags : tag list;
  }

let make ~name ~subscription ~address ~location ~resource_group ~rule_list ~tags = {
  name;
  subscription;
  address;
  location;
  resource_group;
  rule_list;
  tags
}

let get_id nsg   = 
  IdKey.of_strings nsg.subscription (Rg.get_name nsg.resource_group) nsg.name

let get_name nsg = nsg.name

let get_address nsg = nsg.address

let get_rules nsg = nsg.rule_list

let show { name; subscription; address; location; resource_group; rule_list; tags; } = 
Printf.sprintf 
  "{ name = %s; subscription = %s; address = %s; location = %s; resource_group = %s; rule_list = %s tags = %s}"
  name 
  subscription 
  address 
  (string_of_loc location) 
  (Rg.get_name resource_group) 
  (Printf.sprintf "[%s]" (String.concat "; " (List.map SecurityRule.show rule_list))) 
  ""

let show_nsg_map m =
  "{" ^
  (m
  |> AddressMap.bindings
  |> List.map (fun (addr, nsg) -> addr ^ ":" ^ show nsg)
  |> String.concat ",")
  ^ "}"