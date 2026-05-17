open Parser.Network_types
open Terraform_ir.Nsg

open Bdd

type bit_encoding = 
| Specific of bool list
| Any

type header_segment =
| DestIP
| SrcIP
| DestPort
| SrcPort
| Protocol


let get_ip_bit_loc segment bit_loc = 
  match segment with
  | DestIP -> 2 + bit_loc
  | SrcIP -> 34 + bit_loc
  | _ -> 0

let encode_protocol man prot = 
  match prot with
  | Tcp -> dand man (ithvar man 0) (dnot man (ithvar man 1))
  | Udp -> dand man (dnot man (ithvar man 0)) (ithvar man 1)
  | Icmp -> dand man (ithvar man 0) (ithvar man 1)
  | Any -> dtrue man


let constant_to_bit_list c =
  let c_32 = Int32.of_int c in
  List.init 32 (fun i ->
    Int32.logand (Int32.shift_right_logical c_32 (31 - i)) 1l <> 0l)

let encode_le_constant man c =
  constant_to_bit_list c
  |> List.mapi (fun i value -> (31 - i, value))
  |> List.fold_left ( fun acc (i, bit) ->
    if bit 
    then ite man (ithvar man i) (dand man acc @@ dtrue man) acc
    else ite man (dnot man @@ Bdd.ithvar man i) (dand man acc @@ dfalse man) acc
  ) (dtrue man)


let encode_le_constant man c =
  constant_to_bit_list c
  |> List.mapi (fun i value -> (31 - i, value))
  |> List.rev
  |> List.fold_left ( fun acc (i, bit) ->
    if bit 
    then ite man (ithvar man i) acc (dtrue man)
    else ite man (ithvar man i) (dfalse man) acc
  ) (dtrue man)

let encode_ge_constant man c =
  constant_to_bit_list c
  |> List.mapi (fun i value -> (31 - i, value))
  |> List.rev
  |> List.fold_left ( fun acc (i, bit) ->
    if bit 
    then ite man (ithvar man i) acc (dfalse man)
    else ite man (ithvar man i) (dtrue man) acc 
  ) (dtrue man)

let encode_interval man lo hi =
  dand man (encode_ge_constant man lo) (encode_le_constant man hi)

let encode_cidr_membership man segment cidr =
  CIDR.to_bit_list cidr 
  |> List.mapi (fun i value -> (31 - i, value))
  |> List.fold_left (fun acc (i, bit) -> 
    let curr_bit = ithvar man @@ get_ip_bit_loc segment i in
    if bit then dand man acc curr_bit else dand man acc (dnot man curr_bit)
  ) (dtrue man)


let encode_route_cidrs man segment cidr_list =
  List.fold_left (fun acc cidr -> 
    dor man acc @@ encode_cidr_membership man segment cidr
  ) (dfalse man) cidr_list 

let encode_endpoint man segment endpoint = 
  match endpoint with
  | SecurityRule.Addresses cidrs -> encode_route_cidrs man segment cidrs
  | SecurityRule.Any -> dtrue man
  | _ -> dfalse man


let encode_allow man allow =
  match allow with
  | SecurityRule.Allow -> dtrue man
  | SecurityRule.Deny -> dfalse man

let encode_security_rule man rule =
  ""

let encode_nsg nsg man = 
  dtrue man