type node
type edge

type hsa_graph

type resource_address = string

type analysis_result

type build_timing = {
  association_build_ms : float;
  node_addition_ms     : float;
  edge_addition_ms     : float;
  total_build_ms       : float;
}

type analyze_timing = {
  build         : build_timing;
  fixpoint_ms   : float;
  total_ms      : float;
  node_count    : int;
  edge_count    : int;
}

val build_graph : Terraform_ir.World.t -> Bdd.manager -> hsa_graph * build_timing

val node_count : hsa_graph -> int

val has_edge_between : hsa_graph -> resource_address -> resource_address -> bool

val get_decider : hsa_graph -> resource_address -> resource_address -> Bdd.bdd option

val reachable_packet_count : Terraform_ir.World.t -> resource_address -> resource_address -> float

val run_analysis_timed : Terraform_ir.World.t -> analyze_timing

val analyze : Bdd.manager -> Terraform_ir.World.t -> analysis_result

val reachable_pairs : analysis_result -> (resource_address * resource_address) list

val get_bdd : analysis_result -> resource_address -> resource_address -> Bdd.bdd option

val pick_packet_opt : resource_address -> resource_address -> analysis_result -> Encoder.packet_header option
