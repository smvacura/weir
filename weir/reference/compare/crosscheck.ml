open Terraform_ir
open Parser.Tf_types
open Parser.Network_types
open Engine
open Reference

type verdict = {
  src          : string;
  dst          : string;
  packet       : Packet.t;
  ground_truth : bool;
  engine       : bool;
}

(* --- encode a concrete packet as the singleton BDD pinning every header bit ---
   Layout from Encoder: var (offset+k) is bit k (LSB) of each field; protocol is
   two bits, Tcp=(1,0) Udp=(0,1) Icmp=(1,1). *)

let bit man var b = if b then Bdd.ithvar man var else Bdd.dnot man (Bdd.ithvar man var)

let int32_field man offset width (v : int32) acc =
  let a = ref acc in
  for k = 0 to width - 1 do
    let b = Int32.logand (Int32.shift_right_logical v k) 1l = 1l in
    a := Bdd.dand man !a (bit man (offset + k) b)
  done;
  !a

let int_field man offset width (v : int) acc =
  let a = ref acc in
  for k = 0 to width - 1 do
    let b = (v lsr k) land 1 = 1 in
    a := Bdd.dand man !a (bit man (offset + k) b)
  done;
  !a

let proto_field man (p : protocol) acc =
  let off = Encoder.get_offset Encoder.Protocol in
  let b0, b1 =
    match p with
    | Tcp  -> (true, false)
    | Udp  -> (false, true)
    | Icmp -> (true, true)
    | Any  -> (true, false)   (* concrete packets shouldn't be Any *)
  in
  Bdd.dand man (Bdd.dand man acc (bit man off b0)) (bit man (off + 1) b1)

let packet_point man (pkt : Packet.t) =
  Bdd.dtrue man
  |> int32_field man (Encoder.get_offset Encoder.DestIP) 32 pkt.dest_ip
  |> int32_field man (Encoder.get_offset Encoder.SrcIP) 32 pkt.src_ip
  |> int_field man (Encoder.get_offset Encoder.DestPort) 16 pkt.dest_port
  |> int_field man (Encoder.get_offset Encoder.SrcPort) 16 pkt.src_port
  |> proto_field man pkt.protocol

let engine_reachable man ar src dst pkt =
  match Hsa.get_bdd ar src dst with
  | None -> false
  | Some reach -> not (Bdd.is_false (Bdd.dand man reach (packet_point man pkt)))

(* --- driving both oracles --- *)

let subnet_owner (world : World.t) ip =
  AddressMap.bindings world.subnets
  |> List.find_opt (fun (_, s) ->
         match Subnet.get_cidrs s with c :: _ -> Packet.ip_in_cidr ip c | [] -> false)
  |> Option.map fst

let setup world =
  let man = Bdd.init ~vars:128 () in
  let ar = Hsa.analyze man world in
  let g = Reachability.build_graph world in
  (man, ar, g)

let compare_packets world pkts =
  let man, ar, g = setup world in
  List.filter_map
    (fun pkt ->
      match subnet_owner world pkt.Packet.src_ip, subnet_owner world pkt.Packet.dest_ip with
      | Some src, Some dst ->
        Some { src; dst; packet = pkt;
               ground_truth = Reachability.reachable_in g ~src pkt;
               engine = engine_reachable man ar src dst pkt }
      | _ -> None)
    pkts

let sample_pairwise (world : World.t) =
  let subnets = AddressMap.bindings world.subnets in
  let host (_, s) =
    let lo, _ = CIDR.get_interval (List.hd (Subnet.get_cidrs s)) in
    Int32.add lo 4l
  in
  List.concat_map
    (fun a ->
      List.map
        (fun b ->
          Packet.make ~src_ip:(host a) ~dest_ip:(host b)
            ~src_port:40000 ~dest_port:443 ~protocol:Tcp)
        subnets)
    subnets

let concrete_of_header (h : Encoder.packet_header) =
  let ip c = fst (CIDR.get_interval c) in
  let port = function Single n -> n | Range (a, _) -> a | Any -> 0 in
  let protocol = match h.protocol with Any -> Tcp | p -> p in
  Packet.make
    ~src_ip:(ip h.src_ip) ~dest_ip:(ip h.dest_ip)
    ~src_port:(port h.src_port) ~dest_port:(port h.dest_port) ~protocol

let compare_engine_witnesses world =
  let man, ar, g = setup world in
  Hsa.reachable_pairs ar
  |> List.filter (fun (src, dst) -> src <> dst)
  |> List.filter_map (fun (src, dst) ->
         match Hsa.pick_packet_opt src dst ar with
         | None -> None
         | Some h ->
           let pkt = concrete_of_header h in
           Some { src; dst; packet = pkt;
                  ground_truth = Reachability.reachable_in g ~src pkt;
                  engine = engine_reachable man ar src dst pkt })

let disagreements = List.filter (fun v -> v.ground_truth <> v.engine)

let show_verdict v =
  Printf.sprintf "%-26s -> %-26s  gt=%-5b engine=%-5b%s"
    v.src v.dst v.ground_truth v.engine
    (if v.ground_truth = v.engine then "" else "   <-- DISAGREE")
