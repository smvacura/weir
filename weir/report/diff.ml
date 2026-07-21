open Frontends
open Parser.Network_types

let show_endpoint ip (port : port) =
  match port with
  | Any          -> Printf.sprintf "%s:*"     (CIDR.show ip)
  | Single n     -> Printf.sprintf "%s:%d"    (CIDR.show ip) n
  | Range (a, b) -> Printf.sprintf "%s:%d-%d" (CIDR.show ip) a b

let pp_header fmt (h : Engine.Encoder.packet_header) =
  Fmt.pf fmt "%-24s  %-24s  %s"
    (show_endpoint h.src_ip  h.src_port)
    (show_endpoint h.dest_ip h.dest_port)
    (show_protocol h.protocol)

let pp_examples fmt (examples : Engine.Diff.packet_examples) =
  match examples with
  | Single (hdr, _)    -> pp_header fmt hdr
  | Sample (hdrs, _)   -> Fmt.(list ~sep:cut pp_header) fmt hdrs
  | Exhaustive hdrs    -> Fmt.(list ~sep:cut pp_header) fmt hdrs

let pp_prefix fmt (d : Engine.Diff.packet_diff) =
  match d.added, d.removed with
  | Some _, None   -> Fmt.(styled `Green string) fmt "+"
  | None,   Some _ -> Fmt.(styled `Red   string) fmt "-"
  | Some _, Some _ -> Fmt.(styled `Yellow string) fmt "~"
  | None,   None   -> Fmt.string fmt "?"

let pp_packet_diff fmt (d : Engine.Diff.packet_diff) =
    Fmt.pf fmt "@[<v 2>%a %a -> %a@,%a%a@]"
      pp_prefix d
      Fmt.(styled `Bold string) d.src
      Fmt.(styled `Bold string) d.dst
      (Fmt.option (Fmt.styled `Green pp_examples)) d.added
      (Fmt.option (Fmt.styled `Red   pp_examples)) d.removed

let print fmt before_path after_path =
  let before_world = AzureTF.AzureTFParser.get_resources before_path in
  let after_world  = AzureTF.AzureTFParser.get_resources after_path in
  let diffs = Engine.Diff.compute before_world after_world in
  Fmt.(list ~sep:cut pp_packet_diff) fmt diffs

let print_new fmt plan_path =
  let world = AzureTF.AzureTFParser.get_resources plan_path in
  let diffs = Engine.Diff.compute Terraform_ir.World.empty world in
  Fmt.(list ~sep:cut pp_packet_diff) fmt diffs
