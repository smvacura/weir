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

let rule ?(protocol : protocol = Any) ?(ports : port list = [Any])
    ~name ~priority ~direction ~access ~source ~destination () =
  Nsg.SecurityRule.make
    ~name
    ~description:None
    ~protocol
    ~source_ports:[Any]
    ~destination_ports:ports
    ~source
    ~destination
    ~access
    ~priority
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

let deny_all_in priority =
  rule ~name:"deny-all-in" ~priority ~direction:Inbound ~access:Deny
    ~source:Nsg.SecurityRule.Any ~destination:Nsg.SecurityRule.Any ()

let make_asg name =
  Asg.make
    ~name
    ~subscription:"DEFAULT"
    ~address:("azurerm_application_security_group." ^ name)
    ~location:EastUs
    ~resource_group:test_rg
    ~tags:[]

let make_peering name ~local ~remote ~access =
  Vnet_peering.make
    ~name
    ~subscription:"DEFAULT"
    ~address:("azurerm_virtual_network_peering." ^ name)
    ~resource_group:test_rg
    ~local_vnet:(Resolved local)
    ~remote_vnet:(Resolved remote)
    ~allow_virtual_network_access:(Some access)
    ~allow_forwarded_traffic:(Some true)
    ~allow_gateway_transit:None
    ~use_remote_gateways:None
    ~local_subnet_names:None
    ~remote_subnet_names:None
    ~peer_complete_virtual_networks_enabled:(Some true)

let add_subnet_to_world subnet (world : World.t) =
  { world with subnets = AddressMap.add (Subnet.get_address subnet) subnet world.subnets }

let add_nic_to_world nic (world : World.t) =
  { world with nics = AddressMap.add (Nic.get_address nic) nic world.nics }

let add_vnet_to_world vnet (world : World.t) =
  { world with vnets = AddressMap.add (Vnet.get_address vnet) vnet world.vnets }

let attach_rt_to_subnet rt subnet (world : World.t) =
  let subnet_addr = Subnet.get_address subnet in
  { world with assocs = { world.assocs with subnet_rt = AddressMap.add subnet_addr rt world.assocs.subnet_rt } }

let attach_nsg_to_subnet nsg subnet (world : World.t) =
  let subnet_addr = Subnet.get_address subnet in
  { world with assocs = { world.assocs with subnet_nsg = AddressMap.add subnet_addr nsg world.assocs.subnet_nsg } }

let attach_nsg_to_nic nsg nic (world : World.t) =
  let nic_addr = Nic.get_address nic in
  { world with assocs = { world.assocs with nic_nsg = AddressMap.add nic_addr nsg world.assocs.nic_nsg } }

let add_asg_members asg nics (world : World.t) =
  let asg_addr = Asg.get_address asg in
  { world with
    asgs = AddressMap.add asg_addr asg world.asgs;
    assocs = { world.assocs with asg_to_nics = AddressMap.add asg_addr nics world.assocs.asg_to_nics } }

let add_peering_to_world peering (world : World.t) =
  { world with
    vnet_peerings = AddressMap.add (Vnet_peering.get_address peering) peering world.vnet_peerings }

let packet src dest =
  Reference.Packet.make
    ~src_ip:(ip src) ~dest_ip:(ip dest)
    ~src_port:49152 ~dest_port:80 ~protocol:Tcp

let packet_on ?(protocol = Tcp) ?(dest_port = 80) src dest =
  Reference.Packet.make
    ~src_ip:(ip src) ~dest_ip:(ip dest)
    ~src_port:49152 ~dest_port ~protocol

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

(* --- NSG rule evaluation ---

   Doc anchor (https://learn.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview,
   "Security rules"): rules are evaluated in priority order within a direction,
   evaluation stops at the first match, and the six default rules sit below
   every user rule. *)

let two_subnet_world () =
  let vnet = make_vnet ~addresses:[cidr "10.0.0.0/16"] "vnet1" in
  let s1 = make_subnet vnet "subnet1" "10.0.1.0/24" in
  let s2 = make_subnet vnet "subnet2" "10.0.2.0/24" in
  let world =
    World.empty |> add_vnet_to_world vnet
    |> add_subnet_to_world s1 |> add_subnet_to_world s2
  in
  (world, vnet, s1, s2)

