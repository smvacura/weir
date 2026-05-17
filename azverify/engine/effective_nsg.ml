open Terraform_ir.Nsg
open Parser.Network_types

type t = { rules : SecurityRule.t list}

let get_effective_rules ensg = ensg.rules

let make_exact_cidr ip mask =
  CIDR.make 
  (Option.get (IPv4.of_string_opt ip))
  (Option.get (IPv4Mask.of_string_opt mask))


let internet_default_rules = [
  SecurityRule.make
    ~name:"AllowInternetInbound"
    ~description:(Some "Default system route to allow outbound internet")
    ~protocol:Any
    ~source_ports:[Any]
    ~destination_ports:[Any]
    ~source:(SecurityRule.Addresses [make_exact_cidr "0.0.0.0" "0"])
    ~destination:SecurityRule.Any
    ~access:SecurityRule.Allow
    ~priority:65001
    ~direction:SecurityRule.Outbound
]

let enrich_nsg nsg_opt = 
  match nsg_opt with
  | Some nsg -> { rules = get_rules nsg}
  | None -> { rules = []}