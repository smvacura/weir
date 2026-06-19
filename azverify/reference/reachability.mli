open Terraform_ir

(* A concrete forwarding graph built once from a world. Build it once, then
   answer many packets against it ([reachable_in]) — the intended use is
   sampling a stream of packets out of an HSA result. *)
type graph

val build_graph : World.t -> graph

(* Does this single concrete packet, originating in subnet [src], get delivered
   to the subnet that owns its [dest_ip], passing every NSG it crosses?

   Forwarding is deterministic and single-step, as on Azure: the destination —
   including a same-subnet destination, which gets no special treatment — is
   matched against the source subnet's effective routes by longest-prefix
   match, and only a VirtualNetwork next hop delivers, to whichever subnet of
   the VNet owns the destination (possibly [src] itself). The outbound NSG of
   the source and the inbound NSG of the owner are scanned in priority order.
   This is the brute-force counterpart to the symbolic engine: one packet, one
   LPM decision, no header-space algebra. *)
val reachable_in : graph -> src:string -> Packet.t -> bool

val reachable : World.t -> src:string -> Packet.t -> bool