(* An inbound rule on a port the packet does not use, so no user rule matches
   and the default rules decide. *)
let falls_through_nsg =
  make_nsg "fallthrough"
    [ rule ~name:"allow-ssh" ~priority:100 ~direction:Inbound ~access:Allow
        ~ports:[Single 22] ~source:Nsg.SecurityRule.Any
        ~destination:Nsg.SecurityRule.Any () ]

let nsg_rule_tests = "nsg_rules" >::: [

  "lowest_priority_number_decides_allow" >:: (fun _ ->
    let (world, _, s1, s2) = two_subnet_world () in
    let nsg = make_nsg "n"
      [ rule ~name:"allow" ~priority:100 ~direction:Inbound ~access:Allow
          ~source:Nsg.SecurityRule.Any ~destination:Nsg.SecurityRule.Any ();
        deny_all_in 200 ] in
    let world = attach_nsg_to_subnet nsg s2 world in
    assert_bool "the priority-100 allow is matched first"
      (reachable world (Subnet.get_address s1) (packet "10.0.1.4" "10.0.2.5")));

  "lowest_priority_number_decides_deny" >:: (fun _ ->
    let (world, _, s1, s2) = two_subnet_world () in
    let nsg = make_nsg "n"
      [ deny_all_in 100;
        rule ~name:"allow" ~priority:200 ~direction:Inbound ~access:Allow
          ~source:Nsg.SecurityRule.Any ~destination:Nsg.SecurityRule.Any () ] in
    let world = attach_nsg_to_subnet nsg s2 world in
    assert_bool "a higher-numbered allow is never reached"
      (not (reachable world (Subnet.get_address s1) (packet "10.0.1.4" "10.0.2.5"))));

  (* Inbound and Outbound are independent namespaces: an inbound deny on the
     sending subnet says nothing about traffic leaving it. *)
  "inbound_deny_does_not_filter_egress" >:: (fun _ ->
    let (world, _, s1, _) = two_subnet_world () in
    let world = attach_nsg_to_subnet (make_nsg "n" [deny_all_in 100]) s1 world in
    assert_bool "an inbound rule must not be scanned for the outbound direction"
      (reachable world (Subnet.get_address s1) (packet "10.0.1.4" "10.0.2.5")));

  "outbound_deny_blocks_egress" >:: (fun _ ->
    let (world, _, s1, _) = two_subnet_world () in
    let nsg = make_nsg "n"
      [ rule ~name:"deny-all-out" ~priority:100 ~direction:Outbound ~access:Deny
          ~source:Nsg.SecurityRule.Any ~destination:Nsg.SecurityRule.Any () ] in
    let world = attach_nsg_to_subnet nsg s1 world in
    assert_bool "an outbound deny on the sender stops the packet"
      (not (reachable world (Subnet.get_address s1) (packet "10.0.1.4" "10.0.2.5"))));

  "no_nsg_means_no_filtering" >:: (fun _ ->
    let (world, _, s1, _) = two_subnet_world () in
    assert_bool "a subnet with no NSG attached filters nothing"
      (reachable world (Subnet.get_address s1) (packet "203.0.113.9" "10.0.2.5")));

  (* AllowVnetInBound is VirtualNetwork -> VirtualNetwork; anything else falls
     to DenyAllInBound. *)
  "default_allows_in_vnet_traffic" >:: (fun _ ->
    let (world, _, s1, s2) = two_subnet_world () in
    let world = attach_nsg_to_subnet falls_through_nsg s2 world in
    assert_bool "AllowVnetInBound admits a source inside the VNet"
      (reachable world (Subnet.get_address s1) (packet "10.0.1.4" "10.0.2.5")));

  "default_denies_inbound_from_outside_vnet" >:: (fun _ ->
    let (world, _, s1, s2) = two_subnet_world () in
    let world = attach_nsg_to_subnet falls_through_nsg s2 world in
    assert_bool "DenyAllInBound catches a source outside the VNet"
      (not (reachable world (Subnet.get_address s1) (packet "203.0.113.9" "10.0.2.5"))));

  (* AllowAzureLoadBalancerInBound at 65001: the tag is the host VIP. *)
  "default_admits_host_vip_probe" >:: (fun _ ->
    let (world, _, s1, s2) = two_subnet_world () in
    let world = attach_nsg_to_subnet falls_through_nsg s2 world in
    assert_bool "a probe from 168.63.129.16 is admitted by default"
      (reachable world (Subnet.get_address s1) (packet "168.63.129.16" "10.0.2.5")));

  "port_outside_the_rule_range_falls_through" >:: (fun _ ->
    let (world, _, s1, s2) = two_subnet_world () in
    let nsg = make_nsg "n"
      [ rule ~name:"allow-https" ~priority:100 ~direction:Inbound ~access:Allow
          ~protocol:Tcp ~ports:[Single 443] ~source:Nsg.SecurityRule.Any
          ~destination:Nsg.SecurityRule.Any ();
        deny_all_in 200 ] in
    let world = attach_nsg_to_subnet nsg s2 world in
    let src = Subnet.get_address s1 in
    assert_bool "443 matches the allow"
      (reachable world src (packet_on ~dest_port:443 "10.0.1.4" "10.0.2.5"));
    assert_bool "80 falls past it to the deny"
      (not (reachable world src (packet_on ~dest_port:80 "10.0.1.4" "10.0.2.5"))));

  "protocol_outside_the_rule_falls_through" >:: (fun _ ->
    let (world, _, s1, s2) = two_subnet_world () in
    let nsg = make_nsg "n"
      [ rule ~name:"allow-tcp" ~priority:100 ~direction:Inbound ~access:Allow
          ~protocol:Tcp ~source:Nsg.SecurityRule.Any
          ~destination:Nsg.SecurityRule.Any ();
        deny_all_in 200 ] in
    let world = attach_nsg_to_subnet nsg s2 world in
    let src = Subnet.get_address s1 in
    assert_bool "TCP matches the allow"
      (reachable world src (packet_on ~protocol:Tcp "10.0.1.4" "10.0.2.5"));
    assert_bool "UDP falls past it to the deny"
      (not (reachable world src (packet_on ~protocol:Udp "10.0.1.4" "10.0.2.5"))));

  "port_range_endpoints_are_inclusive" >:: (fun _ ->
    let (world, _, s1, s2) = two_subnet_world () in
    let nsg = make_nsg "n"
      [ rule ~name:"allow-range" ~priority:100 ~direction:Inbound ~access:Allow
          ~ports:[Range (8000, 8100)] ~source:Nsg.SecurityRule.Any
          ~destination:Nsg.SecurityRule.Any ();
        deny_all_in 200 ] in
    let world = attach_nsg_to_subnet nsg s2 world in
    let src = Subnet.get_address s1 in
    assert_bool "8000 is inside the range"
      (reachable world src (packet_on ~dest_port:8000 "10.0.1.4" "10.0.2.5"));
    assert_bool "8100 is inside the range"
      (reachable world src (packet_on ~dest_port:8100 "10.0.1.4" "10.0.2.5"));
    assert_bool "8101 is outside it"
      (not (reachable world src (packet_on ~dest_port:8101 "10.0.1.4" "10.0.2.5"))));

]

