open Smt_ir
open List

let smt_sort_to_string (sort : smt_sort) = 
  match sort with
  | Int -> "Int"
  | Bool -> "Bool"
  | BitVec i -> "(_ BitVec " ^ string_of_int i ^ ")"


let rec smt_term_to_string (term : smt_term) = 
  match term with
  | Symbol n -> n
  | Num a -> string_of_int a
  | Bool b -> string_of_bool b
  | BV (w, v) -> "(_ " ^ "bv" ^ string_of_int v ^ " " ^ string_of_int w ^ ")"
  | Eq (t1, t2) -> "(= " ^ smt_term_to_string t1 ^ " " ^ smt_term_to_string t2 ^ ")"


let smt_cmd_to_string (cmd : smt_cmd) =
  match cmd with
  | SetLogic l -> "(set-logic " ^ l ^ ")\n"
  | DeclareConst (s, t) -> "(declare-const " ^ s ^ " " ^ smt_sort_to_string t ^ ")\n"
  | Assert t -> "(assert " ^ smt_term_to_string t ^ ")\n"
  | CheckSat -> "(check-sat)\n"
  | GetModel -> "(get-model)\n"

let smt_to_string_list l = List.map smt_cmd_to_string l

let write_string_list_to_file f l = 
  let oc = Out_channel.open_text f in
  List.iter (Out_channel.output_string oc) l;
  close_out oc

let smt_to_file l f = 
  l 
  |> smt_to_string_list
  |> write_string_list_to_file f;