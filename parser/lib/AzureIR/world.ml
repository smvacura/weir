
type t = {
  resource_groups : Rg.t Rg.Map.t;
  subnets : Subnet.t Subnet.Map.t;
  vnets : Vnet.t Vnet.Map.t
}

let equal t1 t2 =
  Rg.Map.equal (=) t1.resource_groups t2.resource_groups &&
  Subnet.Map.equal (=) t1.subnets t2.subnets &&
  Vnet.Map.equal (=) t1.vnets t2.vnets

let empty = {
  resource_groups = Rg.Map.empty;
  subnets = Subnet.Map.empty;
  vnets = Vnet.Map.empty
}

let get_resource_group world name = 
  Rg.Map.find_opt (Rg.Id.of_string name) world.resource_groups