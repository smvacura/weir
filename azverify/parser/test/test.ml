open OUnit2

let suite = "all_tests" >::: [
  "network_test" >: Test_network_types.suite;
  "smt_writer_tests" >: Test_parser.suite;
  "azure_tf_tests" >: Test_azure_tf.suite;
  "ipworld_tests" >: Test_ipworld.suite;
  "cidrworld_tests" >: Test_cidrworld.suite;
  "stress_tests" >: Test_stress.suite;
  "multi_rg_stress_tests" >: Test_multi_rg_stress.suite;
  "property_tests" >: Test_properties.suite;
]

let () = 
  run_test_tt_main suite