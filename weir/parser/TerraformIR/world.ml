open Parser.Tf_types

type assocs = {
  subnet_nsg     : Nsg.t AddressMap.t;
  subnet_rt      : Route_table.t AddressMap.t;
  nic_nsg        : Nsg.t AddressMap.t;
  asg_to_nics    : Nic.t list AddressMap.t;
  subnet_to_nics : Nic.t list AddressMap.t;
}

type t = {
  resource_groups : Rg.t AddressMap.t;
  subnets : Subnet.t AddressMap.t;
  vnets : Vnet.t AddressMap.t;
  nsgs : Nsg.t AddressMap.t;
  nics : Nic.t AddressMap.t;
  pips : Pip.t AddressMap.t;
  route_tables : Route_table.t AddressMap.t;
  vnet_peerings : Vnet_peering.t AddressMap.t;
  asgs : Asg.t AddressMap.t;
  assocs : assocs;
}

let equal_assocs a1 a2 =
  AddressMap.equal (=) a1.subnet_nsg a2.subnet_nsg &&
  AddressMap.equal (=) a1.subnet_rt a2.subnet_rt &&
  AddressMap.equal (=) a1.nic_nsg a2.nic_nsg &&
  AddressMap.equal (List.equal (=)) a1.asg_to_nics a2.asg_to_nics &&
  AddressMap.equal (List.equal (=)) a1.subnet_to_nics a2.subnet_to_nics

let equal t1 t2 =
  AddressMap.equal (=) t1.resource_groups t2.resource_groups &&
  AddressMap.equal (=) t1.subnets t2.subnets &&
  AddressMap.equal (=) t1.vnets t2.vnets &&
  AddressMap.equal (=) t1.nsgs t2.nsgs &&
  AddressMap.equal (=) t1.nics t2.nics &&
  AddressMap.equal (=) t1.pips t2.pips &&
  AddressMap.equal (=) t1.route_tables t2.route_tables &&
  AddressMap.equal (=) t1.vnet_peerings t2.vnet_peerings &&
  AddressMap.equal (=) t1.asgs t2.asgs &&
  equal_assocs t1.assocs t2.assocs

let empty_assocs = {
  subnet_nsg     = AddressMap.empty;
  subnet_rt      = AddressMap.empty;
  nic_nsg        = AddressMap.empty;
  asg_to_nics    = AddressMap.empty;
  subnet_to_nics = AddressMap.empty;
}

let empty = {
  resource_groups = AddressMap.empty;
  subnets = AddressMap.empty;
  vnets = AddressMap.empty;
  nsgs = AddressMap.empty;
  nics = AddressMap.empty;
  pips = AddressMap.empty;
  route_tables = AddressMap.empty;
  vnet_peerings = AddressMap.empty;
  asgs = AddressMap.empty;
  assocs = empty_assocs;
}

let get_resource_group world _subscription rg_name =
  AddressMap.fold (fun _ rg acc ->
    if Rg.get_name rg = rg_name then Some rg else acc)
    world.resource_groups None

let resource_addresses world =
  let keys m = AddressMap.fold (fun k _ acc -> k :: acc) m [] in
  keys world.nics @ keys world.pips @ keys world.subnets
  |> List.sort_uniq String.compare

let show_assoc_map m =
  "{" ^
  (m |> AddressMap.bindings |> List.map fst |> String.concat ",")
  ^ "}"

let show world =
  "Resource groups: " ^ Rg.show_rg_map world.resource_groups ^ "\n" ^
  "Vnets: " ^ Vnet.show_vnet_map world.vnets ^ "\n" ^
  "Subnets: " ^ Subnet.show_subnet_map world.subnets ^ "\n" ^
  "Nsgs: " ^ Nsg.show_nsg_map world.nsgs ^ "\n" ^
  "Nics: " ^ Nic.show_nic_map world.nics ^ "\n" ^
  "Pips: " ^ Pip.show_pip_map world.pips ^ "\n" ^
  "Route tables: " ^ Route_table.show_rt_map world.route_tables ^ "\n" ^
  "Vnet peerings: " ^ Vnet_peering.show_peering_map world.vnet_peerings ^ "\n" ^
  "ASGs: " ^ Asg.show_asg_map world.asgs ^ "\n" ^
  "subnet_nsg: " ^ show_assoc_map world.assocs.subnet_nsg ^ "\n" ^
  "subnet_rt: " ^ show_assoc_map world.assocs.subnet_rt ^ "\n" ^
  "nic_nsg: " ^ show_assoc_map world.assocs.nic_nsg ^ "\n" ^
  "asg_to_nics: " ^ show_assoc_map world.assocs.asg_to_nics ^ "\n"
