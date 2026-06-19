open Parser.Azure_types
open Parser.Tf_types

type t = {
  name : string;
  subscription : string;
  address : string;
  resource_group : Rg.t;
  local_vnet : Vnet.t resolvable;
  remote_vnet : Vnet.t resolvable;
  allow_virtual_network_access : bool option;
  allow_forwarded_traffic : bool option;
  allow_gateway_transit : bool option;
  use_remote_gateways : bool option;
  local_subnet_names : string list option;
  remote_subnet_names : string list option;
  peer_complete_virtual_networks_enabled : bool option;
}

let get_name p = p.name

let get_address p = p.address

let get_rg p = p.resource_group

let get_id p =
  IdKey.of_strings p.subscription (Rg.get_name p.resource_group) p.name

let get_local_vnet p = p.local_vnet

let get_remote_vnet p = p.remote_vnet

let get_allow_virtual_network_access p = p.allow_virtual_network_access

let get_allow_forwarded_traffic p = p.allow_forwarded_traffic

let get_allow_gateway_transit p = p.allow_gateway_transit

let get_use_remote_gateways p = p.use_remote_gateways

let get_local_subnet_names p = p.local_subnet_names

let get_remote_subnet_names p = p.remote_subnet_names

let get_peer_complete_virtual_networks_enabled p =
  p.peer_complete_virtual_networks_enabled

let resolve_local_vnet vnet p = { p with local_vnet = Resolved vnet }

let resolve_remote_vnet vnet p = { p with remote_vnet = Resolved vnet }

let make ~name ~subscription ~address ~resource_group ~local_vnet ~remote_vnet
    ~allow_virtual_network_access ~allow_forwarded_traffic
    ~allow_gateway_transit ~use_remote_gateways
    ~local_subnet_names ~remote_subnet_names
    ~peer_complete_virtual_networks_enabled =
  { name; subscription; address; resource_group; local_vnet; remote_vnet;
    allow_virtual_network_access; allow_forwarded_traffic;
    allow_gateway_transit; use_remote_gateways;
    local_subnet_names; remote_subnet_names;
    peer_complete_virtual_networks_enabled }

let compare = compare

let show_vnet_resolvable = function
  | Unresolved -> "Unresolved"
  | Resolved v -> Vnet.get_name v

let show_bool_opt = function
  | None -> "None"
  | Some b -> string_of_bool b

let show_subnet_names_opt = function
  | None -> "None"
  | Some names -> "[" ^ String.concat "," names ^ "]"

let show p =
  Printf.sprintf
    "{ name = %s; subscription = %s; rg = %s; local_vnet = %s; remote_vnet = %s; \
     allow_access = %s; allow_forwarded = %s; allow_gateway = %s; \
     use_remote_gw = %s; local_subnets = %s; remote_subnets = %s; complete = %s }"
    p.name p.subscription (Rg.get_name p.resource_group)
    (show_vnet_resolvable p.local_vnet)
    (show_vnet_resolvable p.remote_vnet)
    (show_bool_opt p.allow_virtual_network_access)
    (show_bool_opt p.allow_forwarded_traffic)
    (show_bool_opt p.allow_gateway_transit)
    (show_bool_opt p.use_remote_gateways)
    (show_subnet_names_opt p.local_subnet_names)
    (show_subnet_names_opt p.remote_subnet_names)
    (show_bool_opt p.peer_complete_virtual_networks_enabled)

let pp fmt p = Format.fprintf fmt "%s" (show p)

let show_peering_map m =
  "{" ^
  (m
  |> AddressMap.bindings
  |> List.map (fun (addr, p) -> addr ^ ":" ^ show p)
  |> String.concat ",")
  ^ "}"
