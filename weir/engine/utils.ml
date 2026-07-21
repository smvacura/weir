open Terraform_ir
open Parser.Tf_types
open Parser.Network_types

module VnetMap = Map.Make(Vnet)
type subnet_index = Subnet.t list VnetMap.t
(** [(cidr, allow_virtual_network_access)] per peered VNet, keyed by local VNet. *)
type peering_index = (CIDR.t * bool) list VnetMap.t
type asg_index = CIDR.t list AddressMap.t

let get_subnet_index (world : World.t) =
  let add_subnet subnet map =
    let vnet = Subnet.get_vnet subnet in
    match VnetMap.find_opt vnet map with
    | Some subnets -> VnetMap.add vnet (subnet::subnets) map
    | None -> VnetMap.add vnet [subnet] map
  in
  let rec aux subnets map =
    match subnets with
    | (_, subnet)::t -> aux t (add_subnet subnet map)
    | [] -> map
  in
  aux (AddressMap.to_list world.subnets) VnetMap.empty

let access_allowed peering =
  Vnet_peering.get_allow_virtual_network_access peering
  |> Option.value ~default:true

let add_remote_cidrs lv rv access_flag map =
  let entries = List.map (fun cidr -> (cidr, access_flag)) (Vnet.get_addresses rv) in
  match VnetMap.find_opt lv map with
  | Some existing -> VnetMap.add lv (existing @ entries) map
  | None -> VnetMap.add lv entries map

let fold_resolved_peerings f (world : World.t) init =
  AddressMap.fold (fun _ peering acc ->
    match Vnet_peering.get_local_vnet peering, Vnet_peering.get_remote_vnet peering with
    | Resolved lv, Resolved rv -> f lv rv peering acc
    | _ -> acc
  ) world.vnet_peerings init

let get_peering_index (world : World.t) =
  fold_resolved_peerings
    (fun lv rv peering map -> add_remote_cidrs lv rv (access_allowed peering) map)
    world VnetMap.empty

let nic_cidrs nic =
  Nic.get_ipconfigs nic
  |> List.filter_map Nic.IpConfiguration.get_private_cidr
  |> List.concat

let get_asg_index (world : World.t) =
  AddressMap.map (fun nics -> List.concat_map nic_cidrs nics) world.assocs.asg_to_nics