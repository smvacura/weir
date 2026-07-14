open Parser.Network_types

let ports_to_string ports =
  match ports with
  | [] -> "*"
  | _  -> String.concat "," (List.map show_port ports)

let pp_status fmt sat =
  if sat
  then Fmt.(styled `Green string) fmt "PASS"
  else Fmt.(styled `Red   string) fmt "FAIL"

let pp_check_result fmt (r : Check.Check_rules.check_result) =
  Fmt.pf fmt "%a  %a -> %a  [%s %s]"
    pp_status r.sat
    Fmt.(styled `Bold string) r.src
    Fmt.(styled `Bold string) r.dest
    (show_protocol r.protocol)
    (ports_to_string r.ports)

let pp_summary fmt results =
  let total = List.length results in
  let passed = List.length (List.filter (fun (r : Check.Check_rules.check_result) -> r.sat) results) in
  let style = if passed = total then `Green else `Red in
  Fmt.(styled style (fun fmt () -> pf fmt "%d/%d rules passed" passed total)) fmt ()

let print fmt results =
  Fmt.pf fmt "%a@,@,%a"
    Fmt.(list ~sep:cut pp_check_result) results
    pp_summary results
