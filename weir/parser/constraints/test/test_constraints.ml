open OUnit2
module Net = Parser.Network_types
module Ast = Constraints.Ast

let parse = Constraints.Parse.of_string

let parse_ok s =
  match parse s with
  | Ok p -> p
  | Error e -> assert_failure ("expected Ok, got Error: " ^ e)

let assert_err s =
  match parse s with
  | Ok _ -> assert_failure ("expected Error, got Ok for:\n" ^ s)
  | Error _ -> ()

let nth_rule p i = List.nth p.Ast.rules i

let valid_policy =
  "version: 0\n\
   rules:\n\
  \  - name: web-cannot-reach-db\n\
  \    from: azurerm_subnet.web\n\
  \    to: azurerm_subnet.db\n\
  \    expect: unreachable\n\
  \  - name: gw-can-reach-web\n\
  \    from: azurerm_subnet.gateway\n\
  \    to: azurerm_subnet.web\n\
  \    expect: reachable\n"

let parsing_tests = "parsing" >::: [
  "valid_multi_rule" >:: (fun _ ->
    let p = parse_ok valid_policy in
    assert_equal 0 p.Ast.version ~printer:string_of_int;
    assert_equal 2 (List.length p.Ast.rules) ~printer:string_of_int;
    let r0 = nth_rule p 0 in
    assert_equal "web-cannot-reach-db" r0.Ast.name;
    assert_equal "azurerm_subnet.web" r0.Ast.src;
    assert_equal "azurerm_subnet.db" r0.Ast.dst;
    assert_equal Ast.Unreachable r0.Ast.expect;
    assert_equal Ast.Reachable (nth_rule p 1).Ast.expect);

  "no_on_is_any_header" >:: (fun _ ->
    let p = parse_ok valid_policy in
    assert_equal Ast.any_header (nth_rule p 0).Ast.on
      ~printer:Ast.show_header);

  "on_protocol_and_ports" >:: (fun _ ->
    let p = parse_ok
      "version: 0\n\
       rules:\n\
      \  - name: a\n\
      \    from: azurerm_subnet.web\n\
      \    to: azurerm_subnet.db\n\
      \    on:\n\
      \      protocol: tcp\n\
      \      ports: [22, \"8000-8080\", \"*\"]\n\
      \    expect: unreachable\n"
    in
    let expected =
      { Ast.protocol = Net.Tcp;
        ports = [ Net.Single 22; Net.Range (8000, 8080); Net.Any ] }
    in
    assert_equal expected (nth_rule p 0).Ast.on ~printer:Ast.show_header);

  "on_protocol_only_defaults_ports_any" >:: (fun _ ->
    let p = parse_ok
      "version: 0\n\
       rules:\n\
      \  - name: a\n\
      \    from: azurerm_subnet.web\n\
      \    to: azurerm_subnet.db\n\
      \    on:\n\
      \      protocol: udp\n\
      \    expect: reachable\n"
    in
    assert_equal { Ast.protocol = Net.Udp; ports = [ Net.Any ] }
      (nth_rule p 0).Ast.on ~printer:Ast.show_header);

  "on_ports_only_defaults_protocol_any" >:: (fun _ ->
    let p = parse_ok
      "version: 0\n\
       rules:\n\
      \  - name: a\n\
      \    from: azurerm_subnet.web\n\
      \    to: azurerm_subnet.db\n\
      \    on:\n\
      \      ports: [443]\n\
      \    expect: reachable\n"
    in
    assert_equal { Ast.protocol = Net.Any; ports = [ Net.Single 443 ] }
      (nth_rule p 0).Ast.on ~printer:Ast.show_header);
]

(* A rule body missing one named field; reused across the error cases below. *)
let rule_missing field =
  let lines =
    [ "name", "a";
      "from", "azurerm_subnet.web";
      "to", "azurerm_subnet.db";
      "expect", "unreachable" ]
    |> List.filter (fun (k, _) -> k <> field)
    |> List.map (fun (k, v) -> "    " ^ k ^ ": " ^ v)
    |> String.concat "\n"
  in
  "version: 0\nrules:\n  -\n" ^ lines ^ "\n"

let error_tests = "errors" >::: [
  "missing_name"   >:: (fun _ -> assert_err (rule_missing "name"));
  "missing_from"   >:: (fun _ -> assert_err (rule_missing "from"));
  "missing_to"     >:: (fun _ -> assert_err (rule_missing "to"));
  "missing_expect" >:: (fun _ -> assert_err (rule_missing "expect"));

  "unknown_expect" >:: (fun _ ->
    assert_err
      "version: 0\nrules:\n  - name: a\n    from: x\n    to: y\n    expect: blocked\n");

  "unknown_protocol" >:: (fun _ ->
    assert_err
      "version: 0\n\
       rules:\n\
      \  - name: a\n\
      \    from: x\n\
      \    to: y\n\
      \    on:\n\
      \      protocol: sctp\n\
      \    expect: unreachable\n");

  "malformed_port" >:: (fun _ ->
    assert_err
      "version: 0\n\
       rules:\n\
      \  - name: a\n\
      \    from: x\n\
      \    to: y\n\
      \    on:\n\
      \      ports: [\"abc\"]\n\
      \    expect: unreachable\n");

  "unsupported_version" >:: (fun _ ->
    assert_err
      "version: 1\nrules:\n  - name: a\n    from: x\n    to: y\n    expect: reachable\n");

  "duplicate_names" >:: (fun _ ->
    assert_err
      "version: 0\n\
       rules:\n\
      \  - name: dup\n\
      \    from: x\n\
      \    to: y\n\
      \    expect: reachable\n\
      \  - name: dup\n\
      \    from: p\n\
      \    to: q\n\
      \    expect: unreachable\n");

  "top_level_not_mapping" >:: (fun _ -> assert_err "- a\n- b\n");

  "malformed_yaml" >:: (fun _ -> assert_err "version: 0\nrules: [oops\n");
]

let suite = "constraints_suite" >::: [
  parsing_tests;
  error_tests;
]

let () = run_test_tt_main suite
