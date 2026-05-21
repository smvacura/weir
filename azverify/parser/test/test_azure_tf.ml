open OUnit2
open Frontends.AzureTF
open Terraform_ir
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
  let rgs' = AddressMap.add (Rg.get_address rg) rg world.resource_groups in
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
  let rgs' = AddressMap.add (Rg.get_address rg) rg AddressMap.empty in
  let vnets' = AddressMap.add (Vnet.get_address vnet) vnet AddressMap.empty in
  let subnets' = AddressMap.add (Subnet.get_address subnet) subnet AddressMap.empty in
  ({ resource_groups = rgs';
     vnets = vnets';
     subnets = subnets';
     nsgs = AddressMap.empty;
     nics = AddressMap.empty;
     pips = AddressMap.empty;
     route_tables = AddressMap.empty;
     route_table_associations = AddressMap.empty;
     nsg_associations = AddressMap.empty;
     nic_nsg_associations = AddressMap.empty} : World.t)

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
  let resource_groups = AddressMap.add (Rg.get_address rg) rg AddressMap.empty in
  let vnets = AddressMap.empty in
  let subnets = AddressMap.empty in
  let nsgs = AddressMap.add (Nsg.get_address nsg) nsg AddressMap.empty in
  let nics = AddressMap.empty in
  let pips = AddressMap.empty in
  let route_tables = AddressMap.empty in
  let route_table_associations = AddressMap.empty in
  let nsg_associations = AddressMap.empty in
  let nic_nsg_associations = AddressMap.empty in
  ({resource_groups; vnets; subnets; nsgs; nics; pips; route_tables; route_table_associations; nsg_associations; nic_nsg_associations} : World.t)

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
    ~subnet:(Resolved subnet)
    ~ip_address_version:IPv4
    ~pip:(Resolved None)
    ~private_address_allocation:Dynamic
    ~primary:None
  in
  let nic = Nic.make
  ~name:"main-nic"
  ~subscription:"DEFAULT"
  ~address:"azurerm_network_interface.main"
  ~location:EastUs
  ~resource_group:rg
  ~ip_configurations:[ipconfig]
  in
  let resource_groups = AddressMap.add (Rg.get_address rg) rg AddressMap.empty in
  let vnets = AddressMap.add (Vnet.get_address vnet) vnet AddressMap.empty in
  let subnets = AddressMap.add (Subnet.get_address subnet) subnet AddressMap.empty in
  let nsgs = AddressMap.empty in
  let nics = AddressMap.add (Nic.get_address nic) nic AddressMap.empty in
  let pips = AddressMap.empty in
  let route_tables = AddressMap.empty in
  let route_table_associations = AddressMap.empty in
  let nsg_associations = AddressMap.empty in
  let world =
  let nic_nsg_associations = AddressMap.empty in
  ({resource_groups; vnets; subnets; nsgs; nics; pips; route_tables; route_table_associations; nsg_associations; nic_nsg_associations} : World.t)
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
    ~subnet:(Resolved subnet)
    ~ip_address_version:IPv4
    ~pip:(Resolved None)
    ~private_address_allocation:(Static (Option.get (IPv4.of_string_opt "10.0.1.10")))
    ~primary:None
  in
  let nic = Nic.make
  ~name:"main-nic"
  ~subscription:"DEFAULT"
  ~address:"azurerm_network_interface.main"
  ~location:EastUs
  ~resource_group:rg
  ~ip_configurations:[ipconfig]
  in
  let resource_groups = AddressMap.add (Rg.get_address rg) rg AddressMap.empty in
  let vnets = AddressMap.add (Vnet.get_address vnet) vnet AddressMap.empty in
  let subnets = AddressMap.add (Subnet.get_address subnet) subnet AddressMap.empty in
  let nsgs = AddressMap.empty in
  let nics = AddressMap.add (Nic.get_address nic) nic AddressMap.empty in
  let pips = AddressMap.empty in
  let route_tables = AddressMap.empty in
  let route_table_associations = AddressMap.empty in
  let nsg_associations = AddressMap.empty in
  let world =
  let nic_nsg_associations = AddressMap.empty in
  ({resource_groups; vnets; subnets; nsgs; nics; pips; route_tables; route_table_associations; nsg_associations; nic_nsg_associations} : World.t)
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
    ~subnet:(Resolved subnet)
    ~ip_address_version:IPv4
    ~pip:(Resolved (Some pip))
    ~private_address_allocation:Dynamic
    ~primary:None
  in
  let nic = Nic.make
    ~name:"nic-jumpbox"
    ~subscription:"DEFAULT"
    ~address:"azurerm_network_interface.this"
    ~location:EastUs
    ~resource_group:rg
    ~ip_configurations:[ipconfig]
  in
  let resource_groups = AddressMap.add (Rg.get_address rg) rg AddressMap.empty in
  let vnets = AddressMap.add (Vnet.get_address vnet) vnet AddressMap.empty in
  let subnets = AddressMap.add (Subnet.get_address subnet) subnet AddressMap.empty in
  let nsgs = AddressMap.add (Nsg.get_address nsg) nsg AddressMap.empty in
  let nics = AddressMap.add (Nic.get_address nic) nic AddressMap.empty in
  let pips = AddressMap.add (Pip.get_address pip) pip AddressMap.empty in
  let route_tables = AddressMap.empty in
  let route_table_associations = AddressMap.empty in
  let nsg_associations = AddressMap.empty in
  let nic_nsg_assoc = Association.BinaryAssociation.make nsg nic "azurerm_network_interface_security_group_association.this" in
  let nic_nsg_associations = AddressMap.add (Association.BinaryAssociation.get_address nic_nsg_assoc) nic_nsg_assoc AddressMap.empty in
  let world =
  ({resource_groups; vnets; subnets; nsgs; nics; pips; route_tables; route_table_associations; nsg_associations; nic_nsg_associations} : World.t)
  in world

