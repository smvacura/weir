open Terraform_ir
open Parser.Network_types
open Parser.Tf_types

open Bdd

type node_id = int
type resource_address = string

type node = { ip_range: Parser.Network_types.CIDR.t; attached: resource_address; nsg : Effective_nsg.t }
type edge = { decider: Bdd.bdd; src: node_id; dest: node_id }

type adjacency = (node_id, edge list) Hashtbl.t

type node_index = (resource_address, node_id) Hashtbl.t

type cidr_index = (Vnet.t * CIDR.t, node_id) Hashtbl.t 

type hsa_graph = {
  nodes : (node_id, node) Hashtbl.t;
  in_list : adjacency;
  out_list: adjacency;
  addr_index: node_index;
  cidr_index: cidr_index;
  next_id: int ref
}

type reachability_table = (node_id * node_id, bdd) Hashtbl.t

type analysis_result = {
  graph : hsa_graph;
  table : reachability_table;
  man : manager
}

(* TODO: initialize hashmaps with better values *)
let init_hsa_graph (world : World.t) = {
  nodes = Hashtbl.create (AddressMap.cardinal world.subnets + AddressMap.cardinal world.nics);
  in_list = Hashtbl.create 0;
  out_list = Hashtbl.create 0;
  addr_index = Hashtbl.create 0;
  cidr_index = Hashtbl.create 0;
  next_id = ref 0
}

let push tbl k v =
    match Hashtbl.find_opt tbl k with
    | Some e -> Hashtbl.replace tbl k (v::e)
    | None -> Hashtbl.add tbl k [v]

let push_mult tbl k v = 
  match Hashtbl.find_opt tbl k with
  | Some e -> Hashtbl.replace tbl k (e @ v)
  | None -> Hashtbl.add tbl k v

let get_node_opt f graph =
  let (let*) = Option.bind in
  let* id = f in
  let* node = Hashtbl.find_opt graph.nodes id in
  Some (id, node)

let get_node_from_cidr_opt vnet_cidr graph =
  get_node_opt (Hashtbl.find_opt graph.cidr_index vnet_cidr) graph

let get_node_from_addr_opt addr graph =
  get_node_opt (Hashtbl.find_opt graph.addr_index addr) graph

type build_context = {
  subnet_to_rt : Route_table.t AddressMap.t;
  subnet_to_nsg : Nsg.t AddressMap.t;
  subnet_index : Utils.subnet_index;
  nic_to_subnet : Subnet.t AddressMap.t;
  nic_to_nsg : Nsg.t AddressMap.t;
  peering_index : Utils.peering_index;
  asg_index : Utils.asg_index;
}

let add_internet_node hsa_graph =
  let id = !(hsa_graph.next_id) in
  let node = {ip_range = CIDR.make (Option.get @@ IPv4.of_octets_opt 0 0 0 0) (IPv4Mask.of_int32 0l); attached = "$internet"; nsg = Effective_nsg.empty} in
  Hashtbl.replace hsa_graph.nodes id node;
  Hashtbl.replace hsa_graph.addr_index "$internet" id;
  hsa_graph.next_id := id + 1


let add_subnet ctx subnet hsa_graph =
  let attached = Subnet.get_address subnet in
  let vnet = Subnet.get_vnet subnet in
  let ip_range = Subnet.get_cidrs subnet |> List.hd in
  let rt = AddressMap.find_opt attached ctx.subnet_to_rt
    |> Option.value ~default:Route_table.empty in
  let nsg = Effective_nsg.enrich_nsg
    (AddressMap.find_opt attached ctx.subnet_to_nsg) (Some vnet) rt ctx.peering_index ctx.asg_index
  in
  let id = !(hsa_graph.next_id) in
  let node = { ip_range; attached; nsg } in
  Hashtbl.replace hsa_graph.addr_index attached id;
  Hashtbl.replace hsa_graph.nodes id node;
  Hashtbl.replace hsa_graph.cidr_index (vnet, ip_range) id;
  hsa_graph.next_id := id + 1

