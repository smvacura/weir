
type t = {
  resource_groups : Rg.t Rg.Map.t;
  subnets : Subnet.t Subnet.Map.t;
  vnets : Vnet.t Vnet.Map.t;
  nsgs : Nsg.t Nsg.Map.t;
}

let equal t1 t2 =
  Rg.Map.equal (=) t1.resource_groups t2.resource_groups &&
  Subnet.Map.equal (=) t1.subnets t2.subnets &&
  Vnet.Map.equal (=) t1.vnets t2.vnets

let empty = {
  resource_groups = Rg.Map.empty;
  subnets = Subnet.Map.empty;
  vnets = Vnet.Map.empty;
  nsgs = Nsg.Map.empty;
}

let get_resource_group world subscription name = 
  Rg.Map.find_opt (Rg.Id.of_strings subscription name name) world.resource_groups

let show world = 
  "Resource groups: " ^ Rg.show_rg_map world.resource_groups ^ "\n" ^
  "Vnets: " ^ Vnet.show_vnet_map world.vnets ^ "\n" ^
  "Subnets: " ^ Subnet.show_subnet_map world.subnets ^ "\n" ^
  "Nsgs: " ^ Nsg.show_nsg_map world.nsgs ^ "\n"