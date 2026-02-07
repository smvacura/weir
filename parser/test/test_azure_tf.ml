open OUnit2
open Frontends.AzureTF
open Azureir
open Parser.Azure_types


let single_rg_world = 
  let world = World.empty in
  let rg = Rg.make_rg 
    "example-resources"
    (Rg.Id.of_string "azurerm_resource_group.example")
    EastUs
    None
    []
  in
  let rgs' = Rg.Map.add (Rg.get_name rg) rg world.resource_groups in
  { world with resource_groups = rgs' }

let sample_rg = 
  Rg.make_rg 
    "example-resources"
    (Rg.Id.of_string "azurerm_resource_group.example")
    EastUs
    None
    []
let rg_helper_tests = "rg_helper" >::: [
  "eq_true" >:: (fun _ -> assert_bool "rg_eq_true" (sample_rg = (Rg.make_rg 
    "example-resources"
    (Rg.Id.of_string "azurerm_resource_group.example")
    EastUs
    None
    [])));
]
let world_helper_tests = "world_helper" >::: [
  "eq_true" >:: (fun _ -> assert_bool "" (World.equal single_rg_world single_rg_world));
  "eq_false" >:: (fun _ -> assert_bool "" (not (World.equal World.empty single_rg_world)))
]

let basic_tests = "simple_graphs" >::: [
  "single_rg" >:: (fun _ -> assert_equal ~cmp:World.equal single_rg_world (AzureTFParser.get_resources "test_plans/single_rg/plan.json"))
]

let suite = "azure_tf_tests" >::: [
  rg_helper_tests;
  world_helper_tests;
  basic_tests
]
