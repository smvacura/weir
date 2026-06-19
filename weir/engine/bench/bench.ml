open Frontends.AzureTF
open Pathfinder

let default_plan = "./test_plans/hsa_stress/plan.json"

let () =
  let path = if Array.length Sys.argv > 1 then Sys.argv.(1) else default_plan in
  let world = AzureTFParser.get_resources path in
  let timing = Hsa.run_analysis_timed world in
  Timing.report timing
