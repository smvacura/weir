open Terraform_ir
open Parser.Tf_types
open Parser.Network_types

module VnetMap = Map.Make(Vnet)
type subnet_index = Subnet.t list VnetMap.t

type peer = {
  remote_vnet : Vnet.t;
  access_allowed : bool;
  remote_forwarding_allowed : bool
}

type peering_index = peer list VnetMap.t
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

let forwarding_allowed peering = 
  Vnet_peering.get_allow_forwarded_traffic peering
  |> Option.value ~default:false


let fold_resolved_peerings f (world : World.t) init =
  AddressMap.fold (fun _ peering acc ->
    match Vnet_peering.get_local_vnet peering, Vnet_peering.get_remote_vnet peering with
    | Resolved lv, Resolved rv -> f lv rv peering acc
    | _ -> acc
  ) world.vnet_peerings init

let index_peerings_by_pair (world : World.t) =
  let tbl = Hashtbl.create 8 in
  fold_resolved_peerings
    (fun lv rv peering () ->
      Hashtbl.replace tbl (Vnet.get_address lv, Vnet.get_address rv) peering)
    world ();
  tbl

let reverse_forwarding by_pair lv rv =
  Hashtbl.find_opt by_pair (Vnet.get_address rv, Vnet.get_address lv)
  |> Option.map forwarding_allowed
  |> Option.value ~default:false

let add_peer lv peer map =
  VnetMap.add lv (peer :: Option.value ~default:[] (VnetMap.find_opt lv map)) map

let get_peering_index (world : World.t) =
  let by_pair = index_peerings_by_pair world in
  fold_resolved_peerings
    (fun lv rv peering map ->
      add_peer lv
        { remote_vnet = rv;
          access_allowed = access_allowed peering;
          remote_forwarding_allowed = reverse_forwarding by_pair lv rv }
        map)
    world VnetMap.empty

let nic_cidrs nic =
  Nic.get_ipconfigs nic
  |> List.filter_map Nic.IpConfiguration.get_private_cidr
  |> List.concat

let get_asg_index (world : World.t) =
  AddressMap.map (fun nics -> List.concat_map nic_cidrs nics) world.assocs.asg_to_nics