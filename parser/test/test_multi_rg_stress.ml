open OUnit2
open Frontends.AzureTF
open Azureir
open Parser.Network_types
open Parser.Tf_types

(* Multi-RG stress test: 5 RGs, 5 VNets per RG, 39 subnets per VNet.
   Total: 5 + 25 + 975 = 1005 resources.
   VNet R-V gets address space 10.(R*5+V).0.0/16.
   Subnet R-V-S gets prefix   10.(R*5+V).S.0/24. *)

let n_rgs     = 5
let n_vnets   = 5   (* per RG *)
let n_subnets = 39  (* per VNet *)

let plan_path = "test_plans/multi_rg_stress/plan.json"

let parsed_world = lazy (AzureTFParser.get_resources plan_path)

let get_world () = Lazy.force parsed_world

(* ── count tests ── *)

let test_rg_count _ =
  let w = get_world () in
  assert_equal n_rgs (IdKeyMap.cardinal w.resource_groups)
    ~msg:(Printf.sprintf "Expected exactly %d resource groups" n_rgs)
    ~printer:string_of_int

let test_vnet_count _ =
  let w = get_world () in
  let expected = n_rgs * n_vnets in
  assert_equal expected (IdKeyMap.cardinal w.vnets)
    ~msg:(Printf.sprintf "Expected exactly %d VNets" expected)
    ~printer:string_of_int

let test_subnet_count _ =
  let w = get_world () in
  let expected = n_rgs * n_vnets * n_subnets in
  assert_equal expected (AddressMap.cardinal w.subnets)
    ~msg:(Printf.sprintf "Expected exactly %d subnets" expected)
    ~printer:string_of_int

let test_no_nsgs _ =
  let w = get_world () in
  assert_equal 0 (IdKeyMap.cardinal w.nsgs)
    ~msg:"Expected no NSGs in multi-RG stress plan"
    ~printer:string_of_int

let test_no_nics _ =
  let w = get_world () in
  assert_equal 0 (IdKeyMap.cardinal w.nics)
    ~msg:"Expected no NICs in multi-RG stress plan"
    ~printer:string_of_int

(* ── RG identity ── *)

(* Every rg-R (R=0..4) must be present. *)
let test_rg_names _ =
  let w = get_world () in
  for r = 0 to n_rgs - 1 do
    let rg_name = Printf.sprintf "rg-%d" r in
    let found = IdKeyMap.exists (fun _ rg -> Rg.get_name rg = rg_name) w.resource_groups in
    assert_bool
      (Printf.sprintf "Resource group %s not found" rg_name)
      found
  done

(* ── VNet CIDR correctness ── *)

