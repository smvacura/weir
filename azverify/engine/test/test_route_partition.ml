open OUnit2
open Parser.Network_types
open Parser.Azure_types
open Azureir

let test_rg =
  Rg.make
    ~name:"test-rg"
    ~subscription:"DEFAULT"
    ~address:"azurerm_resource_group.test"
    ~location:EastUs
    ~managed_by:None
    ~tags:[]

let make_route name cidr_str =
  Route_table.Route.make
    ~name
    ~address_prefix:(Option.get (CIDR.of_string_opt cidr_str))
    ~next_hop:Internet
    ~next_hop_in_ip_address:None

let make_rt routes =
  Route_table.make
    ~name:"test-rt"
    ~subscription:"DEFAULT"
    ~address:"azurerm_route_table.test"
    ~location:EastUs
    ~resource_group:test_rg
    ~disable_bgp_route_propagation:false
    ~routes
    ~tags:[]

let sorted_partitions result route =
  match Hashtbl.find_opt result route with
  | Some l -> List.sort compare l
  | None -> []

let partition_tests = "partition_tests" >::: [
  "single_route" >:: (fun _ ->
    let route_a = make_route "route-a" "10.0.0.0/8" in
    let result = Pathfinder.Route_partition.partition_routes (make_rt [route_a]) in
    let lo, hi = CIDR.get_interval (Route_table.Route.get_prefix route_a) in
    assert_equal [(lo, hi)] (sorted_partitions result route_a));

  "disjoint_routes" >:: (fun _ ->
    let route_a = make_route "route-a" "10.0.0.0/8" in
    let route_b = make_route "route-b" "192.168.0.0/16" in
    let result = Pathfinder.Route_partition.partition_routes (make_rt [route_a; route_b]) in
    let lo_a, hi_a = CIDR.get_interval (Route_table.Route.get_prefix route_a) in
    let lo_b, hi_b = CIDR.get_interval (Route_table.Route.get_prefix route_b) in
    assert_equal [(lo_a, hi_a)] (sorted_partitions result route_a);
    assert_equal [(lo_b, hi_b)] (sorted_partitions result route_b));

  "overlapping_routes" >:: (fun _ ->
    let route_a = make_route "route-a" "10.0.0.0/8" in
    let route_b = make_route "route-b" "10.1.0.0/16" in
    let result = Pathfinder.Route_partition.partition_routes (make_rt [route_a; route_b]) in
    let lo_a, hi_a = CIDR.get_interval (Route_table.Route.get_prefix route_a) in
    let lo_b, hi_b = CIDR.get_interval (Route_table.Route.get_prefix route_b) in
    assert_equal
      [(lo_b, hi_b)]
      (sorted_partitions result route_b);
    assert_equal
      (List.sort compare [(lo_a, Int32.sub lo_b 1l); (Int32.add hi_b 1l, hi_a)])
      (sorted_partitions result route_a));
]

let suite = "route_partition_suite" >::: [partition_tests]

let () = run_test_tt_main suite
