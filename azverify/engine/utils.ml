open Terraform_ir
open Parser.Tf_types

module VnetMap = Map.Make(Vnet)
type subnet_index = Subnet.t list VnetMap.t

let get_subnet_index (world : World.t) = 
  let map = VnetMap.empty in
  let add_subnet subnet map = 
    let vnet = Subnet.get_vnet subnet in
    match VnetMap.find_opt vnet map with
    | Some subnets -> VnetMap.add vnet (subnet::subnets) map
    | None -> map
  in
  let rec aux subnets map =
    match subnets with
    | (address, subnet)::t -> aux t (add_subnet subnet map)
    | [] -> map
  in
  aux (AddressMap.to_list world.subnets) VnetMap.empty 