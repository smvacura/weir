open Parser.Smt_ir
open Parser.Smt_to_file

let test_ir = [
  SetLogic "QF_BV";
  DeclareConst ("x", BitVec 8);
  DeclareConst ("y", BitVec 8);
  Assert (Eq (Symbol "x", BV (8, 5)));      (* x = #b00000101 *)
  Assert (Eq (Symbol "y", Symbol "x"));     (* y = x           *)
  CheckSat;
  GetModel
]

let () = smt_to_file test_ir "test.smt2"
