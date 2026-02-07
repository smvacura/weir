open OUnit2

let suite = "all_tests" >::: [
  "network_test" >: Test_network_types.suite;
  "smt_writer_tests" >: Test_parser.suite;
  "azure_tf_tests" >: Test_azure_tf.suite;
]

let () = 
  run_test_tt_main suite