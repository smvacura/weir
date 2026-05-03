open OUnit2
open Frontends.AzureTF
open Azureir
open Parser.Tf_types
open Parser.Network_types

let cidrworld_helper_tests = "cidrworld_helper" >::: [
  "eq_true" >:: (fun _ ->
    assert_bool "" (Cidrworld.equal Cidrworld.empty Cidrworld.empty));
  "eq_false" >:: (fun _ ->
    let cidr = Option.get (CIDR.of_string_opt "10.0.2.0/24") in
    let subnet = AddressMap.find "azurerm_subnet.internal" Test_azure_tf.simple_network_world.subnets in
    let cidrworld = ({ subnets = CIDRMap.add cidr subnet CIDRMap.empty;
                       routes = CIDRMap.empty;
                       nics = CIDRMap.empty } : Cidrworld.t) in
    assert_bool "" (not (Cidrworld.equal Cidrworld.empty cidrworld)))
]

let get_cidr_index_tests = "get_cidr_index" >::: [
  "empty_world" >:: (fun _ ->
    assert_equal
    ~cmp:Cidrworld.equal
    ~printer:Cidrworld.show
    Cidrworld.empty
    (AzureTFParser.get_cidr_index World.empty));
  "subnet_indexed" >:: (fun _ ->
    let cidr = Option.get (CIDR.of_string_opt "10.0.2.0/24") in
    let subnet = AddressMap.find "azurerm_subnet.internal" Test_azure_tf.simple_network_world.subnets in
    let expected = ({ subnets = CIDRMap.add cidr subnet CIDRMap.empty;
                      routes = CIDRMap.empty;
                      nics = CIDRMap.empty } : Cidrworld.t) in
    assert_equal
    ~cmp:Cidrworld.equal
    ~printer:Cidrworld.show
    expected
    (AzureTFParser.get_cidr_index Test_azure_tf.simple_network_world));
  "dynamic_nic" >:: (fun _ ->
    let cidr = Option.get (CIDR.of_string_opt "10.0.1.0/24") in
    let subnet = AddressMap.find "azurerm_subnet.main" Test_azure_tf.simple_nic_world.subnets in
    let nic = AddressMap.find "azurerm_network_interface.main" Test_azure_tf.simple_nic_world.nics in
    let expected = ({ subnets = CIDRMap.add cidr subnet CIDRMap.empty;
                      routes = CIDRMap.empty;
                      nics = CIDRMap.add cidr nic CIDRMap.empty } : Cidrworld.t) in
    assert_equal
    ~cmp:Cidrworld.equal
    ~printer:Cidrworld.show
    expected
    (AzureTFParser.get_cidr_index Test_azure_tf.simple_nic_world));
  "static_nic" >:: (fun _ ->
    let cidr = Option.get (CIDR.of_string_opt "10.0.1.0/24") in
    let subnet = AddressMap.find "azurerm_subnet.main" Test_azure_tf.static_nic_world.subnets in
    let expected = ({ subnets = CIDRMap.add cidr subnet CIDRMap.empty;
                      routes = CIDRMap.empty;
                      nics = CIDRMap.empty } : Cidrworld.t) in
    assert_equal
    ~cmp:Cidrworld.equal
    ~printer:Cidrworld.show
    expected
    (AzureTFParser.get_cidr_index Test_azure_tf.static_nic_world));
  "route_table" >:: (fun _ ->
    let subnet_cidr = Option.get (CIDR.of_string_opt "10.0.0.0/24") in
    let route_cidr = Option.get (CIDR.of_string_opt "0.0.0.0/0") in
    let subnet = AddressMap.find "azurerm_subnet.subnet" Test_azure_tf.route_table_world.subnets in
    let rt = AddressMap.find "azurerm_route_table.rt" Test_azure_tf.route_table_world.route_tables in
    let route = List.hd (Route_table.get_routes rt) in
    let expected = ({ subnets = CIDRMap.add subnet_cidr subnet CIDRMap.empty;
                      routes = CIDRMap.add route_cidr route CIDRMap.empty;
                      nics = CIDRMap.empty } : Cidrworld.t) in
    assert_equal
    ~cmp:Cidrworld.equal
    ~printer:Cidrworld.show
    expected
    (AzureTFParser.get_cidr_index Test_azure_tf.route_table_world))
]

let suite = "cidrworld_tests" >::: [
  cidrworld_helper_tests;
  get_cidr_index_tests
]
