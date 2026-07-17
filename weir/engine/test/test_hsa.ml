open OUnit2
open Parser.Network_types
open Parser.Azure_types
open Parser.Tf_types
open Terraform_ir
open Pathfinder.Hsa
open Pathfinder.Bdd

(* --- Fixtures --- *)

let test_rg =
  Rg.make
    ~name:"test-rg"
    ~subscription:"DEFAULT"
    ~address:"azurerm_resource_group.test"
    ~location:EastUs
    ~managed_by:None
    ~tags:[]

let cidr s = Option.get (CIDR.of_string_opt s)

let make_vnet ?(addresses = []) name =
  Vnet.make
    ~name
    ~subscription:"DEFAULT"
    ~address:("azurerm_virtual_network." ^ name)
    ~location:EastUs
    ~resource_group:test_rg
    ~addresses

let make_subnet vnet name cidr_str =
  Subnet.make
    ~name
    ~subscription:"DEFAULT"
    ~address:("azurerm_subnet." ^ name)
    ~resource_group:test_rg
    ~vnet
    ~addresses:[cidr cidr_str]

let make_ipconfig name subnet ip_str =
  Nic.IpConfiguration.make
    ~name
    ~subscription:"DEFAULT"
    ~subnet:(Resolved subnet)
    ~ip_address_version:IPv4
    ~pip:(Resolved None)
    ~private_address_allocation:(Static (Option.get (IPv4.of_string_opt ip_str)))
    ~primary:(Some true)

let make_nic name subnet ip_str =
  Nic.make
    ~name
    ~subscription:"DEFAULT"
    ~address:("azurerm_network_interface." ^ name)
    ~location:EastUs
    ~resource_group:test_rg
    ~ip_forwarding_enabled:false
    ~ip_configurations:[make_ipconfig "ipconfig1" subnet ip_str]

let allow_all_rule direction =
  Nsg.SecurityRule.make
    ~name:"AllowAll"
    ~description:None
    ~protocol:Any
    ~source_ports:[Any]
    ~destination_ports:[Any]
    ~source:Nsg.SecurityRule.Any
    ~destination:Nsg.SecurityRule.Any
    ~access:Nsg.SecurityRule.Allow
    ~priority:100
    ~direction

let make_nsg name rules =
  Nsg.make
    ~name
    ~subscription:"DEFAULT"
    ~address:("azurerm_network_security_group." ^ name)
    ~location:EastUs
    ~resource_group:test_rg
    ~rule_list:rules
    ~tags:[]

let allow_all_nsg name =
  make_nsg name [allow_all_rule Nsg.SecurityRule.Inbound; allow_all_rule Nsg.SecurityRule.Outbound]

let add_subnet_to_world subnet (world : World.t) =
  { world with subnets = AddressMap.add (Subnet.get_address subnet) subnet world.subnets }

let add_nic_to_world nic (world : World.t) =
  { world with nics = AddressMap.add (Nic.get_address nic) nic world.nics }

let add_vnet_to_world vnet (world : World.t) =
  { world with vnets = AddressMap.add (Vnet.get_address vnet) vnet world.vnets }

let attach_nsg_to_subnet nsg subnet (world : World.t) =
  let subnet_addr = Subnet.get_address subnet in
  { world with assocs = { world.assocs with subnet_nsg = AddressMap.add subnet_addr nsg world.assocs.subnet_nsg } }

let attach_nsg_to_nic nsg nic (world : World.t) =
  let nic_addr = Nic.get_address nic in
  { world with assocs = { world.assocs with nic_nsg = AddressMap.add nic_addr nsg world.assocs.nic_nsg } }

let attach_rt_to_subnet rt subnet (world : World.t) =
  let subnet_addr = Subnet.get_address subnet in
  { world with assocs = { world.assocs with subnet_rt = AddressMap.add subnet_addr rt world.assocs.subnet_rt } }

let make_udr name cidr_str next_hop =
  Route_table.Route.make
    ~name
    ~address_prefix:(cidr cidr_str)
    ~next_hop
    ~next_hop_in_ip_address:Unresolved
    ~source:UserDefined

let make_rt routes =
  Route_table.make
    ~name:"test-rt"
    ~subscription:"DEFAULT"
    ~address:"azurerm_route_table.test"
    ~location:EastUs
    ~resource_group:test_rg
    ~bgp_route_propagation_enabled:false
    ~routes
    ~tags:[]

