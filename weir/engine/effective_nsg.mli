open Terraform_ir

type t

val get_effective_rules : t -> Nsg.SecurityRule.t list

val enrich_nsg : Nsg.t option -> Vnet.t option -> Route_table.t -> Utils.peering_index -> Utils.asg_index -> t