let add_nic ctx nic hsa_graph =
  let address = Nic.get_address nic in
  let subnet_opt = AddressMap.find_opt address ctx.nic_to_subnet in
  let vnet_opt = Option.map Subnet.get_vnet subnet_opt in
  let rt = match subnet_opt with
    | Some subnet ->
      AddressMap.find_opt (Subnet.get_address subnet) ctx.subnet_to_rt
      |> Option.value ~default:Route_table.empty
    | None -> Route_table.empty in
  let nsg = Effective_nsg.enrich_nsg
    (AddressMap.find_opt address ctx.nic_to_nsg) vnet_opt rt ctx.peering_index ctx.asg_index
  in
  List.iter (fun ipconfig ->
      let config_name = Nic.IpConfiguration.get_name ipconfig in
      let subaddress = address ^ "/" ^ config_name in
      let id = !(hsa_graph.next_id) in
      match Nic.IpConfiguration.get_private_ip ipconfig with
      | Some ip -> let node = { ip_range = CIDR.make ip (IPv4Mask.of_int32 32l); attached = subaddress; nsg} in
                   Hashtbl.replace hsa_graph.addr_index subaddress id;
                   Hashtbl.replace hsa_graph.nodes id node;
                   hsa_graph.next_id := id + 1
      | None -> ()
    ) (Nic.get_ipconfigs nic)

let get_subnets vnet subnets =
  let rec aux subnets acc =
    match subnets with
    | [] -> acc
    | h::t -> if Terraform_ir.Subnet.get_vnet h = vnet
              then aux t (h::acc)
              else aux t acc
  in
  aux subnets []


let add_edge subnet_id node_id node effective_nsg interval graph man = 
  let decider = dand man (dand man
  (Encoder.encode_effective_route man interval) 
  (Encoder.encode_nsg effective_nsg man))
  (Encoder.encode_nsg node.nsg man) in
  let edge = { decider; src = subnet_id; dest = node_id} in
  push graph.in_list node_id edge;
  push graph.out_list subnet_id edge

let add_subnet_edges man ctx subnet_id subnet graph =
  let subnet_address = Subnet.get_address subnet in
  let vnet = Subnet.get_vnet subnet in
  let rt = AddressMap.find_opt subnet_address ctx.subnet_to_rt
    |> Option.value ~default:Route_table.empty in
  let source_nsg = AddressMap.find_opt subnet_address ctx.subnet_to_nsg in
  let effective_routes = Effective_route_table.enrich_route_table rt vnet ctx.peering_index
    |> Effective_route_table.get_effective_routes
    |> Route_partition.partition_routes in
  let effective_nsg = Effective_nsg.enrich_nsg source_nsg (Some vnet) rt ctx.peering_index ctx.asg_index in
  Hashtbl.iter (
    fun route interval ->
      let add addr_result subinterval =
        Option.iter (fun (id, node) ->
          add_edge subnet_id id node effective_nsg subinterval graph man
        ) addr_result
      in
      match Route_table.Route.get_next_hop route with
      | VirtualAppliance -> begin
        match Route_table.Route.get_next_hop_ip route with
        | Resolved StaticAppliance ip ->
          add (get_node_from_cidr_opt (vnet, CIDR.make ip (IPv4Mask.of_int32 32l)) graph) interval
        | Resolved DynamicNic address ->
          add (get_node_from_addr_opt address graph) interval
        | Resolved ApplianceSet set ->
          List.iter (fun address -> add (get_node_from_addr_opt address graph) interval) set
        | _ -> ()
      end
      | VirtualNetwork ->
        let all_subnets = Utils.VnetMap.fold (fun _ subnets acc -> subnets @ acc) ctx.subnet_index [] in
        List.iter (fun subnet ->
          List.iter (fun cidr ->
            let subintervals = List.filter_map (CIDR.intersect cidr) interval in
            if subintervals <> [] then
              add (get_node_from_addr_opt (Subnet.get_address subnet) graph) subintervals
          ) (Subnet.get_cidrs subnet)
        ) all_subnets
      | _ -> ()
  ) effective_routes

let add_nic_edge ctx nic_id nic graph man =
  let nic_address = Nic.get_address nic in
  let subnet_opt = AddressMap.find_opt nic_address ctx.nic_to_subnet in
  let vnet_opt = Option.map Subnet.get_vnet subnet_opt in
  let rt = match subnet_opt with
    | Some subnet ->
      AddressMap.find_opt (Subnet.get_address subnet) ctx.subnet_to_rt
      |> Option.value ~default:Route_table.empty
    | None -> Route_table.empty in
  let ensg = Effective_nsg.enrich_nsg
    (AddressMap.find_opt nic_address ctx.nic_to_nsg) vnet_opt rt ctx.peering_index ctx.asg_index
  in
  match subnet_opt with
  | Some subnet -> begin
    match Hashtbl.find_opt graph.addr_index (Subnet.get_address subnet) with
    | Some node_id -> 
      let decider = Encoder.encode_nsg ensg man in
      let edge = { decider; src = nic_id; dest = node_id} in
      push graph.in_list node_id edge;
      push graph.out_list nic_id edge
    | None -> ()
    end
  | None -> ()


