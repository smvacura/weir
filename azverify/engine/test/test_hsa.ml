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

let make_vnet name =
  Vnet.make
    ~name
    ~subscription:"DEFAULT"
    ~address:("azurerm_virtual_network." ^ name)
    ~location:EastUs
    ~resource_group:test_rg
    ~addresses:[]

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
  let addr = "assoc_nsg_" ^ Nsg.get_address nsg ^ "_" ^ Subnet.get_address subnet in
  { world with nsg_associations =
    AddressMap.add addr (Association.BinaryAssociation.make nsg subnet addr) world.nsg_associations }

let attach_nsg_to_nic nsg nic (world : World.t) =
  let addr = "assoc_nsg_" ^ Nsg.get_address nsg ^ "_" ^ Nic.get_address nic in
  { world with nic_nsg_associations =
    AddressMap.add addr (Association.BinaryAssociation.make nsg nic addr) world.nic_nsg_associations }

let nic_node_addr nic = Nic.get_address nic ^ "/ipconfig1"

(* --- BDD helpers --- *)

let man () = Pathfinder.Bdd.init () ~vars:32

(* Evaluate a BDD with DestIP bits fixed to the given IP; all other fields free.
   Returns true iff any satisfying assignment exists for those DestIP values. *)
let ip_as_int32 ip_str =
  fst (CIDR.get_interval (Option.get (CIDR.of_string_opt (ip_str ^ "/32"))))

let permits_dest_ip mgr bdd ip_str =
  let ip_int = Int32.to_int (ip_as_int32 ip_str) in
  let cube =
    List.init 32 (fun i ->
      if (ip_int lsr i) land 1 = 1 then ithvar mgr i
      else dnot mgr (ithvar mgr i))
    |> List.fold_left (dand mgr) (dtrue mgr)
  in
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
    let graph = build_graph world mgr in
    assert_equal 3 (node_count graph)
      ~msg:"expected 2 subnet nodes + 1 NIC node");

  "empty_world_has_no_nodes" >:: (fun _ ->
    let mgr = man () in
    let graph = build_graph World.empty mgr in
    assert_equal 0 (node_count graph));

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
    let graph = build_graph world mgr in
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
    let graph = build_graph world mgr in
    assert_bool "NIC should not connect directly to an unrelated subnet"
      (not (has_edge_between graph (nic_node_addr nic) (Subnet.get_address sb))));

]

(* Subnets in the same VNet are connected via VNet-local routes. *)
let subnet_connectivity_tests = "subnet_connectivity" >::: [

  "subnets_in_same_vnet_are_connected" >:: (fun _ ->
    let vnet = make_vnet "vnet" in
    let sa = make_subnet vnet "subnet-a" "10.0.1.0/24" in
    let sb = make_subnet vnet "subnet-b" "10.0.2.0/24" in
    let world =
      World.empty
      |> add_vnet_to_world vnet
      |> add_subnet_to_world sa
      |> add_subnet_to_world sb
    in
    let mgr = man () in
    let graph = build_graph world mgr in
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
    let graph = build_graph world mgr in
    assert_bool "subnets in different VNets should not be connected"
      (not (has_edge_between graph (Subnet.get_address sa) (Subnet.get_address sb))));

]

(* The edge BDD permits exactly the traffic that the route and NSGs allow. *)
let bdd_tests = "bdd_semantics" >::: [

  (* With allow-all NSGs, the decider on the A→B edge is determined by
     the winning route intervals: it permits IPs in subnet B's CIDR only. *)
  "vnetlocal_edge_permits_dest_in_target_cidr" >:: (fun _ ->
    let vnet = make_vnet "vnet" in
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
    let graph = build_graph world mgr in
    match get_decider graph (Subnet.get_address sa) (Subnet.get_address sb) with
    | None -> assert_failure "expected edge from subnet-a to subnet-b"
    | Some bdd ->
      assert_bool "decider should permit traffic destined for subnet-b's CIDR"
        (permits_dest_ip mgr bdd "10.0.2.1"));

  "vnetlocal_edge_denies_dest_outside_target_cidr" >:: (fun _ ->
    let vnet = make_vnet "vnet" in
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
    let graph = build_graph world mgr in
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
    let graph = build_graph world mgr in
    match get_decider graph (nic_node_addr nic) (Subnet.get_address subnet) with
    | None -> assert_failure "expected edge from NIC to subnet"
    | Some bdd ->
      assert_bool "deny-all NIC NSG should block all traffic"
        (not (permits_dest_ip mgr bdd "10.0.1.4")));

]

let suite = "hsa_suite" >::: [
  node_count_tests;
  nic_connectivity_tests;
  subnet_connectivity_tests;
  bdd_tests;
]

let () = run_test_tt_main suite
