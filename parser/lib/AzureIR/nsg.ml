open Parser.Azure_types

module Id = struct
  
  type t = string * string * string

  let compare = compare

  let of_strings sub rg name : t = (sub, rg, name)

  let to_strings ((sub, rg, name) : t )  = (sub, rg, name)
end

module SecurityRule = struct
  
  type t = {
    name: string;
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