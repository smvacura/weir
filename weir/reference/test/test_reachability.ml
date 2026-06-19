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

let add_subnet_to_world subnet (world : World.t) =
  { world with subnets = AddressMap.add (Subnet.get_address subnet) subnet world.subnets }

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

let () =
  run_test_tt_main ("reference_reachability" >::: [
    intra_subnet_routing_tests;
    reserved_prefix_tests;
  ])
