open Parser.Azure_types
open Parser.Network_types

module Id = struct
  
  type t = string * string * string

  let compare = compare

  let of_strings sub rg name : t = (sub, rg, name)

  let to_strings ((sub, rg, name) : t )  = (sub, rg, name)
end

module SecurityRule = struct


  type endpoint = 
  | Addresses of CIDR.t list
  | ApplicationGroups of string list
  | Any
  [@@deriving show]

  let addresses_of_string_list_opt list = 
    if List.mem (Some "*") list
    then Some Any
    else 
      match CIDR.of_list_opt_strict list with
      | Some l -> Some (Addresses l)
      | None -> None

  let endpoint_of_list_opt list name_this = 
    match name_this with
    | "application" -> 
      if (List.length (List.filter (Option.is_none) list) > 0) 
      then None
      else Some (ApplicationGroups (List.map (Option.value ~default:"") list))
    | "addresses" -> addresses_of_string_list_opt list

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
  | Incoming
  | Outgoing
  [@@deriving show]

  let direction_of_string_otp str = 
    match str with 
    | "Incoming" -> Some Incoming
    | "Outgoing" -> Some Outgoing
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

let get_id nsg : Id.t  = 
  (nsg.subscription, (Rg.get_name (nsg.resource_group)), nsg.name)


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

module Map = Map.Make(Id)

let show_nsg_map m =
  "{" ^ 
  (m
  |> Map.bindings
  |> List.map (fun ((sub, rg, name),v) -> sub ^ rg ^ name ^ ":" ^ show v)
  |> String.concat ",")
  ^
  "}"