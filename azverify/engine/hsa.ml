open Terraform_ir
open Parser.Network_types

type node_id = int
type resource_address = string

type node = { ip_range: Parser.Network_types.CIDR.t; attached: resource_address }
type edge = { decider: Bdd.bdd; src: node_id; dest: node_id }

type adjacency = (node_id, edge list) Hashtbl.t

type node_index = (resource_address, node_id) Hashtbl.t

type hsa_graph = {
  nodes : (node_id, node) Hashtbl.t;
  in_list : adjacency;
  out_list: adjacency;
  addr_index: node_index;
  next_id: int ref
}

let add_node address ip_range hsa_graph =
  let id = !(hsa_graph.next_id) in
  let node = { ip_range; attached = address } in
  Hashtbl.replace hsa_graph.addr_index address id;
  Hashtbl.replace hsa_graph.nodes id node;
  hsa_graph.next_id := id + 1;
  id

let get_subnets vnet subnets =
  let rec aux subnets acc =
    match subnets with
    | [] -> acc
    | h::t -> if Terraform_ir.Subnet.get_vnet h = vnet
              then aux t (h::acc)
              else aux t acc
  in
  aux subnets []


let nsg_to_bdd (nsg : Nsg.t) (man : Bdd.manager) = Bdd.dtrue man

let cidr_block_to_bdd (cidr : CIDR.t) (man : Bdd.manager) = Bdd.dtrue man

let cidr_blocks_to_bdd (cidrs : CIDR.t list) (man : Bdd.manager) = 
  let rec aux ell acc = 
    match ell with
    | [] -> acc
    | h::t -> aux t (Bdd.dor man (cidr_block_to_bdd h man) acc)
  in
  aux cidrs (Bdd.dfalse man)


let add_edge src dest nsg_1 nsg_2 route_cidrs hsa_graph man = 
  let nsg_1_bdd = match nsg_1 with
  | Some nsg -> nsg_to_bdd nsg man
  | None -> Bdd.dtrue man
  in
  let nsg_2_bdd = match nsg_2 with
  | Some nsg -> nsg_to_bdd nsg man
  | None -> Bdd.dtrue man
  in
  let route_bdd = cidr_blocks_to_bdd route_cidrs man in
  let decider = Bdd.dand man (Bdd.dand man nsg_1_bdd nsg_2_bdd) route_bdd in
  let edge = { decider; src; dest; } in
  let push tbl k v =
    Hashtbl.replace tbl k (v :: Hashtbl.find tbl k)
  in
  push hsa_graph.in_list dest edge;
  push hsa_graph.in_list dest edge;
