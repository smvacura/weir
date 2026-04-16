open OUnit2

let suite = "all_tests" >::: [
  "network_test" >: Test_network_types.suite;
  "smt_writer_tests" >: Test_parser.suite;
  "azure_tf_tests" >: Test_azure_tf.suite;
  "stress_tests" >: Test_stress.suite;
  "multi_rg_stress_tests" >: Test_multi_rg_stress.suite;
]

let () = 
  run_test_tt_main suite