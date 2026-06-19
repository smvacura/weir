open Cmdliner

let run_show logs_level plan =
  Logs.set_level logs_level;
  Logs.set_reporter (Logs_fmt.reporter ());
  (try
    Report.Diff.print_new Fmt.stdout plan;
    Format.pp_print_newline Fmt.stdout ()
  with Frontends.AzureTF.AzureTFParser.Parse_error msg ->
    Logs.err (fun m -> m "%s" msg);
    exit 1)

let run logs_level if_new before after =
  Logs.set_level logs_level;
  Logs.set_reporter (Logs_fmt.reporter ());
  (try
    if (not (Sys.file_exists before)) && if_new
    then Report.Diff.print_new Fmt.stdout after
    else Report.Diff.print Fmt.stdout before after;
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

let show_cmd =
  let plan =
    Arg.(required & pos 0 (some non_dir_file) None &
         info [] ~docv:"PLAN" ~doc:"Terraform plan JSON for a new deployment.")
  in
  let info =
    Cmd.info "show"
      ~doc:"Show all reachability in a new Terraform plan (no prior state)."
  in
  Cmd.v info Term.(const run_show $ Logs_cli.level () $ plan)

let diff_cmd =
  let before =
    Arg.(required & pos 0 (some string) None &
         info [] ~docv:"BEFORE" ~doc:"Terraform plan JSON before the change.")
  in
  let after =
    Arg.(required & pos 1 (some non_dir_file) None &
         info [] ~docv:"AFTER" ~doc:"Terraform plan JSON after the change.")
  in
  let if_new =
    Arg.(value & flag &
         info ["show-if-new"] ~doc:"If BEFORE does not exist, show all reachability in AFTER as new.")
  in
  let info =
    Cmd.info "diff"
      ~doc:"Show reachability changes between two Terraform plan snapshots."
  in
  Cmd.v info Term.(const run $ Logs_cli.level () $ if_new $ before $ after)

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
  let info = Cmd.info "weir" ~version:"%%VERSION%%" ~doc:"Azure network verifier." in
  exit (Cmd.eval (Cmd.group info [show_cmd; diff_cmd; check_cmd]))
