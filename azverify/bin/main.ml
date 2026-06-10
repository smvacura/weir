open Cmdliner

let run logs_level before after =
  Logs.set_level logs_level;
  Logs.set_reporter (Logs_fmt.reporter ());
  (try
    Report.Diff.print Fmt.stdout before after;
    Format.pp_print_newline Fmt.stdout ()
  with Frontends.AzureTF.AzureTFParser.Parse_error msg ->
    Logs.err (fun m -> m "%s" msg);
    exit 1)

let run_check logs_level policy_path plan_path =
  Logs.set_level logs_level;
  Logs.set_reporter (Logs_fmt.reporter ());
  try
    match Constraints.Parse.of_file policy_path with
    | Error msg ->
      Logs.err (fun m -> m "policy error: %s" msg);
      exit 1
    | Ok policy ->
      let world = Frontends.AzureTF.AzureTFParser.get_resources plan_path in
      let man = Pathfinder.Bdd.init () in
      let results = Check.Check_rules.compute man policy.Constraints.Ast.rules world in
      Report.Constraints.print Fmt.stdout results;
      Format.pp_print_newline Fmt.stdout ();
      if List.exists (fun (r : Check.Check_rules.check_result) -> not r.sat) results
      then exit 1
  with Frontends.AzureTF.AzureTFParser.Parse_error msg ->
    Logs.err (fun m -> m "%s" msg);
    exit 1

let diff_cmd =
  let before =
    Arg.(required & pos 0 (some non_dir_file) None &
         info [] ~docv:"BEFORE" ~doc:"Terraform plan JSON before the change.")
  in
  let after =
    Arg.(required & pos 1 (some non_dir_file) None &
         info [] ~docv:"AFTER" ~doc:"Terraform plan JSON after the change.")
  in
  let info =
    Cmd.info "diff"
      ~doc:"Show reachability changes between two Terraform plan snapshots."
  in
  Cmd.v info Term.(const run $ Logs_cli.level () $ before $ after)

let check_cmd =
  let policy =
    Arg.(required & pos 0 (some non_dir_file) None &
         info [] ~docv:"POLICY" ~doc:"Constraint policy YAML file.")
  in
  let plan =
    Arg.(required & pos 1 (some non_dir_file) None &
         info [] ~docv:"PLAN" ~doc:"Terraform plan JSON to check.")
  in
  let info =
    Cmd.info "check"
      ~doc:"Check a constraint policy against a Terraform plan."
  in
  Cmd.v info Term.(const run_check $ Logs_cli.level () $ policy $ plan)

let () =
  let info = Cmd.info "azverify" ~version:"%%VERSION%%" ~doc:"Azure network verifier." in
  exit (Cmd.eval (Cmd.group info [diff_cmd; check_cmd]))
