open OUnit2
open Engine.Encoder
open Engine.Bdd


let eval mgr bdd x =
  let cube =
    List.init 32 (fun i ->
      if (x lsr i) land 1 = 1 then ithvar mgr i
      else dnot mgr (ithvar mgr i))
    |> List.fold_left (dand mgr) (dtrue mgr)
  in
  let r = dand mgr bdd cube in
  sat_count mgr r > 0.5

let test_interval lo hi x _ =
  let man = init () ~vars:32 in
  let in_bdd_interval = eval man (encode_interval man ~width:32 ~offset:0 lo hi) x in
  if x >= lo && x <= hi
  then assert_bool "" in_bdd_interval
  else assert_bool "" (not in_bdd_interval)


let interval_tests = "interval tests" >::: [
  "[0,0], 0" >:: (test_interval 0 0 0);
  "[0,0], 1" >:: (test_interval 0 0 1);
  "[0,4], 3" >:: (test_interval 0 4 3)
]

let suite = "encoder_suite" >::: [interval_tests;]

let () = run_test_tt_main suite