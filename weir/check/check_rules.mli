open Pathfinder.Hsa
open Pathfinder.Bdd
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

val compute : manager -> rule list -> World.t -> check_result list
