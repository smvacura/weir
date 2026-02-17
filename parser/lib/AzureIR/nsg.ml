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

module Map = Map.Make(Id)