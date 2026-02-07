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

let simple_network_world = 
  let rg = Rg.make_rg
    "network-rg"
    (Rg.Id.of_string "azurerm_resource_group.main")
    WestUs2
    None
    []
  in
  let vnet = Vnet.make_vnet
    "main-vnet"
    (Vnet.Id.of_string "azurerm_virtual_network.main")
    WestUs2
    rg
    (Option.get (Parser.Network_types.CIDR.of_list_opt_strict [Some "10.0.0.0/16"]))
  in
  let subnet = Subnet.make_subnet
    "internal-subnet"
    (Subnet.Id.of_string "azurerm_subnet.internal")
    rg
    vnet
    (Option.get (Parser.Network_types.CIDR.of_list_opt_strict [Some "10.0.0.0/16"]))
  in
  let rgs' = Rg.Map.add (Rg.get_name rg) rg Rg.Map.empty in
  let vnets' = Vnet.Map.add (Vnet.get_name vnet) vnet Vnet.Map.empty in
  let subnets' = Subnet.Map.add (Subnet.get_name subnet) subnet Subnet.Map.empty in
  ({ resource_groups = rgs'; vnets = vnets'; subnets = subnets'} : World.t)



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
  "single_rg" >:: (fun _ -> assert_equal ~cmp:World.equal single_rg_world (AzureTFParser.get_resources "test_plans/single_rg/plan.json"));
  "simple_network" >:: (fun _ -> assert_equal ~cmp:World.equal simple_network_world (AzureTFParser.get_resources "test_plans/simple_network/plan.json"))
]

let suite = "azure_tf_tests" >::: [
  rg_helper_tests;
  world_helper_tests;
  basic_tests
]
