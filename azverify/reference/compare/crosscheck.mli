open Terraform_ir

(* Cross-checks the independent ground truth (Reference.Reachability) against the
   HSA/BDD engine. The engine is treated as an opaque oracle-under-test: we read
   its reachability BDDs and ask whether a concrete packet is in them. No engine
   semantics flow back into the ground truth. *)

type verdict = {
  src          : string;
  dst          : string;
  packet       : Reference.Packet.t;
  ground_truth : bool;          (* Reference.Reachability *)
  engine       : bool;          (* membership in the engine's src->dst BDD *)
}

(* Run both oracles on each supplied concrete packet. src and dst are the subnets
   owning src_ip and dest_ip; packets whose endpoints are in no subnet are
   dropped from the result. *)
val compare_packets : World.t -> Reference.Packet.t list -> verdict list

(* A representative TCP/443 packet for every ordered pair of subnets (host .4 of
   each), for a deterministic cross-check that doesn't depend on the engine's
   witness picker. *)
val sample_pairwise : World.t -> Reference.Packet.t list

(* Sample one witness packet from every (src<>dst) pair the engine reports
   reachable, then run both oracles on it — the "sample from an HSA run" check. *)
val compare_engine_witnesses : World.t -> verdict list

val disagreements : verdict list -> verdict list

val show_verdict : verdict -> string
