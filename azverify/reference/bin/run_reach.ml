open Terraform_ir
open Parser.Tf_types
open Parser.Network_types
open Frontends
open Reference

let usage () =
  prerr_endline
    "usage: run_reach <plan.json> <src_ip> <dest_ip> [dest_port=443] [protocol=tcp] [src_port=40000]";
  exit 2

let arg i default = if Array.length Sys.argv > i then Sys.argv.(i) else default

let ip_of_string s =
  match String.split_on_char '.' s |> List.map int_of_string with
  | [ a; b; c; d ] ->
    let open Int32 in
    logor (shift_left (of_int a) 24)
      (logor (shift_left (of_int b) 16)
         (logor (shift_left (of_int c) 8) (of_int d)))
  | _ -> failwith (Printf.sprintf "malformed IPv4 address: %s" s)

let protocol_of_string s =
  match String.lowercase_ascii s with
  | "tcp"        -> Tcp
  | "udp"        -> Udp
  | "icmp"       -> Icmp
  | "any" | "*"  -> Any
  | _ -> failwith (Printf.sprintf "unknown protocol: %s" s)

let () =
  if Array.length Sys.argv < 4 then usage ();
  let path      = Sys.argv.(1) in
  let src_ip    = ip_of_string Sys.argv.(2) in
  let dest_ip   = ip_of_string Sys.argv.(3) in
  let dest_port = int_of_string (arg 4 "443") in
  let protocol  = protocol_of_string (arg 5 "tcp") in
  let src_port  = int_of_string (arg 6 "40000") in

  let world : World.t = AzureTF.AzureTFParser.get_resources path in
  let subnets = AddressMap.bindings world.subnets in

  Printf.printf "Subnets in %s:\n" path;
  List.iter
    (fun (addr, s) ->
      Printf.printf "  %-28s %s\n" addr (CIDR.show (List.hd (Subnet.get_cidrs s))))
    subnets;

  let owner ip =
    List.find_opt
      (fun (_, s) -> Packet.ip_in_cidr ip (List.hd (Subnet.get_cidrs s)))
      subnets
    |> Option.map fst
  in
  match owner src_ip with
  | None ->
    Printf.eprintf "\nsource IP %s is not in any subnet\n" Sys.argv.(2);
    exit 1
  | Some src ->
    let g = Reachability.build_graph world in
    let pkt = Packet.make ~src_ip ~dest_ip ~src_port ~dest_port ~protocol in
    let r = Reachability.reachable_in g ~src pkt in
    Printf.printf "\n%s:%d -> %s:%d  %s  (from %s)\n  reachable: %b\n"
      Sys.argv.(2) src_port Sys.argv.(3) dest_port (show_protocol protocol) src r
