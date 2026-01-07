
type t = {
  resource_groups : Rg.t Rg.Map.t;
  subnets : Subnet.t Subnet.Map.t;
  vnets : Vnet.t Vnet.Map.t
}

let empty = {
  resource_groups = Rg.Map.empty;
  subnets = Subnet.Map.empty;
  vnets = Vnet.Map.empty
}

let get_resource_group world name = 
  Rg.Map.find_opt (Rg.Id.of_string name) world.resource_groups