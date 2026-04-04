open Parser.Tf_types

type t = {
  resource_groups : Rg.t IdKeyMap.t;
  subnets : Subnet.t AddressMap.t;
  vnets : Vnet.t IdKeyMap.t;
  nsgs : Nsg.t IdKeyMap.t;
  nics : Nic.t IdKeyMap.t;
  pips : Pip.t AddressMap.t
}

let equal t1 t2 =
  IdKeyMap.equal (=) t1.resource_groups t2.resource_groups &&
  AddressMap.equal (=) t1.subnets t2.subnets &&
  IdKeyMap.equal (=) t1.vnets t2.vnets &&
  IdKeyMap.equal (=) t1.nsgs t2.nsgs &&
  IdKeyMap.equal (=) t1.nics t2.nics &&
  AddressMap.equal (=) t1.pips t2.pips

let empty = {
  resource_groups = IdKeyMap.empty;
  subnets = AddressMap.empty;
  vnets = IdKeyMap.empty;
  nsgs = IdKeyMap.empty;
  nics = IdKeyMap.empty;
  pips = AddressMap.empty;
}

let get_resource_group world subscription name = 
  IdKeyMap.find_opt (IdKey.of_strings subscription name name) world.resource_groups

let show world = 
  "Resource groups: " ^ Rg.show_rg_map world.resource_groups ^ "\n" ^
  "Vnets: " ^ Vnet.show_vnet_map world.vnets ^ "\n" ^
  "Subnets: " ^ Subnet.show_subnet_map world.subnets ^ "\n" ^
  "Nsgs: " ^ Nsg.show_nsg_map world.nsgs ^ "\n" ^
  "Nics: " ^ Nic.show_nic_map world.nics ^ "\n" ^
  "Pips: " ^ Pip.show_pip_map world.pips ^ "\n"