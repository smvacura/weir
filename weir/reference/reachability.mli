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
   VirtualNetwork next hop delivers, to whichever subnet owns the destination:
   one in this VNet (possibly [src] itself), or one in a VNet peered to it with
   virtual network access allowed. A VirtualAppliance next hop hands the packet
   to the appliance's NIC and re-routes from the subnet hosting it, provided the
   NIC is reachable from this VNet and has ip_forwarding_enabled; otherwise the
   packet dies there. The walk stops at a repeated node, which is a routing
   loop.

   Every hop scans the outbound NSGs of the sender and the inbound NSGs of the
   receiver in priority order, subnet NSG and NIC NSG together — both must
   permit. Rules naming the VirtualNetwork, Internet or AzureLoadBalancer
   service tags are resolved, as are Application Security Group endpoints, from
   the members' own addresses. Azure's default rules decide when no user rule
   matches.

   This is the brute-force counterpart to the symbolic engine: one packet, one
   path, no header-space algebra. *)
val reachable_in : graph -> src:string -> Packet.t -> bool

val reachable : World.t -> src:string -> Packet.t -> bool
