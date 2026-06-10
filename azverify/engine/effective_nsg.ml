open Terraform_ir.Nsg
open Parser.Network_types

type t = { rules : SecurityRule.t list}

let get_effective_rules ensg = ensg.rules

let make_exact_cidr ip mask =
  CIDR.make 
  (Option.get (IPv4.of_string_opt ip))
  (Option.get (IPv4Mask.of_string_opt mask))


let vnetlocal_default_rules vnet rt = [
    SecurityRule.make
    ~name:"AllowVNetInBound"
    ~description:(Some "Allow all 'Vnet' traffic")
    ~protocol:Any
    ~source_ports:[Any]
    ~destination_ports:[Any]
    ~source:(SecurityRule.Addresses 
      ((Terraform_ir.Vnet.get_addresses vnet) @ (Terraform_ir.Route_table.get_all_route_prefixes rt))
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
      ((Terraform_ir.Vnet.get_addresses vnet) @ (Terraform_ir.Route_table.get_all_route_prefixes rt))
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

let enrich_nsg nsg_opt vnet_opt rt =
  let vnetlocal = match vnet_opt with
    | Some vnet -> vnetlocal_default_rules vnet rt
    | None -> []
  in
  let default_rules = vnetlocal @ internet_default_rules @ deny_default_rules in
  match nsg_opt with
  | Some nsg -> { rules = (get_rules nsg) @ default_rules}
  | None -> { rules = []}