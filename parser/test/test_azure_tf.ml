open OUnit2
open Frontends.AzureTF
open Azureir
open Parser.Azure_types


let single_rg_world = 
  let world = World.empty in
  let rg = Rg.make_rg 
    "example-resources"
    (Rg.Id.of_string "/subscriptions/12345678-1234-1234-1234-123456789abc/resourceGroups/example-resources")
    EastUs
    ""
    []
  in
  let rgs' = Rg.Map.add (Rg.get_name rg) rg world.resource_groups in
  { world with resource_groups = rgs' }

let basic_tests = "test suite for simple graphs" >::: [
  "single_rg" >:: (fun _ -> assert_equal single_rg_world (AzureTFParser.get_resources "test_plans/single_rg/plan.json"))
]
