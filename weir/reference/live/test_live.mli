type fidelity_result = {
  row : Csv.Row.t;
  result : bool;
  agrees : bool;
}

val test_probe_result :
  Terraform_ir.World.t ->
  Reference.Reachability.graph ->
  string ->
  Csv.Row.t ->
  fidelity_result

val test_live_file :
  string ->
  Terraform_ir.World.t ->
  Reference.Reachability.graph ->
  fidelity_result list
