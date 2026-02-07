open OUnit2

let suite = "all_tests" >::: [
  Test_azure_tf.suite;
  Test_parser.suite
]

let () = 
  run_test_tt_main suite