(* vnet-R-V has address space 10.(R*5+V).0.0/16 *)
let test_vnet_address_spaces _ =
  let w = get_world () in
  for r = 0 to n_rgs - 1 do
    for v = 0 to n_vnets - 1 do
      let vnet_name    = Printf.sprintf "vnet-%d-%d" r v in
      let net_idx      = r * n_vnets + v in
      let expected_cidr = Printf.sprintf "10.%d.0.0/16" net_idx in
      let found = IdKeyMap.exists (fun _ vnet ->
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
  done

(* ── Subnet CIDR correctness (spot-check first, middle, last per VNet) ── *)

(* For subnet-R-V-S the expected prefix is 10.(R*5+V).S.0/24.
   Checking all 975 via a double-lookup would be fine but slow; we spot-check
   three representative subnets per VNet (S=0, mid, last) for speed. *)
let test_subnet_cidrs _ =
  let w = get_world () in
  let check r v s =
    let net_idx      = r * n_vnets + v in
    let subnet_name  = Printf.sprintf "subnet-%d-%d-%d" r v s in
    let expected_cidr = Printf.sprintf "10.%d.%d.0/24" net_idx s in
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
  in
  for r = 0 to n_rgs - 1 do
    for v = 0 to n_vnets - 1 do
      check r v 0;
      check r v (n_subnets / 2);
      check r v (n_subnets - 1)
    done
  done

(* ── VNet ↔ Subnet parent linkage ── *)

(* Every subnet-R-V-S must point to vnet-R-V *)
let test_subnet_vnet_linkage _ =
  let w = get_world () in
  AddressMap.iter (fun _ subnet ->
    let sname = Subnet.get_name subnet in
    match String.split_on_char '-' sname with
    | ["subnet"; r_str; v_str; _] ->
      let vnet      = Subnet.get_vnet subnet in
      let expected  = Printf.sprintf "vnet-%s-%s" r_str v_str in
      assert_equal expected (Vnet.get_name vnet)
        ~msg:(Printf.sprintf "%s should belong to %s" sname expected)
        ~printer:(fun s -> s)
    | _ ->
      assert_failure (Printf.sprintf "Unexpected subnet name format: %s" sname)
  ) w.subnets

(* ── Cross-RG isolation ── *)

(* No subnet in rg-R should resolve to a VNet that lives in a different RG.
   We derive the subnet's RG via its VNet (Subnet has no direct get_rg). *)
let test_subnet_rg_isolation _ =
  let w = get_world () in
  AddressMap.iter (fun _ subnet ->
    let sname   = Subnet.get_name subnet in
    let vnet    = Subnet.get_vnet subnet in
    let vnet_rg = Vnet.get_rg vnet in
    (* The subnet name encodes its RG index; vnet name encodes the same index. *)
    match String.split_on_char '-' sname with
    | ["subnet"; r_str; _; _] ->
      let expected_rg = Printf.sprintf "rg-%s" r_str in
      assert_equal expected_rg (Rg.get_name vnet_rg)
        ~msg:(Printf.sprintf "%s: expected VNet in %s but got %s"
                sname expected_rg (Rg.get_name vnet_rg))
        ~printer:(fun s -> s)
    | _ ->
      assert_failure (Printf.sprintf "Unexpected subnet name format: %s" sname)
  ) w.subnets

(* ── Per-RG VNet and subnet counts ── *)

(* Each RG must contain exactly n_vnets VNets. *)
let test_per_rg_vnet_count _ =
  let w = get_world () in
  for r = 0 to n_rgs - 1 do
    let rg_name  = Printf.sprintf "rg-%d" r in
    let rg_vnets = IdKeyMap.fold (fun _ vnet acc ->
      if Rg.get_name (Vnet.get_rg vnet) = rg_name then acc + 1 else acc)
      w.vnets 0
    in
    assert_equal n_vnets rg_vnets
      ~msg:(Printf.sprintf "RG %s should have %d VNets" rg_name n_vnets)
      ~printer:string_of_int
  done

(* Each RG must contain exactly n_vnets * n_subnets subnets.
   Derive RG membership from the subnet's VNet. *)
let test_per_rg_subnet_count _ =
  let w = get_world () in
  let expected = n_vnets * n_subnets in
  for r = 0 to n_rgs - 1 do
    let rg_name     = Printf.sprintf "rg-%d" r in
    let rg_subnets  = AddressMap.fold (fun _ subnet acc ->
      if Rg.get_name (Vnet.get_rg (Subnet.get_vnet subnet)) = rg_name
      then acc + 1 else acc)
      w.subnets 0
    in
    assert_equal expected rg_subnets
      ~msg:(Printf.sprintf "RG %s should have %d subnets" rg_name expected)
      ~printer:string_of_int
  done

(* ── Timing smoke test ── *)

let test_repeated_parse _ =
  for _ = 1 to 5 do
    let _w = AzureTFParser.get_resources plan_path in
    ()
  done

let suite = "multi_rg_stress_tests" >::: [
  "rg_count"              >:: test_rg_count;
  "vnet_count"            >:: test_vnet_count;
  "subnet_count"          >:: test_subnet_count;
  "no_nsgs"               >:: test_no_nsgs;
  "no_nics"               >:: test_no_nics;
  "rg_names"              >:: test_rg_names;
  "vnet_address_spaces"   >:: test_vnet_address_spaces;
  "subnet_cidrs"          >:: test_subnet_cidrs;
  "subnet_vnet_linkage"   >:: test_subnet_vnet_linkage;
  "subnet_rg_isolation"   >:: test_subnet_rg_isolation;
  "per_rg_vnet_count"     >:: test_per_rg_vnet_count;
  "per_rg_subnet_count"   >:: test_per_rg_subnet_count;
  "repeated_parse"        >:: test_repeated_parse;
]
