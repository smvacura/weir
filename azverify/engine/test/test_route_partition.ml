open OUnit2
open Parser.Network_types
open Parser.Azure_types
open Terraform_ir

let test_rg =
  Rg.make
    ~name:"test-rg"
    ~subscription:"DEFAULT"
    ~address:"azurerm_resource_group.test"
    ~location:EastUs
    ~managed_by:None
    ~tags:[]

let make_route ?(source = UserDefined) name cidr_str =
  Route_table.Route.make
    ~name
    ~address_prefix:(Option.get (CIDR.of_string_opt cidr_str))
    ~next_hop:Internet
    ~next_hop_in_ip_address:None
    ~source

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

let show_intervals ivs =
  "[" ^ String.concat "; " (List.map (fun (lo, hi) ->
    Printf.sprintf "(%ld,%ld)" lo hi) ivs) ^ "]"

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

  (* Two /16s nested inside a /8, with a gap between them.
     route_a owns three fragments: before route_b, between route_b and route_c, after route_c. *)
  "two_nested_routes" >:: (fun _ ->
    let route_a = make_route "route-a" "10.0.0.0/8" in
    let route_b = make_route "route-b" "10.1.0.0/16" in
    let route_c = make_route "route-c" "10.3.0.0/16" in
    let result = Pathfinder.Route_partition.partition_routes (make_rt [route_a; route_b; route_c]) in
    let lo_a, hi_a = CIDR.get_interval (Route_table.Route.get_prefix route_a) in
    let lo_b, hi_b = CIDR.get_interval (Route_table.Route.get_prefix route_b) in
    let lo_c, hi_c = CIDR.get_interval (Route_table.Route.get_prefix route_c) in
    assert_equal [(lo_b, hi_b)] (sorted_partitions result route_b);
    assert_equal [(lo_c, hi_c)] (sorted_partitions result route_c);
    assert_equal
      (List.sort compare [
        (lo_a, Int32.sub lo_b 1l);
        (Int32.add hi_b 1l, Int32.sub lo_c 1l);
        (Int32.add hi_c 1l, hi_a)])
      (sorted_partitions result route_a));

  (* Three levels: /8 contains /16 which contains /24.
     Each route owns the portion of its range not covered by a more-specific child. *)
  "three_levels_of_nesting" >:: (fun _ ->
    let route_a = make_route "route-a" "10.0.0.0/8" in
    let route_b = make_route "route-b" "10.1.0.0/16" in
    let route_c = make_route "route-c" "10.1.1.0/24" in
    let result = Pathfinder.Route_partition.partition_routes (make_rt [route_a; route_b; route_c]) in
    let lo_a, hi_a = CIDR.get_interval (Route_table.Route.get_prefix route_a) in
    let lo_b, hi_b = CIDR.get_interval (Route_table.Route.get_prefix route_b) in
    let lo_c, hi_c = CIDR.get_interval (Route_table.Route.get_prefix route_c) in
    assert_equal [(lo_c, hi_c)] (sorted_partitions result route_c);
    assert_equal
      (List.sort compare [(lo_b, Int32.sub lo_c 1l); (Int32.add hi_c 1l, hi_b)])
      (sorted_partitions result route_b);
    assert_equal
      (List.sort compare [(lo_a, Int32.sub lo_b 1l); (Int32.add hi_b 1l, hi_a)])
      (sorted_partitions result route_a));
]

