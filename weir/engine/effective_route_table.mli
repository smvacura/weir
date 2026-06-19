open Terraform_ir

type t

val get_effective_routes : t -> Route_table.Route.t list

val enrich_route_table : Route_table.t -> Vnet.t -> Utils.peering_index -> t
