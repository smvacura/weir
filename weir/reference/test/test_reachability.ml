open OUnit2
open Parser.Network_types
open Parser.Azure_types
open Terraform_ir
open Parser.Tf_types

(* These tests pin the reference oracle to Azure's documented routing
   semantics. Each scenario is anchored to a passage in
   https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-udr-overview
   (the "Routing example" and "System routes" sections), so the expected
   values come from Microsoft's documentation, not from the engine or from
   the oracle itself. *)

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

let ip s = fst (CIDR.get_interval (cidr (s ^ "/32")))

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

let udr name prefix next_hop =
  Route_table.Route.make
    ~name
    ~address_prefix:(cidr prefix)
    ~next_hop
    ~next_hop_in_ip_address:Unresolved
    ~source:UserDefined

let make_rt name routes =
  Route_table.make
    ~name
    ~subscription:"DEFAULT"
    ~address:("azurerm_route_table." ^ name)
    ~location:EastUs
    ~resource_group:test_rg
    ~routes
    ~bgp_route_propagation_enabled:true
    ~tags:[]

let make_ipconfig subnet ip_str =
  Nic.IpConfiguration.make
    ~name:"ipconfig1"
    ~subscription:"DEFAULT"
    ~subnet:(Resolved subnet)
    ~ip_address_version:IPv4
    ~pip:(Resolved None)
    ~private_address_allocation:(Static (Option.get (IPv4.of_string_opt ip_str)))
    ~primary:(Some true)

let make_nic ~forwards name subnet ip_str =
  Nic.make
    ~name
    ~subscription:"DEFAULT"
    ~address:("azurerm_network_interface." ^ name)
    ~location:EastUs
    ~resource_group:test_rg
    ~ip_forwarding_enabled:forwards
    ~ip_configurations:[make_ipconfig subnet ip_str]

let appliance_udr name prefix ip_str =
  Route_table.Route.make
    ~name
    ~address_prefix:(cidr prefix)
    ~next_hop:VirtualAppliance
    ~next_hop_in_ip_address:(Resolved (StaticAppliance (Option.get (IPv4.of_string_opt ip_str))))
    ~source:UserDefined

let add_subnet_to_world subnet (world : World.t) =
  { world with subnets = AddressMap.add (Subnet.get_address subnet) subnet world.subnets }

let add_nic_to_world nic (world : World.t) =
  { world with nics = AddressMap.add (Nic.get_address nic) nic world.nics }

let add_vnet_to_world vnet (world : World.t) =
  { world with vnets = AddressMap.add (Vnet.get_address vnet) vnet world.vnets }

let attach_rt_to_subnet rt subnet (world : World.t) =
  let subnet_addr = Subnet.get_address subnet in
  { world with assocs = { world.assocs with subnet_rt = AddressMap.add subnet_addr rt world.assocs.subnet_rt } }

let packet src dest =
  Reference.Packet.make
    ~src_ip:(ip src) ~dest_ip:(ip dest)
    ~src_port:49152 ~dest_port:80 ~protocol:Tcp

let reachable world src pkt =
  Reference.Reachability.reachable world ~src pkt

(* --- Intra-subnet traffic goes through LPM, not direct delivery ---

   Doc anchor ("Routing example", route IDs 2 and 3): with VNet 10.0.0.0/16
   and Subnet1 10.0.0.0/24, the UDR "Within-VNet1" (10.0.0.0/16 -> Virtual
   appliance) captures intra-subnet traffic; the example adds the UDR
   "Within-Subnet1" (10.0.0.0/24 -> Virtual network) precisely so that
   intra-subnet traffic "isn't routed to the virtual appliance specified in
   the previous rule (ID2)". There is no implicit per-subnet system route:
   "Azure doesn't create default routes for subnet address ranges." *)

