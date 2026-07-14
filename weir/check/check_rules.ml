open Pathfinder.Hsa
open Pathfinder.Bdd
open Pathfinder.Encoder
open Parser.Network_types
open Terraform_ir
open Constraints.Ast

type check_result = {
  name: string;
  src: resource_address;
  dest: resource_address;
  ports: port list;
  protocol: protocol;
  sat: bool;
}

let reachable man (rule : rule) results =
  match get_bdd results rule.src rule.dst with
  | Some bdd ->
    let mask = encode_partial_header man rule.on.protocol rule.on.ports in
    not (is_false (dand man mask bdd))
  | None -> false

let check_rule man results (rule : rule) =
  let holds =
    match rule.expect with
    | Reachable   -> reachable man rule results
    | Unreachable -> not (reachable man rule results)
  in
  {
    name = rule.name;
    src = rule.src;
    dest = rule.dst;
    ports = rule.on.ports;
    protocol = rule.on.protocol;
    sat = holds;
  }

let compute man (rules : rule list) world =
  let sources = List.sort_uniq Stdlib.compare (List.map (fun (c : rule) -> c.src) rules) in
  let results = analyze ~srcs:sources man world in
  List.map (check_rule man results) rules
