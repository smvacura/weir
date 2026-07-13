open Terraform_ir.Nsg
open Parser.Network_types
open Parser.Azure_types
open Utils

type t = { rules : SecurityRule.t list}

let empty = { rules = [] }

let get_effective_rules ensg = ensg.rules

let make_exact_cidr ip mask =
  CIDR.make 
  (Option.get (IPv4.of_string_opt ip))
  (Option.get (IPv4Mask.of_string_opt mask))


let vnetlocal_default_rules vnet rt peering_idx = 
  let peered_cidrs = match VnetMap.find_opt vnet peering_idx with
  | Some entries -> List.filter_map (fun (cidr, allowed) -> if allowed then Some cidr else None) entries
  | None -> []
  in
  [
    SecurityRule.make
    ~name:"AllowVNetInBound"
    ~description:(Some "Allow all 'Vnet' traffic")
    ~protocol:Any
    ~source_ports:[Any]
    ~destination_ports:[Any]
    ~source:(SecurityRule.Addresses 
      ((Terraform_ir.Vnet.get_addresses vnet) @ (Terraform_ir.Route_table.get_all_route_prefixes rt) @ peered_cidrs)
    )
    ~destination:SecurityRule.Any
    ~access:SecurityRule.Allow
    ~priority:65000
    ~direction:SecurityRule.Inbound;
    SecurityRule.make
    ~name:"AllowVNetOutbound"
    ~description:(Some "Allow all 'Vnet' traffic")
    ~protocol:Any
    ~source_ports:[Any]
    ~destination_ports:[Any]
    ~source:(SecurityRule.Addresses 
      ((Terraform_ir.Vnet.get_addresses vnet) @ (Terraform_ir.Route_table.get_all_route_prefixes rt) @ peered_cidrs)
    )
    ~destination:SecurityRule.Any
    ~access:SecurityRule.Allow
    ~priority:65000
    ~direction:SecurityRule.Outbound;
]

let internet_default_rules = []


let deny_default_rules = [
  SecurityRule.make
    ~name:"DenyAllOutbound"
    ~description:(Some "Default catch-all system route to deny outbound packets")
    ~protocol:Any
    ~source_ports:[Any]
    ~destination_ports:[Any]
    ~source:(SecurityRule.Addresses [make_exact_cidr "0.0.0.0" "0"])
    ~destination:SecurityRule.Any
    ~access:SecurityRule.Deny
    ~priority:65500
    ~direction:SecurityRule.Outbound;
  SecurityRule.make
    ~name:"DenyAllInbound"
    ~description:(Some "Default catch-all system route to deny inbound packets")
    ~protocol:Any
    ~source_ports:[Any]
    ~destination_ports:[Any]
    ~source:(SecurityRule.Addresses [make_exact_cidr "0.0.0.0" "0"])
    ~destination:SecurityRule.Any
    ~access:SecurityRule.Deny
    ~priority:65500
    ~direction:SecurityRule.Inbound
]

let resolve_endpoint asg_idx = function
  | SecurityRule.ApplicationGroups asgs ->
    let cidrs = List.concat_map (fun asg ->
      Option.value ~default:[] (Parser.Tf_types.AddressMap.find_opt asg asg_idx)
    ) asgs in
    SecurityRule.Addresses cidrs
  | ep -> ep

let resolve_asg asg_idx rule =
  SecurityRule.map_endpoints (resolve_endpoint asg_idx) rule

let enrich_nsg nsg_opt vnet_opt rt peering_idx asg_idx =
  let vnetlocal = match vnet_opt with
    | Some vnet -> vnetlocal_default_rules vnet rt peering_idx
    | None -> []
  in
  let default_rules = vnetlocal @ internet_default_rules @ deny_default_rules in
  match nsg_opt with
  | Some nsg -> { rules = List.map (resolve_asg asg_idx) (get_rules nsg) @ default_rules }
  | None -> { rules = [] }