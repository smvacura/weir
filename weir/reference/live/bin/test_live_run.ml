open Frontends
open Reference

let () =
  if Array.length Sys.argv < 2 then (prerr_endline "usage: crosscheck_run <plan_dir>"; exit 2);
  let dir = Sys.argv.(1) in
  let files = Sys.readdir dir  in 
  if not @@ Array.mem "plan.json" files then (prerr_endline "missing plan.json"; exit 2);
  if not @@ Array.mem "live.tsv" files then (prerr_endline "missing live.tsv"; exit 2);
  let world = Frontends.AzureTF.AzureTFParser.get_resources (Filename.concat dir "plan.json") in
  let graph = Reachability.build_graph world in
  let results = Live.Test_live.test_live_file (Filename.concat dir "live.tsv") world graph in
  List.iter
    (fun (r : Live.Test_live.fidelity_result) ->
      let field = Csv.Row.find r.row in
      Printf.printf "%-4s  azure=%-9s  reference=%-13s  %s:%s -> %s:%s %s  [%s -> %s]\n"
        (if r.agrees then "ok" else "DIFF")
        (field "result")
        (if r.result then "delivered" else "not delivered")
        (field "src_ip") (field "src_port")
        (field "dest_ip") (field "dest_port")
        (field "protocol")
        (field "src_address") (field "dest_address"))
    results;
  let total = List.length results in
  let disagreed = List.length (List.filter (fun (r : Live.Test_live.fidelity_result) -> not r.agrees) results) in
  Printf.printf "\n%s: %d rows, %d agree, %d disagree\n" dir total (total - disagreed) disagreed;
  if disagreed > 0 then exit 1
