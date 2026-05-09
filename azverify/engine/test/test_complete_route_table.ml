open OUnit2
open Parser.Network_types
open Parser.Azure_types
open Terraform_ir

module CRT = Pathfinder.Complete_route_table

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

let make_subnet vnet name cidr_strs =
  Subnet.make
    ~name
    ~subscription:"DEFAULT"
    ~address:("azurerm_subnet." ^ name)
    ~resource_group:test_rg
    ~vnet
    ~addresses:(List.map cidr cidr_strs)

let make_udr name cidr_str =
  Route_table.Route.make
    ~name
    ~address_prefix:(cidr cidr_str)
    ~next_hop:Drop
    ~next_hop_in_ip_address:None
    ~source:UserDefined

let make_rt routes =
  Route_table.make
    ~name:"test-rt"
    ~subscription:"DEFAULT"
    ~address:"azurerm_route_table.test"
    ~location:EastUs
    ~resource_group:test_rg
    ~disable_bgp_route_propagation:true
    ~routes
    ~tags:[]

let subnet_index vnet subnets =
  Pathfinder.Utils.VnetMap.(add vnet subnets empty)

let enrich ?(udrs = []) vnet subnets =
  CRT.get_routes (CRT.enrich_route_table (make_rt udrs) vnet (subnet_index vnet subnets))

(* --- Helpers --- *)

let show_contains route sub =
  let s = Route_table.Route.show route in
  let sn = String.length s and m = String.length sub in
  let rec go i = i <= sn - m && (String.sub s i m = sub || go (i + 1)) in
  go 0

let find_route routes prefix_str =
  let target = cidr prefix_str in
  List.find_opt (fun r -> CIDR.compare (Route_table.Route.get_prefix r) target = 0) routes

let assert_route_hop routes prefix_str expected_hop =
  match find_route routes prefix_str with
  | None ->
    assert_failure (Printf.sprintf "expected a route for %s" prefix_str)
  | Some r ->
    assert_bool
      (Printf.sprintf "route for %s: expected next_hop containing %S, got: %s"
         prefix_str expected_hop (Route_table.Route.show r))
      (show_contains r expected_hop)

let count_routes_for routes prefix_str =
  let target = cidr prefix_str in
  List.length (List.filter (fun r -> CIDR.compare (Route_table.Route.get_prefix r) target = 0) routes)

(* --- Tests --- *)

(* VNet-local system routes: one VirtualNetwork route per subnet CIDR. *)
let vnet_local_tests = "vnet_local_routes" >::: [

  "single_subnet_single_cidr" >:: (fun _ ->
    let vnet = make_vnet "vnet" in
    let subnet = make_subnet vnet "subnet-a" ["10.0.1.0/24"] in
    let routes = enrich vnet [subnet] in
    assert_route_hop routes "10.0.1.0/24" "VirtualNetwork");

  "two_subnets_produce_separate_routes" >:: (fun _ ->
    let vnet = make_vnet "vnet" in
    let sa = make_subnet vnet "subnet-a" ["10.0.1.0/24"] in
    let sb = make_subnet vnet "subnet-b" ["10.0.2.0/24"] in
    let routes = enrich vnet [sa; sb] in
    assert_route_hop routes "10.0.1.0/24" "VirtualNetwork";
    assert_route_hop routes "10.0.2.0/24" "VirtualNetwork");

  (* A dual-stack or dual-prefix subnet produces one VirtualNetwork route per CIDR. *)
  "subnet_with_two_cidrs" >:: (fun _ ->
    let vnet = make_vnet "vnet" in
    let subnet = make_subnet vnet "subnet-a" ["10.0.1.0/24"; "10.0.2.0/24"] in
    let routes = enrich vnet [subnet] in
    assert_route_hop routes "10.0.1.0/24" "VirtualNetwork";
    assert_route_hop routes "10.0.2.0/24" "VirtualNetwork");

]

(* Default system routes present on every Azure subnet. *)
let default_system_route_tests = "default_system_routes" >::: [

  "default_internet_route" >:: (fun _ ->
    let vnet = make_vnet "vnet" in
    let subnet = make_subnet vnet "subnet-a" ["10.0.1.0/24"] in
    let routes = enrich vnet [subnet] in
    assert_route_hop routes "0.0.0.0/0" "Internet");

  (* Azure drops traffic to RFC 1918 / RFC 6598 ranges not covered by the VNet
     by adding four None (Drop) system routes. *)
  "rfc1918_and_shared_space_drop_routes" >:: (fun _ ->
    let vnet = make_vnet "vnet" in
    let subnet = make_subnet vnet "subnet-a" ["10.0.1.0/24"] in
    let routes = enrich vnet [subnet] in
    assert_route_hop routes "10.0.0.0/8"     "Drop";
    assert_route_hop routes "172.16.0.0/12"  "Drop";
    assert_route_hop routes "192.168.0.0/16" "Drop";
    assert_route_hop routes "100.64.0.0/10"  "Drop");

]

(* User-defined routes (UDRs) with the exact same prefix as a system route
   override that system route; the system route must not appear in the table. *)
let override_tests = "user_route_overrides" >::: [

  "udr_overrides_internet_default" >:: (fun _ ->
    let vnet = make_vnet "vnet" in
    let subnet = make_subnet vnet "subnet-a" ["10.0.1.0/24"] in
    let udr = make_udr "force-drop-default" "0.0.0.0/0" in
    let routes = enrich ~udrs:[udr] vnet [subnet] in
    (* UDR must be present and the Internet system route must be absent *)
    assert_route_hop routes "0.0.0.0/0" "Drop";
    assert_equal 1 (count_routes_for routes "0.0.0.0/0")
      ~msg:"only one 0.0.0.0/0 route should exist when UDR overrides the default");

  "udr_overrides_rfc1918_drop_route" >:: (fun _ ->
    let vnet = make_vnet "vnet" in
    let subnet = make_subnet vnet "subnet-a" ["10.0.1.0/24"] in
    let udr = make_udr "custom-10" "10.0.0.0/8" in
    let routes = enrich ~udrs:[udr] vnet [subnet] in
    assert_route_hop routes "10.0.0.0/8" "Drop";
    assert_equal 1 (count_routes_for routes "10.0.0.0/8")
      ~msg:"only one 10.0.0.0/8 route should exist when UDR overrides the system None route");

  (* A UDR at a more-specific prefix does NOT suppress the system route at the
     covering prefix — both coexist and LPM picks the winner at forwarding time. *)
  "more_specific_udr_does_not_suppress_system_route" >:: (fun _ ->
    let vnet = make_vnet "vnet" in
    let subnet = make_subnet vnet "subnet-a" ["10.0.1.0/24"] in
    let udr = make_udr "custom-specific" "10.1.0.0/24" in
    let routes = enrich ~udrs:[udr] vnet [subnet] in
    assert_route_hop routes "10.0.0.0/8" "Drop";
    assert_route_hop routes "10.1.0.0/24" "Drop");

  "udr_at_unrelated_prefix_preserved" >:: (fun _ ->
    let vnet = make_vnet "vnet" in
    let subnet = make_subnet vnet "subnet-a" ["10.0.1.0/24"] in
    let udr = make_udr "custom-docs" "203.0.113.0/24" in
    let routes = enrich ~udrs:[udr] vnet [subnet] in
    assert_route_hop routes "203.0.113.0/24" "Drop");

]

let suite = "complete_route_table_suite" >::: [
  vnet_local_tests;
  default_system_route_tests;
  override_tests;
]

let () = run_test_tt_main suite
