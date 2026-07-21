open Parser.Network_types
open Terraform_ir.Nsg

open Bdd


type header_segment =
| DestIP
| SrcIP
| DestPort
| SrcPort
| Protocol


type packet_header = {
    dest_ip : CIDR.t;
    src_ip : CIDR.t;
    dest_port : port;
    src_port : port;
    protocol : protocol
}
[@@deriving show]

let get_offset segment =
  match segment with
  | DestIP -> 0
  | SrcIP -> 32
  | DestPort -> 64
  | SrcPort -> 80
  | Protocol -> 96

let encode_protocol man ~offset prot = 
  match prot with
  | Tcp -> dand man (ithvar man offset) (dnot man (ithvar man (offset + 1)))
  | Udp -> dand man (dnot man (ithvar man offset)) (ithvar man (offset + 1))
  | Icmp -> dand man (ithvar man offset) (ithvar man (offset + 1))
  | Any -> dtrue man


let constant_to_bit_list ~width c =
  let c_32 = Int32.of_int c in
  List.init width (fun i ->
    Int32.logand (Int32.shift_right_logical c_32 (width - 1 - i)) 1l <> 0l)


let encode_le_constant man ~width ~offset c =
  constant_to_bit_list ~width c
  |> List.mapi (fun i value -> (width - 1 - i, value))
  |> List.rev
  |> List.fold_left ( fun acc (i, bit) ->
    if bit 
    then ite man (ithvar man (offset + i)) acc (dtrue man)
    else ite man (ithvar man (offset + i)) (dfalse man) acc
  ) (dtrue man)

let encode_ge_constant man ~width ~offset c =
  constant_to_bit_list ~width c
  |> List.mapi (fun i value -> (width - 1 - i, value))
  |> List.rev
  |> List.fold_left ( fun acc (i, bit) ->
    if bit 
    then ite man (ithvar man (offset + i)) acc (dfalse man)
    else ite man (ithvar man (offset + i)) (dtrue man) acc 
  ) (dtrue man)

let encode_interval man ~width ~offset lo hi =
  dand man (encode_ge_constant man ~width ~offset lo) (encode_le_constant man ~width ~offset hi)

let encode_cidr_membership man ~offset cidr =
  CIDR.to_bit_list cidr 
  |> List.mapi (fun i value -> (31 - i, value))
  |> List.fold_left (fun acc (i, bit) -> 
    let curr_bit = ithvar man (offset + i) in
    if bit then dand man acc curr_bit else dand man acc (dnot man curr_bit)
  ) (dtrue man)


let encode_route_cidrs man ~offset cidr_list =
  List.fold_left (fun acc cidr -> 
    dor man acc @@ encode_cidr_membership man ~offset cidr
  ) (dfalse man) cidr_list 

let encode_endpoint man ~offset endpoint = 
  match endpoint with
  | SecurityRule.Addresses cidrs -> encode_route_cidrs man ~offset cidrs
  | SecurityRule.Any -> dtrue man
  | _ -> dfalse man

let encode_port man ~offset port =
  match port with
  | Single p -> encode_interval man ~width:16 ~offset p p
  | Range (lo, hi) -> encode_interval man ~width:16 ~offset lo hi
  | Any -> dtrue man

let encode_port_list man ~offset ports =
  List.fold_left (fun acc port ->
    dor man acc @@ encode_port man ~offset port
  ) (dfalse man) ports

let encode_security_rule man rule =
    [ encode_endpoint man ~offset:(get_offset SrcIP) (SecurityRule.get_src_ip rule); 
    encode_endpoint man ~offset:(get_offset DestIP) (SecurityRule.get_dest_ip rule); 
    encode_port_list man ~offset:(get_offset SrcPort) (SecurityRule.get_src_ports rule); 
    encode_port_list man ~offset:(get_offset DestPort) (SecurityRule.get_dest_ports rule); 
    encode_protocol man ~offset:(get_offset Protocol) (SecurityRule.get_protocol rule);
    ]
    |> List.fold_left (dand man) (dtrue man)

let encode_nsg ensg man =
  let rules = Effective_nsg.get_effective_rules ensg
  |> List.sort SecurityRule.compare
  in
  match rules with
  | [] -> dtrue man
  | _ ->
    List.fold_left (fun (permitted, shadowed) rule ->
      let matched = encode_security_rule man rule in
      let unshadowed = dand man matched (dnot man shadowed) in
      match SecurityRule.get_access rule with
      | SecurityRule.Allow -> (dor man permitted unshadowed, dor man unshadowed shadowed)
      | SecurityRule.Deny -> (permitted, dor man unshadowed shadowed)
      ) (dfalse man, dfalse man) rules
      |> fst

let encode_effective_route man interval_list =
  List.fold_left (fun acc (lo, hi) ->
    dor man acc @@ encode_interval man ~width:32 ~offset:(get_offset DestIP) (Int32.to_int lo) (Int32.to_int hi)
  ) (dfalse man) interval_list

let encode_partial_header man protocol ports =
    dand man
      (encode_protocol  man ~offset:(get_offset Protocol) protocol)
      (encode_port_list man ~offset:(get_offset DestPort) ports)

let safe_get arr i = if i < Array.length arr then arr.(i) else None

let bits_to_int arr lo len =
  let v = ref 0 in
  for i = lo + len - 1 downto lo do
    let b = match safe_get arr i with Some p -> p | None -> false in
    v := (!v lsl 1) lor (if b then 1 else 0)
  done;
  !v

let protocol_of_bits b1 b2 =
  match b1, b2 with
  | Some true, Some false -> Tcp
  | Some false, Some true -> Udp
  | Some true, Some true -> Icmp
  | None, None -> Any
  | _ -> failwith "Incorrect protocol bits"

let decode_single_packet arr =
  { dest_ip = bits_to_int arr (get_offset DestIP) 32 |> Int32.of_int |> IPv4.of_int32 |> (fun ip -> CIDR.make ip (IPv4Mask.of_mask_length 32));  (* force /32 downstream *)
    src_ip = bits_to_int arr (get_offset SrcIP) 32 |> Int32.of_int |> IPv4.of_int32 |> (fun ip -> CIDR.make ip (IPv4Mask.of_mask_length 32));
    dest_port = Single (bits_to_int arr (get_offset DestPort) 16);
    src_port = Single (bits_to_int arr (get_offset SrcPort) 16);
    protocol = protocol_of_bits (safe_get arr (get_offset Protocol)) (safe_get arr (get_offset Protocol + 1))}