open Hsa
open Encoder

type packet_examples =
  | Single     of packet_header * int
  | Sample     of packet_header list * int
  | Exhaustive of packet_header list

type packet_diff = {
  src         : resource_address;
  dst         : resource_address;
  added       : packet_examples option;
  removed     : packet_examples option;
  num_added   : float;
  num_removed : float;
}

val compute : Terraform_ir.World.t -> Terraform_ir.World.t -> packet_diff list
