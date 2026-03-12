open Parser.Azure_types
open Parser.Network_types

module Id = struct
  
  type t = string * string * string

  let compare = compare

  let of_strings sub rg name : t = (sub, rg, name)

  let to_strings ((sub, rg, name) : t )  = (sub, rg, name)
end


module IpConfiguration = struct
  
  type t = {
    name: string;
    subscription: string;
    subnet: Subnet.t;
    ip_address_version: [`Ipv4 | `Ipv6];
    pip: Pip.t option;
    private_address_allocation: ip_assignment;
    primary: bool;
  } [@@deriving show]

  let make name subscription subnet ip_address_version pip private_address_allocation primary =
    {name; subscription; subnet; ip_address_version; pip; private_address_allocation; primary}
end

type t = {
  name : string;
  subscription : string;
  location : string;
  resource_group : Rg.t;
  ip_configurations : IpConfiguration.t list
} [@@deriving show]

let get_name nic = nic.name

let get_name_string nic = nic.name

let get_name_string nic = nic.name

let get_rg nic = nic.resource_group

let make_nic name subscription location resource_group ip_configurations =
  {name; subscription; location; resource_group; ip_configurations}

let get_id nic : Id.t =  
  (nic.subscription, Rg.get_name (nic.resource_group), nic.name)


module Map = Map.Make(Id)

let show_nic_map m =
  "{" ^ 
  (m
  |> Map.bindings
  |> List.map (fun ((sub, rg, name), nic) -> sub ^ rg ^ name ^ ":" ^ show nic)
  |> String.concat ",")
  ^
  "}"