let source_priority_tests = "source_priority_tests" >::: [

  (* UDR and System at identical prefix: UDR owns the entire range, System owns nothing.
     Uses 0.0.0.0/0 to exercise the full unsigned address space. *)
  "udr_shadows_system_same_prefix" >:: (fun _ ->
    let sys = make_route ~source:System      "sys" "0.0.0.0/0" in
    let udr = make_route ~source:UserDefined "udr" "0.0.0.0/0" in
    let result = Pathfinder.Route_partition.partition_routes (make_rt [sys; udr]) in
    let lo, hi = CIDR.get_interval (Route_table.Route.get_prefix udr) in
    assert_equal [(lo, hi)] (sorted_partitions result udr)
      ~msg:"UDR should own the full range";
    assert_equal [] (sorted_partitions result sys)
      ~msg:"System route should own nothing when shadowed");

  (* BGP and System at identical prefix: BGP wins. *)
  "bgp_shadows_system_same_prefix" >:: (fun _ ->
    let sys = make_route ~source:System "sys" "0.0.0.0/0" in
    let bgp = make_route ~source:Bgp    "bgp" "0.0.0.0/0" in
    let result = Pathfinder.Route_partition.partition_routes (make_rt [sys; bgp]) in
    let lo, hi = CIDR.get_interval (Route_table.Route.get_prefix bgp) in
    assert_equal [(lo, hi)] (sorted_partitions result bgp)
      ~msg:"BGP route should own the full range";
    assert_equal [] (sorted_partitions result sys)
      ~msg:"System route should own nothing when shadowed by BGP");

  (* UDR and BGP at identical prefix: UDR wins. *)
  "udr_shadows_bgp_same_prefix" >:: (fun _ ->
    let bgp = make_route ~source:Bgp        "bgp" "0.0.0.0/0" in
    let udr = make_route ~source:UserDefined "udr" "0.0.0.0/0" in
    let result = Pathfinder.Route_partition.partition_routes (make_rt [bgp; udr]) in
    let lo, hi = CIDR.get_interval (Route_table.Route.get_prefix udr) in
    assert_equal [(lo, hi)] (sorted_partitions result udr)
      ~msg:"UDR should own the full range";
    assert_equal [] (sorted_partitions result bgp)
      ~msg:"BGP route should own nothing when shadowed by UDR");

  (* Realistic Azure fragment: System /0 (Internet default) with a UDR shadowing
     the System /8 (RFC1918 drop), leaving System /0 to own the remainder. *)
  "udr_shadows_system_inner_prefix_system_owns_remainder" >:: (fun _ ->
    let sys0  = make_route ~source:System      "sys-0"  "0.0.0.0/0" in
    let sys8  = make_route ~source:System      "sys-8"  "10.0.0.0/8" in
    let udr8  = make_route ~source:UserDefined "udr-8"  "10.0.0.0/8" in
    let result = Pathfinder.Route_partition.partition_routes (make_rt [sys0; sys8; udr8]) in
    let lo0, hi0 = CIDR.get_interval (Route_table.Route.get_prefix sys0) in
    let lo8, hi8 = CIDR.get_interval (Route_table.Route.get_prefix udr8) in
    assert_equal [(lo8, hi8)] (sorted_partitions result udr8)
      ~printer:show_intervals
      ~msg:"UDR should own the /8 range";
    assert_equal [] (sorted_partitions result sys8)
      ~printer:show_intervals
      ~msg:"System /8 should own nothing when shadowed";
    assert_equal
      (List.sort compare [(lo0, Int32.sub lo8 1l); (Int32.add hi8 1l, hi0)])
      (sorted_partitions result sys0)
      ~printer:show_intervals
      ~msg:"System /0 should own everything outside the shadowed /8");

  (* LPM beats source priority: a more-specific System /24 wins over a less-specific UDR /8,
     even though UserDefined outranks System at the same prefix length. *)
  "lpm_beats_source_priority" >:: (fun _ ->
    let sys0  = make_route ~source:System      "sys-0"  "0.0.0.0/0" in
    let udr8  = make_route ~source:UserDefined "udr-8"  "10.0.0.0/8" in
    let sys24 = make_route ~source:System      "sys-24" "10.1.1.0/24" in
    let result = Pathfinder.Route_partition.partition_routes (make_rt [sys0; udr8; sys24]) in
    let lo0,  hi0  = CIDR.get_interval (Route_table.Route.get_prefix sys0) in
    let lo8,  hi8  = CIDR.get_interval (Route_table.Route.get_prefix udr8) in
    let lo24, hi24 = CIDR.get_interval (Route_table.Route.get_prefix sys24) in
    assert_equal [(lo24, hi24)] (sorted_partitions result sys24)
      ~printer:show_intervals
      ~msg:"System /24 should win over UDR /8 via LPM";
    assert_equal
      (List.sort compare [(lo8, Int32.sub lo24 1l); (Int32.add hi24 1l, hi8)])
      (sorted_partitions result udr8)
      ~printer:show_intervals
      ~msg:"UDR /8 should own the /8 range minus the System /24";
    assert_equal
      (List.sort compare [(lo0, Int32.sub lo8 1l); (Int32.add hi8 1l, hi0)])
      (sorted_partitions result sys0)
      ~printer:show_intervals
      ~msg:"System /0 should own everything outside the /8");

]

let suite = "route_partition_suite" >::: [partition_tests; source_priority_tests]

let () = run_test_tt_main suite
