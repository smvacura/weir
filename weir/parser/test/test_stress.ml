open OUnit2
open Frontends.AzureTF
open Terraform_ir
open Parser.Network_types
open Parser.Tf_types

(* Stress test: 1 RG, 10 VNets, 20 subnets per VNet = 200 subnets total.
   We do not build an expected World by hand; instead we assert structural
   properties of the parsed result (counts, names, CIDR correctness). *)

let n_vnets   = 10
let n_subnets = 20   (* per VNet *)

let plan_path = "test_plans/stress_test/plan.json"

let parsed_world =
  (* Parsed once and shared across all tests in this suite. *)
  lazy (AzureTFParser.get_resources plan_path)

let get_world () = Lazy.force parsed_world

(* ── count tests ── *)

let test_rg_count _ =
  let w = get_world () in
  assert_equal 1 (AddressMap.cardinal w.resource_groups)
    ~msg:"Expected exactly 1 resource group"
    ~printer:string_of_int

let test_vnet_count _ =
  let w = get_world () in
  assert_equal n_vnets (AddressMap.cardinal w.vnets)
    ~msg:(Printf.sprintf "Expected exactly %d VNets" n_vnets)
    ~printer:string_of_int

let test_subnet_count _ =
  let w = get_world () in
  let expected = n_vnets * n_subnets in
  assert_equal expected (AddressMap.cardinal w.subnets)
    ~msg:(Printf.sprintf "Expected exactly %d subnets" expected)
    ~printer:string_of_int

let test_no_nsgs _ =
  let w = get_world () in
  assert_equal 0 (AddressMap.cardinal w.nsgs)
    ~msg:"Expected no NSGs in stress plan"
    ~printer:string_of_int

let test_no_nics _ =
  let w = get_world () in
  assert_equal 0 (AddressMap.cardinal w.nics)
    ~msg:"Expected no NICs in stress plan"
    ~printer:string_of_int

(* ── RG identity ── *)

let test_rg_name _ =
  let w = get_world () in
  let rg = AddressMap.bindings w.resource_groups |> List.hd |> snd in
  assert_equal "stress-rg" (Rg.get_name rg)
    ~msg:"RG name should be stress-rg"
    ~printer:(fun s -> s)

(* ── per-VNet CIDR correctness ── *)

(* For vnet-V the expected address space is 10.V.0.0/16 *)
let test_vnet_address_spaces _ =
  let w = get_world () in
  for v = 0 to n_vnets - 1 do
    let vnet_name = Printf.sprintf "vnet-%d" v in
    let expected_cidr = Printf.sprintf "10.%d.0.0/16" v in
    let found = AddressMap.exists (fun _ vnet ->
      Vnet.get_name vnet = vnet_name &&
      (match Vnet.get_addresses vnet with
       | [cidr] -> CIDR.show cidr = expected_cidr
       | _ -> false))
      w.vnets
    in
    assert_bool
      (Printf.sprintf "VNet %s should have address space %s" vnet_name expected_cidr)
      found
  done

(* ── per-subnet CIDR correctness ── *)

(* For subnet-V-S the expected prefix is 10.V.S.0/24 *)
let test_subnet_cidrs _ =
  let w = get_world () in
  for v = 0 to n_vnets - 1 do
    for s = 0 to n_subnets - 1 do
      let subnet_name = Printf.sprintf "subnet-%d-%d" v s in
      let expected_cidr = Printf.sprintf "10.%d.%d.0/24" v s in
      let found = AddressMap.exists (fun _ subnet ->
        Subnet.get_name subnet = subnet_name &&
        (match Subnet.get_cidrs subnet with
         | [cidr] -> CIDR.show cidr = expected_cidr
         | _ -> false))
        w.subnets
      in
      assert_bool
        (Printf.sprintf "Subnet %s should have prefix %s" subnet_name expected_cidr)
        found
    done
  done

(* ── VNet ↔ Subnet parent linkage ── *)

(* Every subnet should point to a VNet whose name matches the subnet's V index *)
let test_subnet_vnet_linkage _ =
  let w = get_world () in
  AddressMap.iter (fun _ subnet ->
    let sname = Subnet.get_name subnet in
    (* names are subnet-V-S; extract V *)
    match String.split_on_char '-' sname with
    | ["subnet"; v_str; _] ->
      let vnet = Subnet.get_vnet subnet in
      let expected_vnet = Printf.sprintf "vnet-%s" v_str in
      assert_equal expected_vnet (Vnet.get_name vnet)
        ~msg:(Printf.sprintf "%s should belong to %s" sname expected_vnet)
        ~printer:(fun s -> s)
    | _ ->
      assert_failure (Printf.sprintf "Unexpected subnet name format: %s" sname)
  ) w.subnets

(* ── timing smoke test ── *)

(* Parse the file 10 more times and assert it doesn't blow up.
   We don't enforce a hard time bound (too environment-dependent),
   but any exception here is a failure. *)
let test_repeated_parse _ =
  for _ = 1 to 10 do
    let _w = AzureTFParser.get_resources plan_path in
    ()
  done

let suite = "stress_tests" >::: [
  "rg_count"            >:: test_rg_count;
  "vnet_count"          >:: test_vnet_count;
  "subnet_count"        >:: test_subnet_count;
  "no_nsgs"             >:: test_no_nsgs;
  "no_nics"             >:: test_no_nics;
  "rg_name"             >:: test_rg_name;
  "vnet_address_spaces" >:: test_vnet_address_spaces;
  "subnet_cidrs"        >:: test_subnet_cidrs;
  "subnet_vnet_linkage" >:: test_subnet_vnet_linkage;
  "repeated_parse"      >:: test_repeated_parse;
]
