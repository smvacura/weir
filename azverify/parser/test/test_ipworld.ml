open OUnit2
open Frontends.AzureTF
open Azureir
open Parser.Tf_types
open Parser.Network_types

let ipworld_helper_tests = "ipworld_helper" >::: [
  "eq_true" >:: (fun _ ->
    assert_bool "" (Ipworld.equal Ipworld.empty Ipworld.empty));
  "eq_false" >:: (fun _ ->
    let ip = Option.get (IPv4.of_string_opt "10.0.1.10") in
    let nic = AddressMap.find "azurerm_network_interface.main" Test_azure_tf.static_nic_world.nics in
    let ipworld = ({ nics = IPMap.add ip nic IPMap.empty } : Ipworld.t) in
    assert_bool "" (not (Ipworld.equal Ipworld.empty ipworld)))
]

let get_ip_index_tests = "get_ip_index" >::: [
  "empty_world" >:: (fun _ ->
    assert_equal
    ~cmp:Ipworld.equal
    ~printer:Ipworld.show
    Ipworld.empty
    (AzureTFParser.get_ip_index World.empty));
  "no_nics" >:: (fun _ ->
    assert_equal
    ~cmp:Ipworld.equal
    ~printer:Ipworld.show
    Ipworld.empty
    (AzureTFParser.get_ip_index Test_azure_tf.simple_network_world));
  "dynamic_nic" >:: (fun _ ->
    assert_equal
    ~cmp:Ipworld.equal
    ~printer:Ipworld.show
    Ipworld.empty
    (AzureTFParser.get_ip_index Test_azure_tf.simple_nic_world));
  "static_nic" >:: (fun _ ->
    let ip = Option.get (IPv4.of_string_opt "10.0.1.10") in
    let nic = AddressMap.find "azurerm_network_interface.main" Test_azure_tf.static_nic_world.nics in
    let expected = ({ nics = IPMap.add ip nic IPMap.empty } : Ipworld.t) in
    assert_equal
    ~cmp:Ipworld.equal
    ~printer:Ipworld.show
    expected
    (AzureTFParser.get_ip_index Test_azure_tf.static_nic_world))
]

let suite = "ipworld_tests" >::: [
  ipworld_helper_tests;
  get_ip_index_tests
]
