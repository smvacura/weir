open OUnit2
open Frontends.AzureTF
open Parser.Tf_types
open Parser.Network_types
open Pathfinder.Hsa
open Pathfinder.Bdd
open Pathfinder.Encoder

let plan_path = "test_plans/single_header_subnet/plan.json"

let parsed_world = lazy (AzureTFParser.get_resources plan_path)
let get_world () = Lazy.force parsed_world

let src_addr = "azurerm_subnet.source_subnet"
let dest_addr = "azurerm_subnet.nic_subnet"

let integration_tests = "hsa_integration" >::: [

  "two_subnets_parsed" >:: (fun _ ->
    let world = get_world () in
    assert_equal 2 (AddressMap.cardinal world.subnets)
      ~msg:"expected 2 subnets" ~printer:string_of_int);

  "graph_has_two_nodes" >:: (fun _ ->
    let world = get_world () in
    let man = init () in
    let graph, _ = build_graph world man in
    assert_equal 2 (node_count graph)
      ~msg:"expected 2 nodes" ~printer:string_of_int);

  "edge_exists_src_to_dest" >:: (fun _ ->
    let world = get_world () in
    let man = init () in
    let graph, _ = build_graph world man in
    assert_bool "expected edge from source_subnet to nic_subnet"
      (has_edge_between graph src_addr dest_addr));

  "one_header_reaches_dest" >:: (fun _ ->
    let world = get_world () in
    assert_equal 1.0
      (reachable_packet_count world src_addr dest_addr)
      ~msg:"expected exactly 1 reachable header" ~printer:string_of_float);

  "one_header_is_correct" >:: (fun _ ->
    let world = get_world () in
    assert_equal {
      src_ip = CIDR.make (Option.get @@ IPv4.of_string_opt "10.1.1.24") (IPv4Mask.of_mask_length 32);
      dest_ip = CIDR.make (Option.get @@ IPv4.of_string_opt "10.1.2.24") (IPv4Mask.of_mask_length 32);
      src_port = Single 22;
      dest_port = Single 22;
      protocol = Tcp
    }
    ~printer:show_packet_header
    (analyze (init ()) world
      |> pick_packet_opt "azurerm_subnet.source_subnet" "azurerm_subnet.nic_subnet"
      |> Option.get
    ));

]

let two_header_plan_path = "test_plans/two_header_subnet/plan.json"

let two_header_world = lazy (AzureTFParser.get_resources two_header_plan_path)
let get_two_header_world () = Lazy.force two_header_world

let two_header_tests = "two_header_integration" >::: [

  "two_subnets_parsed" >:: (fun _ ->
    let world = get_two_header_world () in
    assert_equal 2 (AddressMap.cardinal world.subnets)
      ~msg:"expected 2 subnets" ~printer:string_of_int);

  "two_headers_reach_dest" >:: (fun _ ->
    let world = get_two_header_world () in
    assert_equal 2.0
      (reachable_packet_count world src_addr dest_addr)
      ~msg:"expected exactly 2 reachable headers" ~printer:string_of_float);

]

let suite = "hsa_integration_suite" >::: [
  integration_tests;
  two_header_tests;
]

let () = run_test_tt_main suite
