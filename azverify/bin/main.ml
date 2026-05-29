let usage = "Usage: azverify diff <before.json> <after.json>"

let () =
  if Array.length Sys.argv < 4 || Sys.argv.(1) <> "diff" then begin
    Printf.eprintf "%s\n" usage;
    exit 1
  end;
  let before_path = Sys.argv.(2) in
  let after_path  = Sys.argv.(3) in
  Report.Reachability.get_reachability Fmt.stdout before_path after_path;
  Format.pp_print_newline Fmt.stdout ()
