open Hsa
open Encoder
open Bdd

type packet_examples =
  | Single     of packet_header * int
  | Sample     of packet_header list * int
  | Exhaustive of packet_header list

type packet_diff = {
  src     : resource_address;
  dst     : resource_address;
  added   : packet_examples option;
  removed : packet_examples option;
  num_added : float;
  num_removed : float;
}

let pick_example man bdd =
  match Bdd.pick_sat man bdd |> Option.map Encoder.decode_single_packet with
  | Some packet -> Some (Single (packet, Bdd.sat_count man bdd |> Float.to_int))
  | None -> None

let get_pair_diff man src dst before_results after_results =
  let before_bdd = get_bdd before_results src dst |> Option.value ~default:(dfalse man) in
  let after_bdd  = get_bdd after_results  src dst |> Option.value ~default:(dfalse man) in
  let removed_bdd = dand man before_bdd (dnot man after_bdd) in
  let added_bdd   = dand man after_bdd  (dnot man before_bdd) in
  let num_removed = sat_count man removed_bdd in
  let num_added = sat_count man added_bdd in
  match pick_example man removed_bdd, pick_example man added_bdd with
  | None, None -> None
  | removed, added -> Some { src; dst; added; removed; num_added; num_removed}

let compute before after =
  let man = init () in
  let before_results = analyze man before in
  let after_results  = analyze man after in
  let addrs =
    List.sort_uniq String.compare
      (Terraform_ir.World.resource_addresses before
       @ Terraform_ir.World.resource_addresses after)
  in
  let pairs = List.concat_map (fun src ->
    List.filter_map (fun dst ->
      if src = dst then None else Some (src, dst)
    ) addrs
  ) addrs
  in
  List.filter_map (fun (src, dst) ->
    get_pair_diff man src dst before_results after_results
  ) pairs