let route_table_world =
  let rg = Rg.make
    ~name:"test-rg"
    ~subscription:"DEFAULT"
    ~address:"azurerm_resource_group.rg"
    ~location:EastUs
    ~managed_by:None
    ~tags:[]
  in
  let vnet = Vnet.make
    ~name:"test-vnet"
    ~subscription:"DEFAULT"
    ~address:"azurerm_virtual_network.vnet"
    ~location:EastUs
    ~resource_group:rg
    ~addresses:(Option.get (CIDR.of_list_opt_strict [Some "10.0.0.0/16"]))
  in
  let subnet = Subnet.make
    ~name:"test-subnet"
    ~subscription:"DEFAULT"
    ~address:"azurerm_subnet.subnet"
    ~resource_group:rg
    ~vnet:vnet
    ~addresses:(Option.get (CIDR.of_list_opt_strict [Some "10.0.0.0/24"]))
  in
  let route = Route_table.Route.make
    ~name:"default"
    ~address_prefix:(Option.get (CIDR.of_string_opt "0.0.0.0/0"))
    ~next_hop:Internet
    ~next_hop_in_ip_address:Unresolved
    ~source:UserDefined
  in
  let rt = Route_table.make
    ~name:"test-rt"
    ~subscription:"DEFAULT"
    ~address:"azurerm_route_table.rt"
    ~location:EastUs
    ~resource_group:rg
    ~routes:[route]
    ~bgp_route_propagation_enabled:true
    ~tags:[]
  in
  let assoc = Association.BinaryAssociation.make rt subnet "azurerm_subnet_route_table_association.assoc" in
  let resource_groups = AddressMap.add (Rg.get_address rg) rg AddressMap.empty in
  let vnets = AddressMap.add (Vnet.get_address vnet) vnet AddressMap.empty in
  let subnets = AddressMap.add (Subnet.get_address subnet) subnet AddressMap.empty in
  let nsgs = AddressMap.empty in
  let nics = AddressMap.empty in
  let pips = AddressMap.empty in
  let route_tables = AddressMap.add (Route_table.get_address rt) rt AddressMap.empty in
  let route_table_associations = AddressMap.add (Association.BinaryAssociation.get_address assoc) assoc AddressMap.empty in
  let nsg_associations = AddressMap.empty in
  let world =
    let nic_nsg_associations = AddressMap.empty in
  ({resource_groups; vnets; subnets; nsgs; nics; pips; route_tables; route_table_associations; nsg_associations; nic_nsg_associations} : World.t)
  in world

let nsg_subnet_assoc_world =
  let rg = Rg.make
    ~name:"nsg-subnet-rg"
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
  let rule = Nsg.SecurityRule.make
    ~name:"allow-https"
    ~description:(Some "")
    ~source_ports:[Any]
    ~destination_ports:[Single 443]
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
  let assoc = Association.BinaryAssociation.make nsg subnet "azurerm_subnet_network_security_group_association.assoc" in
  let resource_groups = AddressMap.add (Rg.get_address rg) rg AddressMap.empty in
  let vnets = AddressMap.add (Vnet.get_address vnet) vnet AddressMap.empty in
  let subnets = AddressMap.add (Subnet.get_address subnet) subnet AddressMap.empty in
  let nsgs = AddressMap.add (Nsg.get_address nsg) nsg AddressMap.empty in
  let nics = AddressMap.empty in
  let pips = AddressMap.empty in
  let route_tables = AddressMap.empty in
  let route_table_associations = AddressMap.empty in
  let nsg_associations = AddressMap.add (Association.BinaryAssociation.get_address assoc) assoc AddressMap.empty in
  let nic_nsg_associations = AddressMap.empty in
  ({resource_groups; vnets; subnets; nsgs; nics; pips; route_tables; route_table_associations; nsg_associations; nic_nsg_associations} : World.t)