let intra_subnet_routing_tests = "intra_subnet_routing" >::: [

  "no_udr_same_subnet_delivers" >:: (fun _ ->
    let vnet = make_vnet ~addresses:[cidr "10.0.0.0/16"] "vnet1" in
    let s1 = make_subnet vnet "subnet1" "10.0.0.0/24" in
    let world = World.empty |> add_vnet_to_world vnet |> add_subnet_to_world s1 in
    assert_bool "default VnetLocal route delivers same-subnet traffic"
      (reachable world (Subnet.get_address s1) (packet "10.0.0.4" "10.0.0.5")));

  (* Doc ID2 without ID3: the /16 UDR ties the VnetLocal system route on
     prefix and wins as a UDR, so same-subnet traffic goes to the appliance
     (blocked under the oracle's scoping). *)
  "vnet_wide_udr_to_appliance_captures_intra_subnet" >:: (fun _ ->
    let vnet = make_vnet ~addresses:[cidr "10.0.0.0/16"] "vnet1" in
    let s1 = make_subnet vnet "subnet1" "10.0.0.0/24" in
    let rt = make_rt "rt1" [udr "Within-VNet1" "10.0.0.0/16" VirtualAppliance] in
    let world =
      World.empty |> add_vnet_to_world vnet |> add_subnet_to_world s1
      |> attach_rt_to_subnet rt s1
    in
    assert_bool "intra-subnet traffic must follow the /16 UDR to the appliance"
      (not (reachable world (Subnet.get_address s1) (packet "10.0.0.4" "10.0.0.5"))));

  (* Doc ID2 + ID3: the more specific /24 -> Virtual network UDR restores
     local delivery. *)
  "subnet_prefix_udr_to_virtualnetwork_restores_delivery" >:: (fun _ ->
    let vnet = make_vnet ~addresses:[cidr "10.0.0.0/16"] "vnet1" in
    let s1 = make_subnet vnet "subnet1" "10.0.0.0/24" in
    let rt = make_rt "rt1"
      [ udr "Within-VNet1" "10.0.0.0/16" VirtualAppliance;
        udr "Within-Subnet1" "10.0.0.0/24" VirtualNetwork ] in
    let world =
      World.empty |> add_vnet_to_world vnet |> add_subnet_to_world s1
      |> attach_rt_to_subnet rt s1
    in
    assert_bool "the /24 Virtual network UDR keeps intra-subnet traffic local"
      (reachable world (Subnet.get_address s1) (packet "10.0.0.4" "10.0.0.5")));

  (* A UDR for the subnet's own prefix with next hop None drops even
     same-subnet traffic ("None: ... traffic ... is dropped"). *)
  "subnet_prefix_udr_to_none_drops_intra_subnet" >:: (fun _ ->
    let vnet = make_vnet ~addresses:[cidr "10.0.0.0/16"] "vnet1" in
    let s1 = make_subnet vnet "subnet1" "10.0.0.0/24" in
    let rt = make_rt "rt1" [udr "DropLocal" "10.0.0.0/24" Drop] in
    let world =
      World.empty |> add_vnet_to_world vnet |> add_subnet_to_world s1
      |> attach_rt_to_subnet rt s1
    in
    assert_bool "a None UDR covering the subnet drops intra-subnet traffic"
      (not (reachable world (Subnet.get_address s1) (packet "10.0.0.4" "10.0.0.5"))));

  "cross_subnet_delivery_still_works" >:: (fun _ ->
    let vnet = make_vnet ~addresses:[cidr "10.0.0.0/16"] "vnet1" in
    let s1 = make_subnet vnet "subnet1" "10.0.0.0/24" in
    let s2 = make_subnet vnet "subnet2" "10.0.1.0/24" in
    let world =
      World.empty |> add_vnet_to_world vnet
      |> add_subnet_to_world s1 |> add_subnet_to_world s2
    in
    assert_bool "cross-subnet traffic delivers via the VnetLocal route"
      (reachable world (Subnet.get_address s1) (packet "10.0.0.4" "10.0.1.5")));

]

(* --- VNet address space covering a reserved drop prefix ---

   Doc anchor ("System routes" / next hop type None): "If you assign any of
   the previous address ranges within the address space of a virtual network,
   Azure automatically changes the next hop type for the route from None to
   Virtual network. If you assign an address range ... that includes, but
   isn't the same as, one of the four reserved address prefixes, Azure
   removes the route for the prefix". *)

let reserved_prefix_tests = "reserved_prefix_coverage" >::: [

  (* VNet space equal to a reserved prefix: the drop flips to Virtual
     network, so cross-subnet traffic delivers. *)
  "vnet_space_equal_to_reserved_prefix_delivers" >:: (fun _ ->
    let vnet = make_vnet ~addresses:[cidr "10.0.0.0/8"] "vnet1" in
    let s1 = make_subnet vnet "subnet1" "10.0.0.0/24" in
    let s2 = make_subnet vnet "subnet2" "10.1.0.0/24" in
    let world =
      World.empty |> add_vnet_to_world vnet
      |> add_subnet_to_world s1 |> add_subnet_to_world s2
    in
    assert_bool "VNet space equal to 10.0.0.0/8 overrides the reserved drop"
      (reachable world (Subnet.get_address s1) (packet "10.0.0.4" "10.1.0.5")));

  (* VNet space strictly containing a reserved prefix: Azure removes the
     drop route, so the (shorter) VnetLocal route wins for destinations
     inside the reserved range. *)
  "vnet_space_containing_reserved_prefix_delivers" >:: (fun _ ->
    let vnet = make_vnet ~addresses:[cidr "172.16.0.0/11"] "vnet1" in
    let s1 = make_subnet vnet "subnet1" "172.16.1.0/24" in
    let s2 = make_subnet vnet "subnet2" "172.20.0.0/24" in
    let world =
      World.empty |> add_vnet_to_world vnet
      |> add_subnet_to_world s1 |> add_subnet_to_world s2
    in
    assert_bool
      "172.16.0.0/11 covers 172.16.0.0/12, so the /12 drop route is removed"
      (reachable world (Subnet.get_address s1) (packet "172.16.1.4" "172.20.0.5")));

  (* VNet space strictly inside a reserved prefix (the common case): the
     drop route survives and still catches destinations outside the VNet. *)
  "reserved_drop_survives_when_vnet_is_inside_it" >:: (fun _ ->
    let vnet = make_vnet ~addresses:[cidr "10.1.0.0/16"] "vnet1" in
    let s1 = make_subnet vnet "subnet1" "10.1.0.0/24" in
    let world = World.empty |> add_vnet_to_world vnet |> add_subnet_to_world s1 in
    assert_bool "10.2.0.5 is outside the VNet and inside 10.0.0.0/8: dropped"
      (not (reachable world (Subnet.get_address s1) (packet "10.1.0.4" "10.2.0.5"))));

]

(* --- Forwarding through a virtual appliance ---

   Doc anchor ("Routing example", route ID2 "Within-VNet1" -> Virtual
   appliance): a UDR naming a virtual appliance hands the packet to the
   appliance's NIC, which then routes onward from its own subnet, rather than
   ending the path.

   Doc anchor (https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-network-interface,
   "Enable or disable IP forwarding"): IP forwarding lets a NIC "receive network
   traffic not destined for one of the IP addresses assigned to ... the network
   interface", and "You must enable IP forwarding for every network interface
   that receives traffic not destined for its own IP address." A NIC without it
   drops transit traffic. *)

let three_subnet_world ~forwards =
  let vnet = make_vnet ~addresses:[cidr "10.0.0.0/16"] "vnet1" in
  let src = make_subnet vnet "subnet_src" "10.0.0.0/24" in
  let nva_subnet = make_subnet vnet "subnet_nva" "10.0.1.0/24" in
  let dst = make_subnet vnet "subnet_dst" "10.0.2.0/24" in
  let nva = make_nic ~forwards "nva" nva_subnet "10.0.1.10" in
  let rt = make_rt "rt_src" [appliance_udr "to-nva" "10.0.2.0/24" "10.0.1.10"] in
  let world =
    World.empty |> add_vnet_to_world vnet
    |> add_subnet_to_world src |> add_subnet_to_world nva_subnet
    |> add_subnet_to_world dst
    |> add_nic_to_world nva
    |> attach_rt_to_subnet rt src
  in
  (world, Subnet.get_address src)

let appliance_routing_tests = "appliance_routing" >::: [

  (* The appliance subnet has no UDR, so its VnetLocal system route delivers
     the packet onward to the subnet owning the destination. *)
  "appliance_with_ip_forwarding_relays_to_destination" >:: (fun _ ->
    let (world, src) = three_subnet_world ~forwards:true in
    assert_bool "a forwarding appliance relays the packet to the destination subnet"
      (reachable world src (packet "10.0.0.4" "10.0.2.5")));

  "appliance_without_ip_forwarding_drops" >:: (fun _ ->
    let (world, src) = three_subnet_world ~forwards:false in
    assert_bool "a NIC without ip_forwarding_enabled drops transit traffic"
      (not (reachable world src (packet "10.0.0.4" "10.0.2.5"))));

  (* Two appliances pointing their /24 UDR at each other: the walk must end at
     the repeated node rather than recurse forever. *)
  "mutual_appliance_udrs_terminate" >:: (fun _ ->
    let vnet = make_vnet ~addresses:[cidr "10.0.0.0/16"] "vnet1" in
    let s_a = make_subnet vnet "subnet_a" "10.0.1.0/24" in
    let s_b = make_subnet vnet "subnet_b" "10.0.2.0/24" in
    let nva_a = make_nic ~forwards:true "nva_a" s_a "10.0.1.10" in
    let nva_b = make_nic ~forwards:true "nva_b" s_b "10.0.2.10" in
    let rt_a = make_rt "rt_a" [appliance_udr "a-to-b" "10.0.3.0/24" "10.0.2.10"] in
    let rt_b = make_rt "rt_b" [appliance_udr "b-to-a" "10.0.3.0/24" "10.0.1.10"] in
    let world =
      World.empty |> add_vnet_to_world vnet
      |> add_subnet_to_world s_a |> add_subnet_to_world s_b
      |> add_nic_to_world nva_a |> add_nic_to_world nva_b
      |> attach_rt_to_subnet rt_a s_a |> attach_rt_to_subnet rt_b s_b
    in
    assert_bool "a routing loop terminates and delivers nothing"
      (not (reachable world (Subnet.get_address s_a) (packet "10.0.1.4" "10.0.3.5"))));

]

let () =
  run_test_tt_main ("reference_reachability" >::: [
    intra_subnet_routing_tests;
    reserved_prefix_tests;
    appliance_routing_tests;
  ])
