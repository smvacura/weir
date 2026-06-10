module Net = Parser.Network_types

let err fmt = Printf.ksprintf (fun s -> Error s) fmt

let rec map_result f = function
  | [] -> Ok []
  | x :: xs ->
    let (let*) = Result.bind in
    let* y = f x in
    let* ys = map_result f xs in
    Ok (y :: ys)

let as_mapping context (y : Yaml.value) =
  match y with
  | `O fields -> Ok fields
  | _ -> err "%s: expected a mapping" context

let as_sequence context (y : Yaml.value) =
  match y with
  | `A items -> Ok items
  | _ -> err "%s: expected a list" context

let member key fields = List.assoc_opt key fields

let string_field context key fields =
  match member key fields with
  | Some (`String s) -> Ok s
  | Some _ -> err "%s: field %S must be a string" context key
  | None -> err "%s: missing required field %S" context key

(* yaml-lib renders every numeric scalar as `Float, so version 0 arrives as 0. *)
let int_field context key fields =
  match member key fields with
  | Some (`Float f) -> Ok (int_of_float f)
  | Some _ -> err "%s: field %S must be an integer" context key
  | None -> err "%s: missing required field %S" context key

(* Net.protocol_of_string_opt only accepts the capitalized show form ("Tcp"); YAML
   users write the lowercase wire name, so map those directly here. *)
let protocol_of_yaml context (y : Yaml.value) =
  match y with
  | `String s ->
    (match String.lowercase_ascii s with
     | "tcp"       -> Ok Net.Tcp
     | "udp"       -> Ok Net.Udp
     | "icmp"      -> Ok Net.Icmp
     | "any" | "*" -> Ok Net.Any
     | _ -> err "%s: unknown protocol %S" context s)
  | _ -> err "%s: protocol must be a string" context

let port_of_yaml context (y : Yaml.value) =
  let scalar =
    match y with
    | `Float f  -> Ok (string_of_int (int_of_float f))
    | `String s -> Ok s
    | _ -> err "%s: port must be an integer or string" context
  in
  let (let*) = Result.bind in
  let* s = scalar in
  match Net.port_of_string_opt s with
  | Some p -> Ok p
  | None -> err "%s: malformed port %S" context s

let header_of_yaml context y_opt =
  let (let*) = Result.bind in
  match y_opt with
  | None -> Ok Ast.any_header
  | Some y ->
    let* fields = as_mapping (context ^ ".on") y in
    let* protocol =
      match member "protocol" fields with
      | None -> Ok (Net.Any : Net.protocol)
      | Some p -> protocol_of_yaml (context ^ ".on.protocol") p
    in
    let* ports =
      match member "ports" fields with
      | None -> Ok [ (Net.Any : Net.port) ]
      | Some p ->
        let* items = as_sequence (context ^ ".on.ports") p in
        map_result (port_of_yaml (context ^ ".on.ports")) items
    in
    Ok { Ast.protocol; ports }

let expectation_of_string context s =
  match String.lowercase_ascii s with
  | "reachable"   -> Ok Ast.Reachable
  | "unreachable" -> Ok Ast.Unreachable
  | _ -> err "%s: expect must be \"reachable\" or \"unreachable\", got %S" context s

let rule_of_yaml (y : Yaml.value) =
  let (let*) = Result.bind in
  let* fields = as_mapping "rule" y in
  let* name = string_field "rule" "name" fields in
  let* () = if name = "" then err "rule: field \"name\" must be non-empty" else Ok () in
  let context = Printf.sprintf "rule %S" name in
  let* src = string_field context "from" fields in
  let* () = if src = "" then err "%s: field \"from\" must be non-empty" context else Ok () in
  let* dst = string_field context "to" fields in
  let* () = if dst = "" then err "%s: field \"to\" must be non-empty" context else Ok () in
  let* on = header_of_yaml context (member "on" fields) in
  let* expect_s = string_field context "expect" fields in
  let* expect = expectation_of_string context expect_s in
  Ok { Ast.name; src; dst; on; expect }

let check_unique_names rules =
  let rec go seen = function
    | [] -> Ok ()
    | (r : Ast.rule) :: rest ->
      if List.mem r.name seen
      then err "duplicate rule name %S" r.name
      else go (r.name :: seen) rest
  in
  go [] rules

let of_string s =
  let (let*) = Result.bind in
  let* yaml =
    Yaml.of_string s |> Result.map_error (fun (`Msg m) -> "YAML parse error: " ^ m)
  in
  let* fields = as_mapping "document" yaml in
  let* version = int_field "document" "version" fields in
  let* () =
    if version = 0 then Ok ()
    else err "unsupported version %d (v0 expects version: 0)" version
  in
  let* rules_yaml =
    match member "rules" fields with
    | Some y -> as_sequence "rules" y
    | None -> err "document: missing required field \"rules\""
  in
  let* rules = map_result rule_of_yaml rules_yaml in
  let* () = check_unique_names rules in
  Ok { Ast.version; rules }

let of_file path =
  match In_channel.with_open_text path In_channel.input_all with
  | contents -> of_string contents
  | exception Sys_error msg -> Error msg