let add_topological_edge subnet_id node_id interval graph man =
  let decider = Encoder.encode_effective_route man interval in
  let edge = { decider; src = subnet_id; dest = node_id } in
  push graph.in_list node_id edge;
  push graph.out_list subnet_id edge

let add_topological_subnet_edges man ctx subnet_id subnet graph =
  let subnet_address = Subnet.get_address subnet in
  let vnet = Subnet.get_vnet subnet in
  let rt = AddressMap.find_opt subnet_address ctx.subnet_to_rt
    |> Option.value ~default:Route_table.empty in
  let effective_routes = Effective_route_table.enrich_route_table rt vnet ctx.peering_index
    |> Effective_route_table.get_effective_routes
    |> Route_partition.partition_routes in
  Hashtbl.iter (
    fun route interval ->
      let add addr_result =
        Option.iter (fun (id, _node) ->
          add_topological_edge subnet_id id interval graph man
        ) addr_result
      in
      match Route_table.Route.get_next_hop route with
      | VirtualAppliance -> begin
        match Route_table.Route.get_next_hop_ip route with
        | Resolved StaticAppliance ip ->
          add (get_node_from_cidr_opt (vnet, CIDR.make ip (IPv4Mask.of_int32 32l)) graph)
        | Resolved DynamicNic address ->
          add (get_node_from_addr_opt address graph)
        | Resolved ApplianceSet set ->
          List.iter (fun address -> add (get_node_from_addr_opt address graph)) set
        | _ -> ()
      end
      | VirtualNetwork -> add (get_node_from_cidr_opt (vnet, (Route_table.Route.get_prefix route)) graph)
      | _ -> ()
  ) effective_routes

let add_topological_nic_edge ctx nic_id nic graph man =
  match AddressMap.find_opt (Nic.get_address nic) ctx.nic_to_subnet with
  | Some subnet -> begin
    match Hashtbl.find_opt graph.addr_index (Subnet.get_address subnet) with
    | Some node_id ->
      let decider = dtrue man in
      let edge = { decider; src = nic_id; dest = node_id } in
      push graph.in_list node_id edge;
      push graph.out_list nic_id edge
    | None -> ()
    end
  | None -> ()

type build_timing = {
  association_build_ms : float;
  node_addition_ms     : float;
  edge_addition_ms     : float;
  total_build_ms       : float;
}

type analyze_timing = {
  build         : build_timing;
  fixpoint_ms   : float;
  total_ms      : float;
  node_count    : int;
  edge_count    : int;
}

let ms_since t = (Unix.gettimeofday () -. t) *. 1000.0

let edge_count graph =
  Hashtbl.fold (fun _ edges acc -> acc + List.length edges) graph.out_list 0

let build_graph world man =
  let t0 = Unix.gettimeofday () in
  let subnet_to_nsg = world.World.assocs.subnet_nsg in
  let subnet_to_rt  = world.World.assocs.subnet_rt in
  let nic_to_nsg    = world.World.assocs.nic_nsg in
  let nic_to_subnet = AddressMap.fold (fun _ nic acc ->
    let address = Nic.get_address nic in
    match Nic.get_ipconfigs nic |> List.filter_map Nic.IpConfiguration.get_subnet |> List.find_opt (fun _ -> true) with
    | Some subnet -> AddressMap.add address subnet acc
    | None -> acc
  ) world.nics AddressMap.empty in
  let ctx = { subnet_to_rt; subnet_to_nsg; subnet_index = Utils.get_subnet_index world; nic_to_subnet; nic_to_nsg; peering_index = Utils.get_peering_index world; asg_index = Utils.get_asg_index world } in
  let t_assoc = ms_since t0 in
  let t1 = Unix.gettimeofday () in
  let hsa_graph = init_hsa_graph world in
  add_internet_node hsa_graph;
  AddressMap.iter (fun _addr subnet ->
    add_subnet ctx subnet hsa_graph
  ) world.subnets;
  AddressMap.iter (fun _addr nic ->
    add_nic ctx nic hsa_graph
  ) world.nics;
  let t_nodes = ms_since t1 in
  let t2 = Unix.gettimeofday () in
  AddressMap.iter (fun _addr subnet ->
    let subnet_id = Hashtbl.find hsa_graph.addr_index (Subnet.get_address subnet) in
    add_subnet_edges man ctx subnet_id subnet hsa_graph
  ) world.subnets;
  AddressMap.iter (fun _addr nic ->
    List.iter (fun ipconfig ->
      let config_name = Nic.IpConfiguration.get_name ipconfig in
      let subaddress = Nic.get_address nic ^ "/" ^ config_name in
      Option.iter (fun nic_id ->
        add_nic_edge ctx nic_id nic hsa_graph man
      ) (Hashtbl.find_opt hsa_graph.addr_index subaddress)
    ) (Nic.get_ipconfigs nic)
  ) world.nics;
  let timing = {
    association_build_ms = t_assoc;
    node_addition_ms     = t_nodes;
    edge_addition_ms     = ms_since t2;
    total_build_ms       = ms_since t0;
  } in
  (hsa_graph, timing)

