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
    private_address_allocation: private_ip_assignment;
    primary: bool option
  } [@@deriving show]

  let make ~name:name ~subscription:subscription ~subnet:subnet ~ip_address_version:ip_address_version ~pip:pip ~private_address_allocation:private_address_allocation ~primary:primary =
    {name; subscription; subnet; ip_address_version; pip; private_address_allocation; primary}
  
  let get_name ipconfig = ipconfig.name

  let get_private_ip ipconfig =
    match ipconfig.private_address_allocation with
    | Static ip -> Some ip
    | _ -> None

  let get_subnet_cidr_block subnet_resolvable =
    match subnet_resolvable with 
    | Resolved subnet -> Some (Subnet.get_cidrs subnet)
    | _ -> None

  let get_private_cidr ipconfig = 
    match ipconfig.private_address_allocation with
    | Dynamic -> get_subnet_cidr_block ipconfig.subnet
    | _ -> None

  let unresolved_fields r =
    List.filter_map Fun.id [
      (match r.subnet with Unresolved -> Some "subnet_id" | _ -> None);
      (match r.pip with Unresolved -> Some "public_ip_address_id" | _ -> None);
    ]

  let resolve ipconfig ~subnet ?(pip=None) =
    {ipconfig with subnet = Resolved subnet; pip = Resolved pip}


  let get_subnet ipconfig =
    match ipconfig.subnet with
    | Resolved subnet -> Some subnet
    | _ -> None

  let resolve_subnet subnet' ip_config = { ip_config with subnet = Resolved subnet' }
end

type t = {
  name : string;
  subscription : string;
  address : string;
  location : azure_location;
  resource_group : Rg.t;
  ip_forwarding_enabled : bool;
  ip_configurations : IpConfiguration.t list;
} [@@deriving show]

let get_name nic = nic.name

let get_address nic = nic.address

let get_ipconfigs nic = nic.ip_configurations

let get_rg nic = nic.resource_group

let get_ip_forwarding_enabled nic = nic.ip_forwarding_enabled

let make ~name:name ~subscription:subscription ~address:address ~location:location ~resource_group:resource_group ~ip_forwarding_enabled:ip_forwarding_enabled ~ip_configurations:ip_configurations =
  {name; subscription; address; location; resource_group; ip_forwarding_enabled; ip_configurations}

let resolve_ipconfigs nic ipconfigs' = {nic with ip_configurations = ipconfigs'}

let get_id nic : IdKey.t =  
  IdKey.of_strings nic.subscription (Rg.get_name nic.resource_group) nic.name


let show_nic_map m =
  "{" ^
  (m
  |> AddressMap.bindings
  |> List.map (fun (addr, nic) -> addr ^ ":" ^ show nic)
  |> String.concat ",")
  ^ "}"

let show_nic_ip_map m =
  "{" ^
  (m
  |> IPMap.bindings
  |> List.map (fun (ip, nic) -> (IPv4.show ip) ^ ":" ^ show nic)
  |> String.concat ",")
  ^ "}"

let show_nic_cidr_map m =
  "{" ^
  (m
  |> CIDRMap.bindings
  |> List.map (fun (cidr, nic) -> (CIDR.show cidr) ^ ":" ^ show nic)
  |> String.concat ",")
  ^ "}"