(* --- Service tags in user rules ---

   Doc anchor (https://learn.microsoft.com/en-us/azure/virtual-network/service-tags-overview):
   VirtualNetwork is "the virtual network address space ..., peered virtual
   networks, ... the virtual IP address of the host, and address prefixes used
   on user-defined routes"; Internet is "the IP address space that's outside the
   virtual network and reachable by the public internet". *)

let allow_from_tag tag =
  make_nsg "tagged"
    [ rule ~name:("allow-" ^ tag) ~priority:100 ~direction:Inbound ~access:Allow
        ~source:(Nsg.SecurityRule.ServiceTags [tag])
        ~destination:Nsg.SecurityRule.Any ();
      deny_all_in 4000 ]

let service_tag_tests = "service_tags" >::: [

  "virtual_network_tag_matches_in_vnet_source" >:: (fun _ ->
    let (world, _, s1, s2) = two_subnet_world () in
    let world = attach_nsg_to_subnet (allow_from_tag "VirtualNetwork") s2 world in
    assert_bool "the priority-100 VirtualNetwork allow is matched, not the deny"
      (reachable world (Subnet.get_address s1) (packet "10.0.1.4" "10.0.2.5")));

  "virtual_network_tag_deny_blocks_in_vnet_source" >:: (fun _ ->
    let (world, _, s1, s2) = two_subnet_world () in
    let nsg = make_nsg "n"
      [ rule ~name:"deny-vnet" ~priority:100 ~direction:Inbound ~access:Deny
          ~source:(Nsg.SecurityRule.ServiceTags ["VirtualNetwork"])
          ~destination:Nsg.SecurityRule.Any () ] in
    let world = attach_nsg_to_subnet nsg s2 world in
    assert_bool "a VirtualNetwork deny must actually match"
      (not (reachable world (Subnet.get_address s1) (packet "10.0.1.4" "10.0.2.5"))));

  "internet_tag_does_not_match_a_vnet_source" >:: (fun _ ->
    let (world, _, s1, s2) = two_subnet_world () in
    let world = attach_nsg_to_subnet (allow_from_tag "Internet") s2 world in
    assert_bool "a private in-VNet address is not in the Internet tag"
      (not (reachable world (Subnet.get_address s1) (packet "10.0.1.4" "10.0.2.5"))));

  "internet_tag_matches_a_public_source" >:: (fun _ ->
    let (world, _, s1, s2) = two_subnet_world () in
    let world = attach_nsg_to_subnet (allow_from_tag "Internet") s2 world in
    assert_bool "a public address is in the Internet tag"
      (reachable world (Subnet.get_address s1) (packet "203.0.113.9" "10.0.2.5")));

  (* Loopback and link-local are not "reachable by the public internet". *)
  "internet_tag_excludes_non_routable_space" >:: (fun _ ->
    let (world, _, s1, s2) = two_subnet_world () in
    let world = attach_nsg_to_subnet (allow_from_tag "Internet") s2 world in
    assert_bool "169.254.0.0/16 is not in the Internet tag"
      (not (reachable world (Subnet.get_address s1) (packet "169.254.1.1" "10.0.2.5"))));

  "azure_load_balancer_tag_is_the_host_vip" >:: (fun _ ->
    let (world, _, s1, s2) = two_subnet_world () in
    let world = attach_nsg_to_subnet (allow_from_tag "AzureLoadBalancer") s2 world in
    let src = Subnet.get_address s1 in
    assert_bool "168.63.129.16 matches"
      (reachable world src (packet "168.63.129.16" "10.0.2.5"));
    assert_bool "an in-VNet address does not"
      (not (reachable world src (packet "10.0.1.4" "10.0.2.5"))));

  (* "address prefixes used on user-defined routes" are part of the tag. *)
  "virtual_network_tag_covers_route_table_prefixes" >:: (fun _ ->
    let (world, _, s1, s2) = two_subnet_world () in
    let rt = make_rt "rt" [udr "to-onprem" "192.168.0.0/16" VirtualNetwork] in
    let world =
      world |> attach_rt_to_subnet rt s2
      |> attach_nsg_to_subnet (allow_from_tag "VirtualNetwork") s2
    in
    assert_bool "a source inside a UDR prefix is in the VirtualNetwork tag"
      (reachable world (Subnet.get_address s1) (packet "192.168.5.5" "10.0.2.5")));

  "unresolved_service_tag_matches_nothing" >:: (fun _ ->
    let (world, _, s1, s2) = two_subnet_world () in
    let world = attach_nsg_to_subnet (allow_from_tag "Storage") s2 world in
    assert_bool "Storage needs Azure's published prefix list, so it cannot match"
      (not (reachable world (Subnet.get_address s1) (packet "10.0.1.4" "10.0.2.5"))));

]

(* --- Application Security Groups ---

   Doc anchor (https://learn.microsoft.com/en-us/azure/virtual-network/application-security-groups):
   an ASG names a set of NICs, and a rule using it applies to those NICs'
   addresses rather than to the whole subnet. *)

let asg_tests = "application_security_groups" >::: [

  "asg_rule_matches_a_member_address" >:: (fun _ ->
    let (world, _, s1, s2) = two_subnet_world () in
    let asg = make_asg "web" in
    let member = make_nic ~forwards:false "web0" s1 "10.0.1.4" in
    let nsg = make_nsg "n"
      [ rule ~name:"allow-from-asg" ~priority:100 ~direction:Inbound ~access:Allow
          ~source:(Nsg.SecurityRule.ApplicationGroups [Asg.get_address asg])
          ~destination:Nsg.SecurityRule.Any ();
        deny_all_in 4000 ] in
    let world =
      world |> add_nic_to_world member |> add_asg_members asg [member]
      |> attach_nsg_to_subnet nsg s2
    in
    assert_bool "the member's own address matches the ASG rule"
      (reachable world (Subnet.get_address s1) (packet "10.0.1.4" "10.0.2.5")));

  (* The whole point of an ASG is that it is narrower than the subnet. *)
  "asg_rule_does_not_match_a_non_member_in_the_same_subnet" >:: (fun _ ->
    let (world, _, s1, s2) = two_subnet_world () in
    let asg = make_asg "web" in
    let member = make_nic ~forwards:false "web0" s1 "10.0.1.4" in
    let nsg = make_nsg "n"
      [ rule ~name:"allow-from-asg" ~priority:100 ~direction:Inbound ~access:Allow
          ~source:(Nsg.SecurityRule.ApplicationGroups [Asg.get_address asg])
          ~destination:Nsg.SecurityRule.Any ();
        deny_all_in 4000 ] in
    let world =
      world |> add_nic_to_world member |> add_asg_members asg [member]
      |> attach_nsg_to_subnet nsg s2
    in
    assert_bool "a neighbour that is not in the ASG is still denied"
      (not (reachable world (Subnet.get_address s1) (packet "10.0.1.9" "10.0.2.5"))));

]

(* --- NIC-level NSGs ---

   Doc anchor (https://learn.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview,
   "How network security groups filter network traffic"): with an NSG on both
   the subnet and the NIC, inbound is filtered subnet-then-NIC and outbound
   NIC-then-subnet, and both must allow the packet. *)

let nic_nsg_tests = "nic_nsgs" >::: [

  "nic_nsg_denies_inbound_where_the_subnet_allows" >:: (fun _ ->
    let (world, _, s1, s2) = two_subnet_world () in
    let target = make_nic ~forwards:false "vm2" s2 "10.0.2.5" in
    let world =
      world |> add_nic_to_world target
      |> attach_nsg_to_nic (make_nsg "nic-deny" [deny_all_in 100]) target
    in
    assert_bool "the destination NIC's own NSG must be scanned"
      (not (reachable world (Subnet.get_address s1) (packet "10.0.1.4" "10.0.2.5"))));

  "nic_nsg_denies_outbound_on_the_sender" >:: (fun _ ->
    let (world, _, s1, _) = two_subnet_world () in
    let sender = make_nic ~forwards:false "vm1" s1 "10.0.1.4" in
    let nsg = make_nsg "nic-deny-out"
      [ rule ~name:"deny-all-out" ~priority:100 ~direction:Outbound ~access:Deny
          ~source:Nsg.SecurityRule.Any ~destination:Nsg.SecurityRule.Any () ] in
    let world =
      world |> add_nic_to_world sender |> attach_nsg_to_nic nsg sender
    in
    assert_bool "the sending NIC's own NSG must be scanned"
      (not (reachable world (Subnet.get_address s1) (packet "10.0.1.4" "10.0.2.5"))));

  "nic_nsg_only_applies_to_its_own_address" >:: (fun _ ->
    let (world, _, s1, s2) = two_subnet_world () in
    let target = make_nic ~forwards:false "vm2" s2 "10.0.2.5" in
    let world =
      world |> add_nic_to_world target
      |> attach_nsg_to_nic (make_nsg "nic-deny" [deny_all_in 100]) target
    in
    assert_bool "a neighbour address in the same subnet is unaffected"
      (reachable world (Subnet.get_address s1) (packet "10.0.1.4" "10.0.2.9")));

]

(* --- Subnet addressing ---

   Doc anchor (https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-manage-subnet):
   a subnet can carry several address prefixes, and Azure reserves the first
   four addresses and the last of every prefix. *)

let subnet_addressing_tests = "subnet_addressing" >::: [

  "delivery_uses_every_address_prefix" >:: (fun _ ->
    let vnet = make_vnet ~addresses:[cidr "10.0.0.0/16"] "vnet1" in
    let s1 = make_subnet vnet "subnet1" "10.0.1.0/24" in
    let s2 =
      Subnet.make ~name:"subnet2" ~subscription:"DEFAULT"
        ~address:"azurerm_subnet.subnet2" ~resource_group:test_rg ~vnet
        ~addresses:[cidr "10.0.2.0/24"; cidr "10.0.3.0/24"]
    in
    let world =
      World.empty |> add_vnet_to_world vnet
      |> add_subnet_to_world s1 |> add_subnet_to_world s2
    in
    assert_bool "a destination in the second prefix is still owned by the subnet"
      (reachable world (Subnet.get_address s1) (packet "10.0.1.4" "10.0.3.5")));

  "reserved_addresses_are_not_deliverable" >:: (fun _ ->
    let (world, _, s1, _) = two_subnet_world () in
    let src = Subnet.get_address s1 in
    assert_bool "the network address is reserved"
      (not (reachable world src (packet "10.0.1.4" "10.0.2.0")));
    assert_bool "the default gateway address is reserved"
      (not (reachable world src (packet "10.0.1.4" "10.0.2.1")));
    assert_bool "the DNS address is reserved"
      (not (reachable world src (packet "10.0.1.4" "10.0.2.2")));
    assert_bool "the fourth address is reserved"
      (not (reachable world src (packet "10.0.1.4" "10.0.2.3")));
    assert_bool "the broadcast address is reserved"
      (not (reachable world src (packet "10.0.1.4" "10.0.2.255")));
    assert_bool "the first assignable address is deliverable"
      (reachable world src (packet "10.0.1.4" "10.0.2.4")));

]

(* --- VNet peering ---

   Doc anchor (https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-udr-overview,
   "Optional default routes"): peering adds "a route for each address range
   within the address space of each virtual network involved in the peering".
   allowVirtualNetworkAccess gates whether the local VNet's VMs may reach the
   remote ones. Peering is not transitive. *)

let peered_world ~access =
  let vnet_a = make_vnet ~addresses:[cidr "10.0.0.0/16"] "vnet_a" in
  let vnet_b = make_vnet ~addresses:[cidr "10.1.0.0/16"] "vnet_b" in
  let a1 = make_subnet vnet_a "a1" "10.0.1.0/24" in
  let b1 = make_subnet vnet_b "b1" "10.1.1.0/24" in
  let world =
    World.empty |> add_vnet_to_world vnet_a |> add_vnet_to_world vnet_b
    |> add_subnet_to_world a1 |> add_subnet_to_world b1
    |> add_peering_to_world (make_peering "ab" ~local:vnet_a ~remote:vnet_b ~access)
    |> add_peering_to_world (make_peering "ba" ~local:vnet_b ~remote:vnet_a ~access)
  in
  (world, Subnet.get_address a1)

let peering_tests = "vnet_peering" >::: [

  "peered_vnets_deliver" >:: (fun _ ->
    let (world, src) = peered_world ~access:true in
    assert_bool "the peering route delivers into the remote VNet"
      (reachable world src (packet "10.0.1.4" "10.1.1.5")));

  "peering_without_virtual_network_access_blocks" >:: (fun _ ->
    let (world, src) = peered_world ~access:false in
    assert_bool "allowVirtualNetworkAccess = false stops the traffic"
      (not (reachable world src (packet "10.0.1.4" "10.1.1.5"))));

  "unpeered_vnets_do_not_deliver" >:: (fun _ ->
    let vnet_a = make_vnet ~addresses:[cidr "10.0.0.0/16"] "vnet_a" in
    let vnet_b = make_vnet ~addresses:[cidr "10.1.0.0/16"] "vnet_b" in
    let a1 = make_subnet vnet_a "a1" "10.0.1.0/24" in
    let b1 = make_subnet vnet_b "b1" "10.1.1.0/24" in
    let world =
      World.empty |> add_vnet_to_world vnet_a |> add_vnet_to_world vnet_b
      |> add_subnet_to_world a1 |> add_subnet_to_world b1
    in
    assert_bool "without a peering the reserved drop route catches it"
      (not (reachable world (Subnet.get_address a1) (packet "10.0.1.4" "10.1.1.5"))));

  (* The VirtualNetwork tag covers peered address space. *)
  "peered_space_is_in_the_virtual_network_tag" >:: (fun _ ->
    let (world, src) = peered_world ~access:true in
    let b1_addr = "azurerm_subnet.b1" in
    let world =
      { world with assocs = { world.assocs with
          subnet_nsg = AddressMap.add b1_addr (allow_from_tag "VirtualNetwork")
                         world.assocs.subnet_nsg } }
    in
    assert_bool "a source in the peer's space matches the VirtualNetwork tag"
      (reachable world src (packet "10.0.1.4" "10.1.1.5")));

]

(* --- Appliance next-hop scoping ---

   Doc anchor (https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-udr-overview,
   "Virtual appliance"): "A next hop private IP address must have direct
   connectivity without having to route through an Azure ExpressRoute gateway
   or through Azure Virtual WAN. Setting the next hop to an IP address without
   direct connectivity results in an invalid UDR configuration." *)

let appliance_scope_tests = "appliance_scope" >::: [

  "next_hop_in_an_unpeered_vnet_is_not_a_candidate" >:: (fun _ ->
    let vnet_a = make_vnet ~addresses:[cidr "10.0.0.0/16"] "vnet_a" in
    let vnet_b = make_vnet ~addresses:[cidr "172.16.0.0/16"; cidr "10.5.0.0/16"] "vnet_b" in
    let a1 = make_subnet vnet_a "a1" "10.0.1.0/24" in
    let b1 = make_subnet vnet_b "b1" "172.16.1.0/24" in
    let b2 = make_subnet vnet_b "b2" "10.5.0.0/24" in
    let nva = make_nic ~forwards:true "nva" b1 "172.16.1.10" in
    let rt = make_rt "rt_a" [appliance_udr "to-other-vnet" "10.5.0.0/16" "172.16.1.10"] in
    let world =
      World.empty |> add_vnet_to_world vnet_a |> add_vnet_to_world vnet_b
      |> add_subnet_to_world a1 |> add_subnet_to_world b1 |> add_subnet_to_world b2
      |> add_nic_to_world nva |> attach_rt_to_subnet rt a1
    in
    assert_bool "a NIC in an unpeered VNet cannot be a next hop"
      (not (reachable world (Subnet.get_address a1) (packet "10.0.1.4" "10.5.0.5"))));

  "appliance_nic_nsg_is_scanned_on_the_way_through" >:: (fun _ ->
    let vnet = make_vnet ~addresses:[cidr "10.0.0.0/16"] "vnet1" in
    let src = make_subnet vnet "subnet_src" "10.0.0.0/24" in
    let nva_subnet = make_subnet vnet "subnet_nva" "10.0.1.0/24" in
    let dst = make_subnet vnet "subnet_dst" "10.0.2.0/24" in
    let nva = make_nic ~forwards:true "nva" nva_subnet "10.0.1.10" in
    let rt = make_rt "rt_src" [appliance_udr "to-nva" "10.0.2.0/24" "10.0.1.10"] in
    let world =
      World.empty |> add_vnet_to_world vnet
      |> add_subnet_to_world src |> add_subnet_to_world nva_subnet
      |> add_subnet_to_world dst |> add_nic_to_world nva
      |> attach_rt_to_subnet rt src
      |> attach_nsg_to_nic (make_nsg "nva-deny" [deny_all_in 100]) nva
    in
    assert_bool "an NSG on the appliance NIC stops the transit packet"
      (not (reachable world (Subnet.get_address src) (packet "10.0.0.4" "10.0.2.5"))));

]

let () =
  run_test_tt_main ("reference_reachability" >::: [
    intra_subnet_routing_tests;
    reserved_prefix_tests;
    appliance_routing_tests;
    appliance_scope_tests;
    nsg_rule_tests;
    service_tag_tests;
    asg_tests;
    nic_nsg_tests;
    subnet_addressing_tests;
    peering_tests;
  ])
