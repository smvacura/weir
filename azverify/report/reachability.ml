open Frontends
open Pathfinder

let pp_examples fmt (examples : Diff.packet_examples) = 
  match examples with
  | Single (hdr, _)    -> Encoder.pp_packet_header fmt hdr
  | Sample (hdrs, _)   -> Fmt.(list ~sep:cut Encoder.pp_packet_header) fmt hdrs
  | Exhaustive hdrs    -> Fmt.(list ~sep:cut Encoder.pp_packet_header) fmt hdrs

let pp_prefix fmt (d : Diff.packet_diff) = 
  match d.added, d.removed with
  | Some _, None   -> Fmt.(styled `Green string) fmt "+"
  | None,   Some _ -> Fmt.(styled `Red   string) fmt "-"
  | Some _, Some _ -> Fmt.(styled `Yellow string) fmt "~"
  | None,   None   -> Fmt.string fmt "?"

let pp_packet_diff fmt (d : Diff.packet_diff) =
    Fmt.pf fmt "@[<v 2>%a %a -> %a@,%a%a@]"
      pp_prefix d
      Fmt.(styled `Bold string) d.src
      Fmt.(styled `Bold string) d.dst
      (Fmt.option (Fmt.styled `Green pp_examples)) d.added
      (Fmt.option (Fmt.styled `Red   pp_examples)) d.removed

let get_reachability fmt before_path after_path =
  let before_world = AzureTF.AzureTFParser.get_resources before_path in
  let after_world  = AzureTF.AzureTFParser.get_resources after_path in
  let diffs = Diff.compute before_world after_world in
  Fmt.(list ~sep:cut pp_packet_diff) fmt diffs