open Parser.Azure_types
open Parser.Network_types

module Id = struct
  
  type t = string * string * string

  let compare = compare

  let of_strings sub rg name : t = (sub, rg, name)

  let to_strings ((sub, rg, name) : t )  = (sub, rg, name)
end

module SecurityRule = struct
  
  type t = {
    name : string;
    description : string option;
    protocol : protocol;
    source_ports : port list;
    destination_ports : port list;
    source : [ `Addresses of CIDR.t list | `ApplicationGroups of string list ];
    destination : [ `Addresses of CIDR.t list | `ApplicationGroups of string list ];
    access : [ `Allow | `Deny ];
    priority : int;
    direction : [ `Incoming | `Outgoing ];
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

let make name subscription address location resource_group rule_list tags = {
  name = name;
  subscription = subscription;
  address = address;
  location = location;
  resource_group = resource_group;
  rule_list = rule_list;
  tags = tags
}

let get_id nsg : Id.t  = 
  (nsg.subscription, (Rg.get_name (nsg.resource_group)), nsg.name)


let show { name; subscription; address; location; resource_group; rule_list; tags; } = 
Printf.sprintf 
  "{ name = %s; subscription = %s; address = %s; location = %s; resource_group = %s; rule_list = %s tags = %s}"
  name subscription address  (string_of_loc location) (Rg.get_name resource_group) "" ""

module Map = Map.Make(Id)

let show_nsg_map m =
  "{" ^ 
  (m
  |> Map.bindings
  |> List.map (fun ((sub, rg, name),v) -> sub ^ rg ^ name ^ ":" ^ show v)
  |> String.concat ",")
  ^
  "}"