let build_topological_graph world man =
  let t0 = Unix.gettimeofday () in
  let subnet_to_nsg = world.World.assocs.subnet_nsg in
  let subnet_to_rt  = world.World.assocs.subnet_rt in
  let nic_to_nsg    = world.World.assocs.nic_nsg in
  let nic_to_subnet = AddressMap.fold (fun _ nic acc ->
    let address = Nic.get_address nic in
    match Nic.get_ipconfigs nic |> List.filter_map Nic.IpConfiguration.get_subnet |> List.find_opt (fun _ -> true) with
    | Some subnet -> AddressMap.add address subnet acc
    | None -> acc
  ) world.nics AddressMap.empty in
  let ctx = { subnet_to_rt; subnet_to_nsg; subnet_index = Utils.get_subnet_index world; nic_to_subnet; nic_to_nsg; peering_index = Utils.get_peering_index world; asg_index = Utils.get_asg_index world } in
  let t_assoc = ms_since t0 in
  let t1 = Unix.gettimeofday () in
  let hsa_graph = init_hsa_graph world in
  AddressMap.iter (fun _addr subnet ->
    add_subnet ctx subnet hsa_graph
  ) world.subnets;
  AddressMap.iter (fun _addr nic ->
    add_nic ctx nic hsa_graph
  ) world.nics;
  let t_nodes = ms_since t1 in
  let t2 = Unix.gettimeofday () in
  AddressMap.iter (fun _addr subnet ->
    let subnet_id = Hashtbl.find hsa_graph.addr_index (Subnet.get_address subnet) in
    add_topological_subnet_edges man ctx subnet_id subnet hsa_graph
  ) world.subnets;
  AddressMap.iter (fun _addr nic ->
    List.iter (fun ipconfig ->
      let config_name = Nic.IpConfiguration.get_name ipconfig in
      let subaddress = Nic.get_address nic ^ "/" ^ config_name in
      Option.iter (fun nic_id ->
        add_topological_nic_edge ctx nic_id nic hsa_graph man
      ) (Hashtbl.find_opt hsa_graph.addr_index subaddress)
    ) (Nic.get_ipconfigs nic)
  ) world.nics;
  let timing = {
    association_build_ms = t_assoc;
    node_addition_ms     = t_nodes;
    edge_addition_ms     = ms_since t2;
    total_build_ms       = ms_since t0;
  } in
  (hsa_graph, timing)

let compute_fixpoint src graph table man =
  let init_worklist () =
    let worklist = Queue.create () in
    Queue.add src worklist;
    worklist
  in

  let init_reachability_table () =
    Hashtbl.add table (src, src) (dtrue man);
  in

  let worklist = init_worklist () in
  init_reachability_table ();

  let current_node_packets dest =
    match Hashtbl.find_opt table (src, dest) with
    | Some packets -> packets
    | None -> dfalse man
  in

  let compute_new_headers edge packets =
    Bdd.dand man (edge.decider) packets
  in

  let add_to_table old_packets new_packets node_id =
    Hashtbl.replace table (src, node_id) (dor man old_packets new_packets)
  in

  let packets_grew combined old_packets =
    not (Bdd.equal combined old_packets)
  in

  let add_to_worklist node_id =
    Queue.add node_id worklist
  in

  let step node =
    match Hashtbl.find_opt graph.out_list node with
    | Some edges ->
      List.iter (fun edge ->
        let dest_id     = edge.dest in
        let src_packets = current_node_packets edge.src in
        let old_packets = current_node_packets dest_id in
        let new_packets = compute_new_headers edge src_packets in
        let combined    = dor man old_packets new_packets in
        if packets_grew combined old_packets then begin
          add_to_table old_packets new_packets dest_id;
          add_to_worklist dest_id
        end
      ) edges
    | None -> ()
  in

  while not @@ Queue.is_empty worklist do
    let curr_node = Queue.pop worklist in
    step curr_node
  done