let make_peering name local_vnet remote_vnet allow_access =
  Vnet_peering.make
    ~name
    ~subscription:"DEFAULT"
    ~address:("azurerm_virtual_network_peering." ^ name)
    ~resource_group:test_rg
    ~local_vnet:(Resolved local_vnet)
    ~remote_vnet:(Resolved remote_vnet)
    ~allow_virtual_network_access:allow_access
    ~allow_forwarded_traffic:None
    ~allow_gateway_transit:None
    ~use_remote_gateways:None
    ~local_subnet_names:None
    ~remote_subnet_names:None
    ~peer_complete_virtual_networks_enabled:None

let add_peering_to_world peering (world : World.t) =
  { world with vnet_peerings = AddressMap.add (Vnet_peering.get_address peering) peering world.vnet_peerings }

let make_asg name =
  Asg.make
    ~name
    ~subscription:"DEFAULT"
    ~address:("azurerm_application_security_group." ^ name)
    ~location:EastUs
    ~resource_group:test_rg
    ~tags:[]

let add_asg_to_world asg (world : World.t) =
  { world with asgs = AddressMap.add (Asg.get_address asg) asg world.asgs }

let add_nic_to_asg asg nic (world : World.t) =
  let asg_addr = Asg.get_address asg in
  let existing = Option.value ~default:[] (AddressMap.find_opt asg_addr world.assocs.asg_to_nics) in
  { world with assocs = { world.assocs with asg_to_nics = AddressMap.add asg_addr (nic :: existing) world.assocs.asg_to_nics } }

let nic_node_addr nic = Nic.get_address nic ^ "/ipconfig1"

(* --- BDD helpers --- *)

let man () = Pathfinder.Bdd.init () ~vars:32

(* Evaluate a BDD with DestIP bits fixed to the given IP; all other fields free.
   Returns true iff any satisfying assignment exists for those DestIP values. *)
let ip_as_int32 ip_str =
  fst (CIDR.get_interval (Option.get (CIDR.of_string_opt (ip_str ^ "/32"))))

let make_ip_cube mgr offset ip_str =
  let ip_int = Int32.to_int (ip_as_int32 ip_str) in
  List.init 32 (fun i ->
    if (ip_int lsr i) land 1 = 1 then ithvar mgr (offset + i)
    else dnot mgr (ithvar mgr (offset + i)))
  |> List.fold_left (dand mgr) (dtrue mgr)

let permits_dest_ip mgr bdd ip_str =
  let cube = make_ip_cube mgr 0 ip_str in
  sat_count mgr (dand mgr bdd cube) > 0.5

(* Fix both dest IP (bits 0-31) and src IP (bits 32-63) and check satisfiability. *)
let permits_src_dest_ip mgr bdd src_str dst_str =
  let cube = dand mgr (make_ip_cube mgr 0 dst_str) (make_ip_cube mgr 32 src_str) in
  sat_count mgr (dand mgr bdd cube) > 0.5

(* --- Tests --- *)

(* A world with N subnets and M NIC ipconfigs produces N+M nodes. *)
let node_count_tests = "node_count" >::: [

  "two_subnets_one_nic_produces_three_nodes" >:: (fun _ ->
    let vnet = make_vnet "vnet" in
    let sa = make_subnet vnet "subnet-a" "10.0.1.0/24" in
    let sb = make_subnet vnet "subnet-b" "10.0.2.0/24" in
    let nic = make_nic "nic1" sa "10.0.1.4" in
    let world =
      World.empty
      |> add_vnet_to_world vnet
      |> add_subnet_to_world sa
      |> add_subnet_to_world sb
      |> add_nic_to_world nic
    in
    let mgr = man () in
    let graph, _ = build_graph world mgr in
    assert_equal 4 (node_count graph)
      ~msg:"expected 2 subnet nodes + 1 NIC node + 1 Internet node");

  "empty_world_has_only_internet_node" >:: (fun _ ->
    let mgr = man () in
    let graph, _ = build_graph World.empty mgr in
    assert_equal 1 (node_count graph)
      ~msg:"expected only the Internet sentinel node");

]

