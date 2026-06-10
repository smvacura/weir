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

let () =
  let info = Cmd.info "azverify" ~version:"%%VERSION%%" ~doc:"Azure network verifier." in
  exit (Cmd.eval (Cmd.group info [diff_cmd]))
