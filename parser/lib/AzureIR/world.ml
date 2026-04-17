open Parser.Tf_types

type t = {
  resource_groups : Rg.t AddressMap.t;
  subnets : Subnet.t AddressMap.t;
  vnets : Vnet.t AddressMap.t;
  nsgs : Nsg.t AddressMap.t;
  nics : Nic.t AddressMap.t;
  pips : Pip.t AddressMap.t;
  route_tables : Route_table.t AddressMap.t;
  route_table_associations : (Route_table.t, Subnet.t) Association.BinaryAssociation.t AddressMap.t;
  nsg_associations : (Nsg.t, Subnet.t) Association.BinaryAssociation.t AddressMap.t
}

let equal t1 t2 =
  AddressMap.equal (=) t1.resource_groups t2.resource_groups &&
  AddressMap.equal (=) t1.subnets t2.subnets &&
  AddressMap.equal (=) t1.vnets t2.vnets &&
  AddressMap.equal (=) t1.nsgs t2.nsgs &&
  AddressMap.equal (=) t1.nics t2.nics &&
  AddressMap.equal (=) t1.pips t2.pips &&
  AddressMap.equal (=) t1.route_tables t2.route_tables &&
  AddressMap.equal (=) t1.route_table_associations t2.route_table_associations &&
  AddressMap.equal (=) t1.nsg_associations t2.nsg_associations

let empty = {
  resource_groups = AddressMap.empty;
  subnets = AddressMap.empty;
  vnets = AddressMap.empty;
  nsgs = AddressMap.empty;
  nics = AddressMap.empty;
  pips = AddressMap.empty;
  route_tables = AddressMap.empty;
  route_table_associations = AddressMap.empty;
  nsg_associations = AddressMap.empty;
}

let get_resource_group world _subscription rg_name =
  AddressMap.fold (fun _ rg acc ->
    if Rg.get_name rg = rg_name then Some rg else acc)
    world.resource_groups None

let show world = 
  "Resource groups: " ^ Rg.show_rg_map world.resource_groups ^ "\n" ^
  "Vnets: " ^ Vnet.show_vnet_map world.vnets ^ "\n" ^
  "Subnets: " ^ Subnet.show_subnet_map world.subnets ^ "\n" ^
  "Nsgs: " ^ Nsg.show_nsg_map world.nsgs ^ "\n" ^
  "Nics: " ^ Nic.show_nic_map world.nics ^ "\n" ^
  "Pips: " ^ Pip.show_pip_map world.pips ^ "\n"