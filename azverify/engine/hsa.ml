type node = { ip_range: Parser.Network_types.CIDR.t; attached: string }
type edge = |
type header_space = |

type node_id = int
type resource_address = string

type hsa_graph = (node_id, node * edge list) Hashtbl.t

type node_index = (resource_address, node_id) Hashtbl.t

let add_node address ip_range attached hsa_graph node_index =
  let id = Hashtbl.length hsa_graph in
  let node = { ip_range; attached } in
  Hashtbl.add node_index address id;
  Hashtbl.add hsa_graph id (node, [])

let get_subnets vnet subnets =
  let rec aux subnets acc =
    match subnets with
    | [] -> acc
    | h::t -> if Terraform_ir.Subnet.get_vnet h = vnet
              then aux t (h::acc)
              else aux t acc
  in
  aux subnets []


let get_route_nodes route_map =
  ""


let get_sorted_routes route_table : Terraform_ir.Route_table.Route.t list = []

let add_edge subnet_address route_table node_index hsa_graph = 
  let id = match Hashtbl.find_opt node_index subnet_address with
  | Some i -> i
  | None -> -1
  in
  match Hashtbl.find_opt hsa_graph id with
  (* TODO: construct edge from route_table and prepend *)
  | Some (node, edges) -> Hashtbl.replace hsa_graph id (node, edges)
  | None -> ()