(* A NIC node has an outgoing edge to its subnet node. *)
let nic_connectivity_tests = "nic_connectivity" >::: [

  "nic_connects_to_its_subnet" >:: (fun _ ->
    let vnet = make_vnet "vnet" in
    let subnet = make_subnet vnet "subnet-a" "10.0.1.0/24" in
    let nic = make_nic "nic1" subnet "10.0.1.4" in
    let world =
      World.empty
      |> add_vnet_to_world vnet
      |> add_subnet_to_world subnet
      |> add_nic_to_world nic
    in
    let mgr = man () in
    let graph, _ = build_graph world mgr in
    assert_bool "NIC should have outgoing edge to its subnet"
      (has_edge_between graph (nic_node_addr nic) (Subnet.get_address subnet)));

  "nic_does_not_connect_to_unrelated_subnet" >:: (fun _ ->
    let vnet = make_vnet "vnet" in
    let sa = make_subnet vnet "subnet-a" "10.0.1.0/24" in
    let sb = make_subnet vnet "subnet-b" "10.0.2.0/24" in
    let nic = make_nic "nic1" sa "10.0.1.4" in
    let world =
      World.empty
      |> add_vnet_to_world vnet
      |> add_subnet_to_world sa
      |> add_subnet_to_world sb
      |> add_nic_to_world nic
    in
    let mgr = man () in
    let graph, _ = build_graph world mgr in
    assert_bool "NIC should not connect directly to an unrelated subnet"
      (not (has_edge_between graph (nic_node_addr nic) (Subnet.get_address sb))));

]

(* Subnets in the same VNet are connected via VNet-local routes. *)
let subnet_connectivity_tests = "subnet_connectivity" >::: [

  "subnets_in_same_vnet_are_connected" >:: (fun _ ->
    let vnet = make_vnet ~addresses:[cidr "10.0.0.0/16"] "vnet" in
    let sa = make_subnet vnet "subnet-a" "10.0.1.0/24" in
    let sb = make_subnet vnet "subnet-b" "10.0.2.0/24" in
    let world =
      World.empty
      |> add_vnet_to_world vnet
      |> add_subnet_to_world sa
      |> add_subnet_to_world sb
    in
    let mgr = man () in
    let graph, _ = build_graph world mgr in
    assert_bool "subnet-a should connect to subnet-b via VNet-local route"
      (has_edge_between graph (Subnet.get_address sa) (Subnet.get_address sb));
    assert_bool "subnet-b should connect to subnet-a via VNet-local route"
      (has_edge_between graph (Subnet.get_address sb) (Subnet.get_address sa)));

  "subnets_in_different_vnets_are_not_connected" >:: (fun _ ->
    let vnet1 = make_vnet "vnet1" in
    let vnet2 = make_vnet "vnet2" in
    let sa = make_subnet vnet1 "subnet-a" "10.0.1.0/24" in
    let sb = make_subnet vnet2 "subnet-b" "10.1.1.0/24" in
    let world =
      World.empty
      |> add_vnet_to_world vnet1
      |> add_vnet_to_world vnet2
      |> add_subnet_to_world sa
      |> add_subnet_to_world sb
    in
    let mgr = man () in
    let graph, _ = build_graph world mgr in
    assert_bool "subnets in different VNets should not be connected"
      (not (has_edge_between graph (Subnet.get_address sa) (Subnet.get_address sb))));

]

