open Terraform_ir
open Frontends

let () =
  if Array.length Sys.argv < 2 then (prerr_endline "usage: crosscheck_run <plan.json>"; exit 2);
  let path = Sys.argv.(1) in
  let world : World.t = AzureTF.AzureTFParser.get_resources path in
  let verdicts = Crosscheck.compare_packets world (Crosscheck.sample_pairwise world) in
  Printf.printf "Ground truth vs HSA engine on %d subnet-pair packet(s):\n\n"
    (List.length verdicts);
  List.iter (fun v -> print_endline (Crosscheck.show_verdict v)) verdicts;
  let dis = Crosscheck.disagreements verdicts in
  Printf.printf "\n%d agree, %d disagree\n"
    (List.length verdicts - List.length dis) (List.length dis)