let node_count graph = Hashtbl.length graph.nodes

let resolve_addr graph addr =
  Hashtbl.find_opt graph.addr_index addr

let has_edge_between graph src_addr dest_addr =
  match resolve_addr graph src_addr, resolve_addr graph dest_addr with
  | Some src_id, Some dest_id ->
    (match Hashtbl.find_opt graph.out_list src_id with
    | Some edges -> List.exists (fun e -> e.dest = dest_id) edges
    | None -> false)
  | _ -> false

let get_decider graph src_addr dest_addr =
  match resolve_addr graph src_addr, resolve_addr graph dest_addr with
  | Some src_id, Some dest_id ->
    (match Hashtbl.find_opt graph.out_list src_id with
    | Some edges ->
      (match List.find_opt (fun e -> e.dest = dest_id) edges with
      | Some edge -> Some edge.decider
      | None -> None)
    | None -> None)
  | _ -> None


let analyze ?srcs man world =
  let graph, _ = build_graph world man in
  let table = Hashtbl.create (Hashtbl.length graph.nodes) in
  let run_from src_id = compute_fixpoint src_id graph table man in
  (match srcs with
   | None -> Hashtbl.iter (fun src_id _src -> run_from src_id) graph.nodes
   | Some addrs ->
     List.iter
       (fun addr ->
         match Hashtbl.find_opt graph.addr_index addr with
         | Some src_id -> run_from src_id
         | None -> ())
       addrs);
  {table; graph; man}

let reachable_pairs {table; graph; man = _} =
  Hashtbl.fold (fun (src_id, dest_id) _bdd acc ->
    match Hashtbl.find_opt graph.nodes src_id, Hashtbl.find_opt graph.nodes dest_id with
    | Some src_node, Some dest_node -> (src_node.attached, dest_node.attached) :: acc
    | _ -> acc
  ) table []

let get_bdd {table; graph; man = _} src_addr dest_addr =
  let (let*) = Option.bind in
  let* src_id = Hashtbl.find_opt graph.addr_index src_addr in
  let* dest_id = Hashtbl.find_opt graph.addr_index dest_addr in
  Hashtbl.find_opt table (src_id, dest_id)

let run_analysis_timed world =
  let t0 = Unix.gettimeofday () in
  let man = Bdd.init () in
  let graph, build = build_graph world man in
  let t1 = Unix.gettimeofday () in
  let table = Hashtbl.create (Hashtbl.length graph.nodes) in
  Hashtbl.iter (fun src_id _src -> compute_fixpoint src_id graph table man) graph.nodes;
  {
    build;
    fixpoint_ms = ms_since t1;
    total_ms    = ms_since t0;
    node_count  = node_count graph;
    edge_count  = edge_count graph;
  }

let query_num_paths_opt table src_id dest_id man =
  match Hashtbl.find_opt table (src_id, dest_id) with
  | Some packets -> Bdd.sat_count man packets
  | None -> 0.0

let pick_packet_opt src_addr dest_addr {table; graph; man} =
  let (let*) = Option.bind in
  let* src_id = Hashtbl.find_opt graph.addr_index src_addr in
  let* dest_id = Hashtbl.find_opt graph.addr_index dest_addr in
  let* packets = Hashtbl.find_opt table (src_id, dest_id) in
  Bdd.pick_sat man packets 
  |> Option.map Encoder.decode_single_packet 

let reachable_packet_count world src_addr dest_addr =
  let man = Bdd.init () in
  let graph, _ = build_graph world man in
  match resolve_addr graph src_addr, resolve_addr graph dest_addr with
  | Some src_id, Some dest_id ->
    let table = Hashtbl.create 4 in
    compute_fixpoint src_id graph table man;
    query_num_paths_opt table src_id dest_id man
  | _ -> 0.0