let dynamic_nic_udr_world =
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
  let appliance_subnet = Subnet.make
    ~name:"appliance-subnet"
    ~subscription:"DEFAULT"
    ~address:"azurerm_subnet.appliance"
    ~resource_group:rg
    ~vnet:vnet
    ~addresses:(Option.get (CIDR.of_list_opt_strict [Some "10.0.0.0/24"]))
  in
  let workload_subnet = Subnet.make
    ~name:"workload-subnet"
    ~subscription:"DEFAULT"
    ~address:"azurerm_subnet.workload"
    ~resource_group:rg
    ~vnet:vnet
    ~addresses:(Option.get (CIDR.of_list_opt_strict [Some "10.0.1.0/24"]))
  in
  let ipconfig = Nic.IpConfiguration.make
    ~name:"internal"
    ~subscription:"DEFAULT"
    ~subnet:(Resolved appliance_subnet)
    ~ip_address_version:IPv4
    ~pip:(Resolved None)
    ~private_address_allocation:Dynamic
    ~primary:None
  in
  let nic = Nic.make
    ~name:"appliance-nic"
    ~subscription:"DEFAULT"
    ~address:"azurerm_network_interface.appliance"
    ~location:EastUs
    ~resource_group:rg
    ~ip_configurations:[ipconfig]
  in
  let route = Route_table.Route.make
    ~name:"to-appliance"
    ~address_prefix:(Option.get (CIDR.of_string_opt "0.0.0.0/0"))
    ~next_hop:VirtualAppliance
    ~next_hop_in_ip_address:(Resolved (DynamicNic "azurerm_network_interface.appliance"))
    ~source:UserDefined
  in
  let rt = Route_table.make
    ~name:"workload-rt"
    ~subscription:"DEFAULT"
    ~address:"azurerm_route_table.workload"
    ~location:EastUs
    ~resource_group:rg
    ~bgp_route_propagation_enabled:true
    ~routes:[route]
    ~tags:[]
  in
  let assoc = Association.BinaryAssociation.make rt workload_subnet "azurerm_subnet_route_table_association.workload" in
  let resource_groups = AddressMap.add (Rg.get_address rg) rg AddressMap.empty in
  let vnets = AddressMap.add (Vnet.get_address vnet) vnet AddressMap.empty in
  let subnets = AddressMap.add (Subnet.get_address appliance_subnet) appliance_subnet AddressMap.empty in
  let subnets = AddressMap.add (Subnet.get_address workload_subnet) workload_subnet subnets in
  let nics = AddressMap.add (Nic.get_address nic) nic AddressMap.empty in
  let route_tables = AddressMap.add (Route_table.get_address rt) rt AddressMap.empty in
  let route_table_associations = AddressMap.add (Association.BinaryAssociation.get_address assoc) assoc AddressMap.empty in
  ({resource_groups; vnets; subnets;
    nsgs = AddressMap.empty; nics; pips = AddressMap.empty;
    route_tables; route_table_associations;
    nsg_associations = AddressMap.empty;
    nic_nsg_associations = AddressMap.empty} : World.t)

let nic_no_subnet_world =
  let rg = Rg.make
    ~name:"main-rg"
    ~subscription:"DEFAULT"
    ~address:"azurerm_resource_group.main"
    ~location:EastUs
    ~managed_by:None
    ~tags:[]
  in
  let resource_groups = AddressMap.add (Rg.get_address rg) rg AddressMap.empty in
  ({resource_groups;
    vnets = AddressMap.empty;
    subnets = AddressMap.empty;
    nsgs = AddressMap.empty;
    nics = AddressMap.empty;
    pips = AddressMap.empty;
    route_tables = AddressMap.empty;
    route_table_associations = AddressMap.empty;
    nsg_associations = AddressMap.empty;
    nic_nsg_associations = AddressMap.empty} : World.t)

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
    (AzureTFParser.get_resources "test_plans/simple_nic_pip/plan.json"));
  "simple_route_table" >:: (fun _ ->
    assert_equal
    ~cmp:World.equal
    ~printer:World.show
    route_table_world
    (AzureTFParser.get_resources "test_plans/simple_route_table/plan.json"));
  "simple_nsg_subnet_assoc" >:: (fun _ ->
    assert_equal
    ~cmp:World.equal
    ~printer:World.show
    nsg_subnet_assoc_world
    (AzureTFParser.get_resources "test_plans/simple_nsg_subnet_assoc/plan.json"));
  "nic_no_subnet" >:: (fun _ ->
    assert_equal
    ~cmp:World.equal
    ~printer:World.show
    nic_no_subnet_world
    (AzureTFParser.get_resources "test_plans/nic_no_subnet/plan.json"));
  "dynamic_nic_udr" >:: (fun _ ->
    assert_equal
    ~cmp:World.equal
    ~printer:World.show
    dynamic_nic_udr_world
    (AzureTFParser.get_resources "test_plans/dynamic_nic_udr/plan.json"))
]

let suite = "azure_tf_tests" >::: [
  rg_helper_tests;
  world_helper_tests;
  basic_tests
]
