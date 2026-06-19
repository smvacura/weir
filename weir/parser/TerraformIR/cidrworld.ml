open Parser.Tf_types

type t = {
  subnets : Subnet.t CIDRMap.t;
  routes : Route_table.Route.t CIDRMap.t;
  nics : Nic.t CIDRMap.t;
}

let equal t1 t2 =
  CIDRMap.equal (=) t1.subnets t2.subnets &&
  CIDRMap.equal (=) t1.routes t2.routes &&
  CIDRMap.equal (=) t1.nics t2.nics

let empty = {
  subnets = CIDRMap.empty;
  routes = CIDRMap.empty;
  nics = CIDRMap.empty;
}

let show world =
  "Subnets: " ^ Subnet.show_subnet_cidr_map world.subnets ^ "\n" ^
  "Routes: " ^ Route_table.Route.show_cidr_map world.routes ^ "\n" ^
  "Nics: " ^ Nic.show_nic_cidr_map world.nics ^ "\n"
