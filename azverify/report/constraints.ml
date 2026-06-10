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

let print fmt results =
  Fmt.(list ~sep:cut pp_check_result) fmt results
