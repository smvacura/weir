open Parser.Smt_to_file
open OUnit2



let basic_tests = "test suite for simple terms" >::: [
  "term" >:: (fun _ -> assert_equal "f" @@ smt_term_to_string (Symbol "f"));
  "number" >:: (fun _ -> assert_equal "42" @@ smt_term_to_string (Num 42));
  "bool" >:: (fun _ -> assert_equal "true" @@ smt_term_to_string (Bool true));
  "BV" >:: (fun _ -> assert_equal "(_ bv4 32)" @@ smt_term_to_string (BV (32, 4)));
  "eq" >:: (fun _ -> assert_equal "(= x 99)" @@ smt_term_to_string (Eq (Symbol "x", (Num 99))));
  "lt" >:: (fun _ -> assert_equal "(< 1 123)" @@ smt_term_to_string (LT (Num 1, Num 123)));
  "le" >:: (fun _ -> assert_equal "(<= 1 123)" @@ smt_term_to_string (LE (Num 1, Num 123)));
  "ite" >:: (fun _ -> assert_equal "(if (< x 0) then 1 else 2)"  @@ smt_term_to_string (ITE (LT (Symbol "x", Num 0), Num 1, Num 2)));
  "and" >:: (fun _ -> assert_equal "(and a b c d)" @@ smt_term_to_string (And [Symbol "a"; Symbol "b"; Symbol "c"; Symbol "d"]));
  "or" >:: (fun _ -> assert_equal "(or a b c d)" @@ smt_term_to_string (Or [Symbol "a"; Symbol "b"; Symbol "c"; Symbol "d"]));
  "not" >:: (fun _ -> assert_equal "(not (= x y))" @@ smt_term_to_string (Not (Eq (Symbol "x", Symbol "y"))));
  "imp" >:: (fun _ -> assert_equal "(=> p q)" @@ smt_term_to_string (Imp (Symbol "p", Symbol "q")));
]

let () = 
  run_test_tt_main basic_tests;