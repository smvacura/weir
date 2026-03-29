open OUnit2
open Frontends.AzureTF
open Azureir
open Parser.Azure_types
open Parser.Tf_types
open Parser.Network_types


let single_rg_world = 
  let world = World.empty in
  let rg = Rg.make 
    ~name:"example-resources"
    ~subscription:"DEFAULT"
    ~address:"azurerm_resource_group.example"
    ~location:EastUs
    ~managed_by:None
    ~tags:[]
  in
  let rgs' = IdKeyMap.add (Rg.get_id rg) rg world.resource_groups in
  { world with resource_groups = rgs' }

let simple_network_world = 
  let rg = Rg.make
    ~name:"network-rg"
    ~subscription:"DEFAULT"
    ~address:"azurerm_resource_group.main"
    ~location:WestUs2
    ~managed_by:None
    ~tags:[]
  in
  let vnet = Vnet.make
    ~name:"main-vnet"
    ~subscription:"DEFAULT"
    ~address:"azurerm_virtual_network.main"
    ~location:WestUs2
    ~resource_group:rg
    ~addresses:(Option.get (CIDR.of_list_opt_strict [Some "10.0.0.0/16"]))
  in
  let subnet = Subnet.make
    ~name:"internal-subnet"
    ~subscription:"DEFAULT"
    ~address:"azurerm_subnet.internal"
    ~resource_group:rg
    ~vnet:vnet
    ~addresses:(Option.get (CIDR.of_list_opt_strict [Some "10.0.2.0/24"]))
  in
  let rgs' = IdKeyMap.add (Rg.get_id rg) rg IdKeyMap.empty in
  let vnets' = IdKeyMap.add (Vnet.get_id vnet) vnet IdKeyMap.empty in
  let subnets' = IdKeyMap.add (Subnet.get_id subnet) subnet IdKeyMap.empty in
  ({ resource_groups = rgs'; vnets = vnets'; subnets = subnets'; nsgs = IdKeyMap.empty; nics = IdKeyMap.empty; pips = IdKeyMap.empty} : World.t)

let simple_nsg_world = 
  let rg = Rg.make
  ~name:"nsg-simple-rg"
  ~subscription:"DEFAULT"
  ~address:"azurerm_resource_group.main"
  ~location:EastUs
  ~managed_by:None
  ~tags:[]
  in
  let rule = Nsg.SecurityRule.make
  ~name:"allow-ssh"
  ~description:(Some "")
  ~source_ports:[Any]
  ~destination_ports:[Single 22]
  ~protocol:Tcp
  ~source:Any
  ~destination:Any
  ~access:Allow
  ~priority:100
  ~direction:Inbound
  in
  let nsg = Nsg.make
  ~name:"main-nsg"
  ~subscription:"DEFAULT"
  ~address:"azurerm_network_security_group.main"
  ~location:EastUs
  ~resource_group:rg
  ~rule_list:[rule]
  ~tags:[]
  in
  let resource_groups = IdKeyMap.add (Rg.get_id rg) rg IdKeyMap.empty in
  let vnets = IdKeyMap.empty in
  let subnets = IdKeyMap.empty in
  let nsgs = IdKeyMap.add (Nsg.get_id nsg) nsg IdKeyMap.empty in
  let nics = IdKeyMap.empty in
  let pips = IdKeyMap.empty in
  ({resource_groups; vnets; subnets; nsgs; nics; pips} : World.t)

let simple_nic_world = 
  let rg = Rg.make
  ~name:"main-rg"
  ~subscription:"DEFAULT"
  ~address:"azurerm_resource_group.main"
  ~location:EastUs
  ~managed_by:None
  ~tags:[]
  in
  let vnet = Vnet.make
  ~name:"main-vnet"
  ~subscription:"DEFAULT"
  ~address:"azurerm_virtual_network.main"
  ~location:EastUs
  ~resource_group:rg
  ~addresses:(Option.get (CIDR.of_list_opt_strict [Some "10.0.0.0/16"]))
  in
  let subnet = Subnet.make
  ~name:"main-subnet"
  ~subscription:"DEFAULT"
  ~address:"azurerm_subnet.main"
  ~resource_group:rg
  ~vnet:vnet
  ~addresses:(Option.get (CIDR.of_list_opt_strict [Some "10.0.1.0/24"]))
  in
  let ipconfig = Nic.IpConfiguration.make
    ~name:"internal"
    ~subscription:"DEFAULT"
    ~subnet:Unresolved
    ~ip_address_version:IPv4
    ~pip:Unresolved
    ~private_address_allocation:Unresolved
    ~primary:Unresolved
  in
  let nic = Nic.make
  ~name:"main-nic"
  ~subscription:"DEFAULT"
  ~address:"azurerm_network_interface.main"
  ~location:EastUs
  ~resource_group:rg
  ~ip_configurations:[ipconfig]
  in
  let resource_groups = IdKeyMap.add (Rg.get_id rg) rg IdKeyMap.empty in
  let vnets = IdKeyMap.add (Vnet.get_id vnet) vnet IdKeyMap.empty in
  let subnets = IdKeyMap.add (Subnet.get_id subnet) subnet IdKeyMap.empty in
  let nsgs =  IdKeyMap.empty in
  let nics = IdKeyMap.add (Nic.get_id nic) nic IdKeyMap.empty in
  let pips = IdKeyMap.empty in 
  let world =
  ({resource_groups; vnets; subnets; nsgs; nics; pips} : World.t)
  in world

let static_nic_world = 
  let rg = Rg.make
  ~name:"main-rg"
  ~subscription:"DEFAULT"
  ~address:"azurerm_resource_group.main"
  ~location:EastUs
  ~managed_by:None
  ~tags:[]
  in
  let vnet = Vnet.make
  ~name:"main-vnet"
  ~subscription:"DEFAULT"
  ~address:"azurerm_virtual_network.main"
  ~location:EastUs
  ~resource_group:rg
  ~addresses:(Option.get (CIDR.of_list_opt_strict [Some "10.0.0.0/16"]))
  in
  let subnet = Subnet.make
  ~name:"main-subnet"
  ~subscription:"DEFAULT"
  ~address:"azurerm_subnet.main"
  ~resource_group:rg
  ~vnet:vnet
  ~addresses:(Option.get (CIDR.of_list_opt_strict [Some "10.0.1.0/24"]))
  in
  let ipconfig = Nic.IpConfiguration.make
    ~name:"internal"
    ~subscription:"DEFAULT"
    ~subnet:Unresolved
    ~ip_address_version:IPv4
    ~pip:Unresolved
    ~private_address_allocation:(Resolved (Static (Option.get (IPv4.of_string_opt "10.0.1.10"))))
    ~primary:Unresolved
  in
  let nic = Nic.make
  ~name:"main-nic"
  ~subscription:"DEFAULT"
  ~address:"azurerm_network_interface.main"
  ~location:EastUs
  ~resource_group:rg
  ~ip_configurations:[ipconfig]
  in
  let resource_groups = IdKeyMap.add (Rg.get_id rg) rg IdKeyMap.empty in
  let vnets = IdKeyMap.add (Vnet.get_id vnet) vnet IdKeyMap.empty in
  let subnets = IdKeyMap.add (Subnet.get_id subnet) subnet IdKeyMap.empty in
  let nsgs =  IdKeyMap.empty in
  let nics = IdKeyMap.add (Nic.get_id nic) nic IdKeyMap.empty in
  let pips = IdKeyMap.empty in 
  let world =
  ({resource_groups; vnets; subnets; nsgs; nics; pips} : World.t)
  in world


let pip_nic_world =
  let rg = Rg.make
    ~name:"rg-jumpbox"
    ~subscription:"DEFAULT"
    ~address:"azurerm_resource_group.this"
    ~location:EastUs
    ~managed_by:None
    ~tags:[]
  in
  let vnet = Vnet.make
    ~name:"vnet-jumpbox"
    ~subscription:"DEFAULT"
    ~address:"azurerm_virtual_network.this"
    ~location:EastUs
    ~resource_group:rg
    ~addresses:(Option.get (CIDR.of_list_opt_strict [Some "10.0.0.0/16"]))
  in
  let subnet = Subnet.make
    ~name:"snet-jumpbox"
    ~subscription:"DEFAULT"
    ~address:"azurerm_subnet.this"
    ~resource_group:rg
    ~vnet:vnet
    ~addresses:(Option.get (CIDR.of_list_opt_strict [Some "10.0.1.0/24"]))
  in
  let rule = Nsg.SecurityRule.make
    ~name:"allow-ssh"
    ~description:(Some "")
    ~source_ports:[Any]
    ~destination_ports:[Single 22]
    ~protocol:Tcp
    ~source:Any
    ~destination:Any
    ~access:Allow
    ~priority:100
    ~direction:Inbound
  in
  let nsg = Nsg.make
    ~name:"nsg-jumpbox"
    ~subscription:"DEFAULT"
    ~address:"azurerm_network_security_group.this"
    ~location:EastUs
    ~resource_group:rg
    ~rule_list:[rule]
    ~tags:[]
  in
  let pip = Pip.make
    ~name:"pip-jumpbox"
    ~subscription:"DEFAULT"
    ~address:"azurerm_public_ip.this"
    ~location:EastUs
    ~resource_group:rg
    ~allocation:Static
  in
  let ipconfig = Nic.IpConfiguration.make
    ~name:"internal"
    ~subscription:"DEFAULT"
    ~subnet:Unresolved
    ~ip_address_version:IPv4
    ~pip:Unresolved
    ~private_address_allocation:Unresolved
    ~primary:Unresolved
  in
  let nic = Nic.make
    ~name:"nic-jumpbox"
    ~subscription:"DEFAULT"
    ~address:"azurerm_network_interface.this"
    ~location:EastUs
    ~resource_group:rg
    ~ip_configurations:[ipconfig]
  in
  let resource_groups = IdKeyMap.add (Rg.get_id rg) rg IdKeyMap.empty in
  let vnets = IdKeyMap.add (Vnet.get_id vnet) vnet IdKeyMap.empty in
  let subnets = IdKeyMap.add (Subnet.get_id subnet) subnet IdKeyMap.empty in
  let nsgs = IdKeyMap.add (Nsg.get_id nsg) nsg IdKeyMap.empty in
  let nics = IdKeyMap.add (Nic.get_id nic) nic IdKeyMap.empty in
  let pips = IdKeyMap.add (Pip.get_id pip) pip IdKeyMap.empty in
  let world =
    ({resource_groups; vnets; subnets; nsgs; nics; pips} : World.t)
  in world

let sample_rg = 
  Rg.make 
    ~name:"example-resources"
    ~subscription:"DEFAULT"
    ~address:"azurerm_resource_group.example"
    ~location:EastUs
    ~managed_by:None
    ~tags:[]
let rg_helper_tests = "rg_helper" >::: [
  "eq_true" >:: (fun _ -> assert_bool "rg_eq_true" (sample_rg = (Rg.make 
    ~name:"example-resources"
    ~subscription:"DEFAULT"
    ~address:"azurerm_resource_group.example"
    ~location:EastUs
    ~managed_by:None
    ~tags:[])));
]
let world_helper_tests = "world_helper" >::: [
  "eq_true" >:: (fun _ -> assert_bool "" (World.equal single_rg_world single_rg_world));
  "eq_false" >:: (fun _ -> assert_bool "" (not (World.equal World.empty single_rg_world)))
]

let basic_tests = "simple_graphs" >::: [
  "single_rg" >:: (fun _ -> 
    assert_equal 
    ~cmp:World.equal 
    ~printer:World.show
    single_rg_world 
    (AzureTFParser.get_resources "test_plans/single_rg/plan.json"));
  "simple_network" >:: (fun _ -> 
    assert_equal 
    ~cmp:World.equal 
    ~printer:World.show
    simple_network_world 
    (AzureTFParser.get_resources "test_plans/simple_network/plan.json"));
  "simple_nsg" >:: (fun _ ->
    assert_equal
    ~cmp:World.equal
    ~printer:World.show
    simple_nsg_world
    (AzureTFParser.get_resources "test_plans/simple_nsg/plan.json"));
  "simple_nic" >:: (fun _ ->
    assert_equal
    ~cmp:World.equal
    ~printer:World.show
    simple_nic_world
    (AzureTFParser.get_resources "test_plans/simple_nic/plan.json" ));
  "static_nic" >:: (fun _ ->
    assert_equal
    ~cmp:World.equal
    ~printer:World.show
    static_nic_world
    (AzureTFParser.get_resources "test_plans/static_nic/plan.json"));
  "simple_pip" >:: (fun _ ->
    assert_equal
    ~cmp:World.equal
    ~printer:World.show
    pip_nic_world
    (AzureTFParser.get_resources "test_plans/simple_nic_pip/plan.json"))
]

let suite = "azure_tf_tests" >::: [
  rg_helper_tests;
  world_helper_tests;
  basic_tests
]
