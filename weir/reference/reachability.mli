open Terraform_ir

(* A concrete forwarding graph built once from a world. Build it once, then
   answer many packets against it ([reachable_in]) — the intended use is
   sampling a stream of packets out of an HSA result. *)
type graph

val build_graph : World.t -> graph

(* Does this single concrete packet, originating in subnet [src], get delivered
   to the subnet that owns its [dest_ip], passing every NSG it crosses?

   Forwarding is deterministic, as on Azure: at each hop the destination —
   including a same-subnet destination, which gets no special treatment — is
   matched against that subnet's effective routes by longest-prefix match. A
   VirtualNetwork next hop delivers, to whichever subnet of the VNet owns the
   destination (possibly [src] itself). A VirtualAppliance next hop hands the
   packet to the appliance's NIC and re-routes from the subnet hosting it,
   provided that NIC has ip_forwarding_enabled; otherwise the packet dies there.
   The walk stops at a repeated node, which is a routing loop. Every hop scans
   the outbound NSG of the sender and the inbound NSG of the receiver in
   priority order. This is the brute-force counterpart to the symbolic engine:
   one packet, one path, no header-space algebra. *)
val reachable_in : graph -> src:string -> Packet.t -> bool

val reachable : World.t -> src:string -> Packet.t -> bool
