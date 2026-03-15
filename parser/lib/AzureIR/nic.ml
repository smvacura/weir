open Parser.Azure_types
open Parser.Network_types
open Parser.Tf_types


module IpConfiguration = struct
  
  type t = {
    name: string;
    subscription: string;
    subnet: Subnet.t resolvable;
    ip_address_version: ip_type;
    pip: Pip.t option resolvable;
    private_address_allocation: ip_assignment resolvable;
    primary: bool resolvable;
  } [@@deriving show]

  let make ~name:name ~subscription:subscription ~subnet:subnet ~ip_address_version:ip_address_version ~pip:pip ~private_address_allocation:private_address_allocation ~primary:primary =
    {name; subscription; subnet; ip_address_version; pip; private_address_allocation; primary}
end

type t = {
  name : string;
  subscription : string;
  address : string;
  location : azure_location;
  resource_group : Rg.t;
  ip_configurations : IpConfiguration.t list
} [@@deriving show]

let get_name nic = nic.name

let get_address nic = nic.address

let get_rg nic = nic.resource_group

let make ~name:name ~subscription:subscription ~address:address ~location:location ~resource_group:resource_group ~ip_configurations:ip_configurations =
  {name; subscription; address; location; resource_group; ip_configurations}

let get_id nic : IdKey.t =  
  IdKey.of_strings nic.subscription (Rg.get_name nic.resource_group) nic.name


let show_nic_map m =
  "{" ^ 
  (m
  |> IdKeyMap.bindings
  |> List.map (fun (id, nic) -> (IdKey.show id) ^ ":" ^ show nic)
  |> String.concat ",")
  ^
  "}"