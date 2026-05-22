type node
type edge

type hsa_graph

type resource_address = string

val build_graph : Terraform_ir.World.t -> Bdd.manager -> hsa_graph

val node_count : hsa_graph -> int

val has_edge_between : hsa_graph -> resource_address -> resource_address -> bool

val get_decider : hsa_graph -> resource_address -> resource_address -> Bdd.bdd option
