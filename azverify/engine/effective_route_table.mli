open Terraform_ir

type t

val get_routes : t -> Route_table.Route.t list

val enrich_route_table : Route_table.t -> Vnet.t -> Utils.subnet_index -> t
