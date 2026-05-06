open Terraform_ir

type route_map = (Route_table.Route.t, (int32 * int32) list) Hashtbl.t

val partition_routes : Route_table.t -> route_map