(* The edge BDD permits exactly the traffic that the route and NSGs allow. *)
let bdd_tests = "bdd_semantics" >::: [

  (* With allow-all NSGs, the decider on the A→B edge is determined by
     the winning route intervals: it permits IPs in subnet B's CIDR only. *)
  "vnetlocal_edge_permits_dest_in_target_cidr" >:: (fun _ ->
    let vnet = make_vnet ~addresses:[cidr "10.0.0.0/16"] "vnet" in
    let sa = make_subnet vnet "subnet-a" "10.0.1.0/24" in
    let sb = make_subnet vnet "subnet-b" "10.0.2.0/24" in
    let nsg_a = allow_all_nsg "nsg-a" in
    let nsg_b = allow_all_nsg "nsg-b" in
    let world =
      World.empty
      |> add_vnet_to_world vnet
      |> add_subnet_to_world sa
      |> add_subnet_to_world sb
      |> attach_nsg_to_subnet nsg_a sa
      |> attach_nsg_to_subnet nsg_b sb
    in
    let mgr = man () in
    let graph, _ = build_graph world mgr in
    match get_decider graph (Subnet.get_address sa) (Subnet.get_address sb) with
    | None -> assert_failure "expected edge from subnet-a to subnet-b"
    | Some bdd ->
      assert_bool "decider should permit traffic destined for subnet-b's CIDR"
        (permits_dest_ip mgr bdd "10.0.2.1"));

  "vnetlocal_edge_denies_dest_outside_target_cidr" >:: (fun _ ->
    let vnet = make_vnet ~addresses:[cidr "10.0.0.0/16"] "vnet" in
    let sa = make_subnet vnet "subnet-a" "10.0.1.0/24" in
    let sb = make_subnet vnet "subnet-b" "10.0.2.0/24" in
    let nsg_a = allow_all_nsg "nsg-a" in
    let nsg_b = allow_all_nsg "nsg-b" in
    let world =
      World.empty
      |> add_vnet_to_world vnet
      |> add_subnet_to_world sa
      |> add_subnet_to_world sb
      |> attach_nsg_to_subnet nsg_a sa
      |> attach_nsg_to_subnet nsg_b sb
    in
    let mgr = man () in
    let graph, _ = build_graph world mgr in
    match get_decider graph (Subnet.get_address sa) (Subnet.get_address sb) with
    | None -> assert_failure "expected edge from subnet-a to subnet-b"
    | Some bdd ->
      assert_bool "decider should deny traffic destined outside subnet-b's CIDR"
        (not (permits_dest_ip mgr bdd "10.0.3.1")));

  (* NIC NSG gate: with a deny-all NIC NSG, the NIC→subnet edge blocks all traffic. *)
  "nic_nsg_deny_all_blocks_traffic" >:: (fun _ ->
    let vnet = make_vnet "vnet" in
    let subnet = make_subnet vnet "subnet-a" "10.0.1.0/24" in
    let nic = make_nic "nic1" subnet "10.0.1.4" in
    let deny_all_nsg =
      make_nsg "deny-all" [
        Nsg.SecurityRule.make
          ~name:"DenyAll"
          ~description:None
          ~protocol:Any
          ~source_ports:[Any]
          ~destination_ports:[Any]
          ~source:Nsg.SecurityRule.Any
          ~destination:Nsg.SecurityRule.Any
          ~access:Nsg.SecurityRule.Deny
          ~priority:100
          ~direction:Nsg.SecurityRule.Outbound
      ]
    in
    let world =
      World.empty
      |> add_vnet_to_world vnet
      |> add_subnet_to_world subnet
      |> add_nic_to_world nic
      |> attach_nsg_to_nic deny_all_nsg nic
    in
    let mgr = man () in
    let graph, _ = build_graph world mgr in
    match get_decider graph (nic_node_addr nic) (Subnet.get_address subnet) with
    | None -> assert_failure "expected edge from NIC to subnet"
    | Some bdd ->
      assert_bool "deny-all NIC NSG should block all traffic"
        (not (permits_dest_ip mgr bdd "10.0.1.4")));

]

(* VNet peering: routes are always injected regardless of allow_virtual_network_access.
   The flag controls only whether the peered CIDR is added to AllowVNetInBound on the
   destination subnet's NSG.  Tests use permits_src_dest_ip so we check the specific
   (src, dst) pair rather than "any source reaches this dest". *)
let peering_tests = "vnet_peering" >::: [

  (* With allow_virtual_network_access = true, the peered CIDR is added to
     AllowVNetInBound on the destination NSG, permitting traffic from the remote subnet. *)
  "peered_traffic_permitted_when_access_allowed" >:: (fun _ ->
    let vnet_a = make_vnet ~addresses:[cidr "10.0.0.0/16"] "vnet-a" in
    let vnet_b = make_vnet ~addresses:[cidr "10.1.0.0/16"] "vnet-b" in
    let sa = make_subnet vnet_a "subnet-a" "10.0.1.0/24" in
    let sb = make_subnet vnet_b "subnet-b" "10.1.1.0/24" in
    let peer_a_to_b = make_peering "peer-a-to-b" vnet_a vnet_b (Some true) in
    let peer_b_to_a = make_peering "peer-b-to-a" vnet_b vnet_a (Some true) in
    let nsg_b = make_nsg "nsg-b" [] in
    let world =
      World.empty
      |> add_vnet_to_world vnet_a
      |> add_vnet_to_world vnet_b
      |> add_subnet_to_world sa
      |> add_subnet_to_world sb
      |> add_peering_to_world peer_a_to_b
      |> add_peering_to_world peer_b_to_a
      |> attach_nsg_to_subnet nsg_b sb
    in
    let mgr = man () in
    let graph, _ = build_graph world mgr in
    match get_decider graph (Subnet.get_address sa) (Subnet.get_address sb) with
    | None -> assert_failure "expected edge from subnet-a to subnet-b"
    | Some bdd ->
      assert_bool "traffic from peered subnet should be permitted by AllowVNetInBound"
        (permits_src_dest_ip mgr bdd "10.0.1.4" "10.1.1.4"));

  (* With allow_virtual_network_access = false, the peered CIDR is excluded from
     AllowVNetInBound; DenyAllInbound catches traffic from the remote subnet. *)
  "peered_traffic_blocked_when_access_denied" >:: (fun _ ->
    let vnet_a = make_vnet ~addresses:[cidr "10.0.0.0/16"] "vnet-a" in
    let vnet_b = make_vnet ~addresses:[cidr "10.1.0.0/16"] "vnet-b" in
    let sa = make_subnet vnet_a "subnet-a" "10.0.1.0/24" in
    let sb = make_subnet vnet_b "subnet-b" "10.1.1.0/24" in
    let peer_a_to_b = make_peering "peer-a-to-b" vnet_a vnet_b (Some false) in
    let peer_b_to_a = make_peering "peer-b-to-a" vnet_b vnet_a (Some false) in
    let nsg_b = make_nsg "nsg-b" [] in
    let world =
      World.empty
      |> add_vnet_to_world vnet_a
      |> add_vnet_to_world vnet_b
      |> add_subnet_to_world sa
      |> add_subnet_to_world sb
      |> add_peering_to_world peer_a_to_b
      |> add_peering_to_world peer_b_to_a
      |> attach_nsg_to_subnet nsg_b sb
    in
    let mgr = man () in
    let graph, _ = build_graph world mgr in
    match get_decider graph (Subnet.get_address sa) (Subnet.get_address sb) with
    | None -> assert_failure "expected edge from subnet-a to subnet-b (route still exists)"
    | Some bdd ->
      assert_bool "traffic from peered subnet should be blocked when access is denied"
        (not (permits_src_dest_ip mgr bdd "10.0.1.4" "10.1.1.4")));

]

let asg_rule direction src_asg_addr =
  Nsg.SecurityRule.make
    ~name:"AllowFromAsg"
    ~description:None
    ~protocol:Any
    ~source_ports:[Any]
    ~destination_ports:[Any]
    ~source:(Nsg.SecurityRule.ApplicationGroups [src_asg_addr])
    ~destination:Nsg.SecurityRule.Any
    ~access:Nsg.SecurityRule.Allow
    ~priority:100
    ~direction

(* An NSG rule with ApplicationGroups source should allow only traffic whose
   source IP belongs to a member NIC; non-member IPs hit DenyAllInbound. *)
let asg_tests = "asg_resolution" >::: [

  "asg_member_ip_is_permitted" >:: (fun _ ->
    let vnet = make_vnet ~addresses:[cidr "10.0.0.0/16"] "vnet" in
    let sa = make_subnet vnet "subnet-a" "10.0.1.0/24" in
    let sb = make_subnet vnet "subnet-b" "10.0.2.0/24" in
    let asg = make_asg "asg1" in
    let member_nic = make_nic "member-nic" sa "10.0.1.4" in
    let nsg_b = make_nsg "nsg-b" [asg_rule Nsg.SecurityRule.Inbound (Asg.get_address asg)] in
    let world =
      World.empty
      |> add_vnet_to_world vnet
      |> add_subnet_to_world sa
      |> add_subnet_to_world sb
      |> add_nic_to_world member_nic
      |> add_asg_to_world asg
      |> add_nic_to_asg asg member_nic
      |> attach_nsg_to_subnet nsg_b sb
    in
    let mgr = man () in
    let graph, _ = build_graph world mgr in
    match get_decider graph (Subnet.get_address sa) (Subnet.get_address sb) with
    | None -> assert_failure "expected edge from subnet-a to subnet-b"
    | Some bdd ->
      assert_bool "ASG member's IP should be permitted by the ApplicationGroups rule"
        (permits_src_dest_ip mgr bdd "10.0.1.4" "10.0.2.1"));

  (* Traffic from outside the VNet CIDR skips AllowVNetInBound and hits
     DenyAllInbound unless covered by an explicit allow rule.  An external
     IP not in the ASG should therefore be denied. *)
  "external_non_member_ip_is_denied" >:: (fun _ ->
    let vnet = make_vnet ~addresses:[cidr "10.0.0.0/16"] "vnet" in
    let sa = make_subnet vnet "subnet-a" "10.0.1.0/24" in
    let sb = make_subnet vnet "subnet-b" "10.0.2.0/24" in
    let asg = make_asg "asg1" in
    let member_nic = make_nic "member-nic" sa "10.0.1.4" in
    let nsg_b = make_nsg "nsg-b" [asg_rule Nsg.SecurityRule.Inbound (Asg.get_address asg)] in
    let world =
      World.empty
      |> add_vnet_to_world vnet
      |> add_subnet_to_world sa
      |> add_subnet_to_world sb
      |> add_nic_to_world member_nic
      |> add_asg_to_world asg
      |> add_nic_to_asg asg member_nic
      |> attach_nsg_to_subnet nsg_b sb
    in
    let mgr = man () in
    let graph, _ = build_graph world mgr in
    match get_decider graph (Subnet.get_address sa) (Subnet.get_address sb) with
    | None -> assert_failure "expected edge from subnet-a to subnet-b"
    | Some bdd ->
      assert_bool "external IP not in the ASG should be denied by DenyAllInbound"
        (not (permits_src_dest_ip mgr bdd "203.0.113.1" "10.0.2.1")));

]

(* Every world has an implicit 0.0.0.0/0 -> Internet system route (see
   effective_route_table.ml), so a subnet with no overriding UDR should always
   have an edge to the Internet sentinel node. *)
let internet_tests = "internet_connectivity" >::: [

  "subnet_with_no_udr_reaches_internet" >:: (fun _ ->
    let vnet = make_vnet ~addresses:[cidr "10.0.0.0/16"] "vnet" in
    let subnet = make_subnet vnet "subnet-a" "10.0.1.0/24" in
    let world =
      World.empty
      |> add_vnet_to_world vnet
      |> add_subnet_to_world subnet
    in
    let mgr = man () in
    let graph, _ = build_graph world mgr in
    assert_bool "subnet should have an outgoing edge to the Internet node"
      (has_edge_between graph (Subnet.get_address subnet) "$internet"));

  "internet_edge_permits_public_destination" >:: (fun _ ->
    let vnet = make_vnet ~addresses:[cidr "10.0.0.0/16"] "vnet" in
    let subnet = make_subnet vnet "subnet-a" "10.0.1.0/24" in
    let nsg = allow_all_nsg "nsg-a" in
    let world =
      World.empty
      |> add_vnet_to_world vnet
      |> add_subnet_to_world subnet
      |> attach_nsg_to_subnet nsg subnet
    in
    let mgr = man () in
    let graph, _ = build_graph world mgr in
    match get_decider graph (Subnet.get_address subnet) "$internet" with
    | None -> assert_failure "expected edge from subnet-a to the Internet node"
    | Some bdd ->
      assert_bool "decider should permit traffic to a public destination"
        (permits_dest_ip mgr bdd "8.8.8.8"));

  (* A UDR overriding 0.0.0.0/0 to Drop replaces the implicit Internet route,
     so no edge to the Internet node should exist. *)
  "udr_override_of_default_route_removes_internet_edge" >:: (fun _ ->
    let vnet = make_vnet ~addresses:[cidr "10.0.0.0/16"] "vnet" in
    let subnet = make_subnet vnet "subnet-a" "10.0.1.0/24" in
    let rt = make_rt [make_udr "drop-default" "0.0.0.0/0" Drop] in
    let world =
      World.empty
      |> add_vnet_to_world vnet
      |> add_subnet_to_world subnet
      |> attach_rt_to_subnet rt subnet
    in
    let mgr = man () in
    let graph, _ = build_graph world mgr in
    assert_bool "Drop UDR should override the implicit Internet route"
      (not (has_edge_between graph (Subnet.get_address subnet) "$internet")));

]

let suite = "hsa_suite" >::: [
  node_count_tests;
  nic_connectivity_tests;
  subnet_connectivity_tests;
  bdd_tests;
  peering_tests;
  asg_tests;
  internet_tests;
]

let () = run_test_tt_main suite
