open OUnit2
open Parser.Network_types
open Parser.Azure_types
open Parser.Tf_types

let () = Random.self_init ()

let repeat n f _ctxt = for _ = 1 to n do f () done

(* -- generators -- *)

let gen_octet () = Random.int 256

let gen_ip () =
  Option.get (IPv4.of_octets_opt (gen_octet ()) (gen_octet ()) (gen_octet ()) (gen_octet ()))

let gen_cidr_string () =
  let w = gen_octet () and x = gen_octet () and y = gen_octet () and z = gen_octet () in
  let p = Random.int 33 in
  let full = (w lsl 24) lor (x lsl 16) lor (y lsl 8) lor z in
  let mask_int =
    if p = 0 then 0
    else lnot ((1 lsl (32 - p)) - 1) land 0xFFFFFFFF
  in
  let net = full land mask_int in
  Printf.sprintf "%d.%d.%d.%d/%d"
    ((net lsr 24) land 0xFF) ((net lsr 16) land 0xFF)
    ((net lsr 8)  land 0xFF) (net land 0xFF) p

let gen_cidr_with_prefix () =
  let w = gen_octet () and x = gen_octet () and y = gen_octet () and z = gen_octet () in
  let p = 1 + Random.int 32 in
  let full = (w lsl 24) lor (x lsl 16) lor (y lsl 8) lor z in
  let mask_int = lnot ((1 lsl (32 - p)) - 1) land 0xFFFFFFFF in
  let net = full land mask_int in
  let s = Printf.sprintf "%d.%d.%d.%d/%d"
    ((net lsr 24) land 0xFF) ((net lsr 16) land 0xFF)
    ((net lsr 8)  land 0xFF) (net land 0xFF) p
  in
  (Option.get (CIDR.of_string_opt s), p)

let gen_port_num () = Random.int 65536

let gen_word () =
  String.init (1 + Random.int 15) (fun _ -> Char.chr (97 + Random.int 26))

(* -- printers -- *)

let show_ip_opt = function
  | None -> "None"
  | Some ip -> "Some " ^ IPv4.show ip

let show_cidr_opt = function
  | None -> "None"
  | Some c -> "Some " ^ CIDR.show c

let show_port_opt = function
  | None -> "None"
  | Some p -> "Some " ^ show_port p

let show_loc_opt = function
  | None -> "None"
  | Some l -> "Some " ^ show_azure_location l

(* -- IPv4 -- *)

let ipv4_tests = "ipv4_property_tests" >::: [
  "show_roundtrip" >:: repeat 2000 (fun () ->
    let ip = gen_ip () in
    assert_equal ~msg:(IPv4.show ip) ~printer:show_ip_opt
      (Some ip) (IPv4.of_string_opt (IPv4.show ip)));
  "of_octets_valid" >:: repeat 2000 (fun () ->
    let w = gen_octet () and x = gen_octet ()
    and y = gen_octet () and z = gen_octet () in
    assert_bool (Printf.sprintf "(%d,%d,%d,%d)" w x y z)
      (Option.is_some (IPv4.of_octets_opt w x y z)));
  "of_octets_out_of_bounds" >:: repeat 1000 (fun () ->
    let bad = 256 + Random.int 10000 in
    assert_equal ~msg:(string_of_int bad) ~printer:show_ip_opt
      None (IPv4.of_octets_opt bad 0   0   0  );
    assert_equal ~msg:(string_of_int bad) ~printer:show_ip_opt
      None (IPv4.of_octets_opt 0   bad 0   0  );
    assert_equal ~msg:(string_of_int bad) ~printer:show_ip_opt
      None (IPv4.of_octets_opt 0   0   bad 0  );
    assert_equal ~msg:(string_of_int bad) ~printer:show_ip_opt
      None (IPv4.of_octets_opt 0   0   0   bad));
]

(* -- IPv4Mask -- *)

let mask_tests = "mask_property_tests" >::: [
  "prefix_roundtrip" >:: (fun _ ->
    for p = 0 to 32 do
      assert_equal ~msg:(string_of_int p)
        (Some (IPv4Mask.mask_of_prefix p))
        (IPv4Mask.of_string_opt (string_of_int p))
    done);
  "out_of_range" >:: (fun _ ->
    List.iter (fun p ->
      assert_equal ~msg:(string_of_int p)
        None (IPv4Mask.of_string_opt (string_of_int p)))
      [-1; 33; 100; -100; 999]);
]

(* -- CIDR -- *)

let cidr_tests = "cidr_property_tests" >::: [
  "show_roundtrip" >:: repeat 2000 (fun () ->
    let s = gen_cidr_string () in
    assert_equal ~msg:s ~printer:(fun x -> x)
      s (CIDR.show (Option.get (CIDR.of_string_opt s))));
  "interval_size" >:: repeat 2000 (fun () ->
    let (c, p) = gen_cidr_with_prefix () in
    let (lo, hi) = CIDR.get_interval c in
    let expected = Int32.of_int ((1 lsl (32 - p)) - 1) in
    assert_equal ~msg:(CIDR.show c) ~printer:(Printf.sprintf "%ld")
      expected (Int32.sub hi lo));
  "of_list_opt_strict_empty" >:: (fun _ ->
    assert_equal (Some []) (CIDR.of_list_opt_strict []));
  "of_list_opt_strict_rejects_none" >:: (fun _ ->
    assert_equal None (CIDR.of_list_opt_strict [None]));
]

(* -- protocol -- *)

let protocol_tests = "protocol_tests" >::: [
  "valid_strings" >:: (fun _ ->
    List.iter (fun s ->
      assert_bool s (Option.is_some (protocol_of_string_opt s)))
      ["Tcp"; "Udp"; "Icmp"; "*"]);
  "invalid_strings" >:: (fun _ ->
    List.iter (fun s ->
      assert_equal ~msg:s None (protocol_of_string_opt s))
      ["tcp"; "UDP"; "any"; ""; "HTTP"; "ICMP"]);
]

(* -- port -- *)

let port_tests = "port_property_tests" >::: [
  "single_roundtrip" >:: repeat 2000 (fun () ->
    let n = gen_port_num () in
    assert_equal ~msg:(string_of_int n) ~printer:show_port_opt
      (Some (Single n)) (port_of_string_opt (string_of_int n)));
  "wildcard" >:: (fun _ ->
    assert_equal ~printer:show_port_opt
      (Some Any) (port_of_string_opt "*"));
  "range" >:: repeat 2000 (fun () ->
    let a = gen_port_num () and b = gen_port_num () in
    let lo = min a b and hi = max a b in
    let s = Printf.sprintf "%d-%d" lo hi in
    assert_equal ~msg:s ~printer:show_port_opt
      (Some (Range (lo, hi))) (port_of_string_opt s));
  "range_unordered" >:: (fun _ ->
    assert_equal ~printer:show_port_opt
      (Some (Range (80, 22))) (port_of_string_opt "80-22"));
  "list_wildcard_collapses" >:: (fun _ ->
    assert_equal (Some [Any]) (port_list_of_string_list_opt ["*"]));
  "list_order_reversed" >:: (fun _ ->
    assert_equal
      (Some [Single 80; Single 22])
      (port_list_of_string_list_opt ["22"; "80"]));
]

(* -- azure_location -- *)

let all_locations = [
  AustraliaCentral;   AustraliaCentral2; AustraliaEast;      AustraliaSoutheast;
  AustriaEast;        BelgiumCentral;    Brazilsouth;         Brazilsoutheast;
  CanadaCentral;      CanadaEast;        CentralIndia;        CentralUs;
  ChileCentral;       EastAsia;          EastUs;              EastUs2;
  FranceCentral;      FranceSouth;       GermanyNorth;        GermanyWestCentral;
  IndonesiaCentral;   IsraelCentral;     ItalyNorth;          JapanEast;
  JapanWest;          KoreaCentral;      KoreaSouth;          MalaysiaWest;
  MexicoCentral;      NewZealandNorth;   NorthCentralUs;      NorthEurope;
  NorwayEast;         NorwayWest;        PolandCentral;       QatarCentral;
  SouthAfricaNorth;   SouthAfricaWest;   SouthCentralUs;      SouthIndia;
  SoutheastAsia;      SpainCentral;      SwedenCentral;       SwedenSouth;
  SwitzerlandNorth;   SwitzerlandWest;   UaeCentral;          UaeNorth;
  UkSouth;            UkWest;            WestCentralUs;       WestEurope;
  WestIndia;          WestUs;            WestUs2;             WestUs3;
]

let location_tests = "location_tests" >::: [
  "string_of_loc_roundtrip" >:: (fun _ ->
    List.iter (fun loc ->
      assert_equal ~msg:(show_azure_location loc) ~printer:show_loc_opt
        (Some loc) (loc_of_string_opt (string_of_loc loc)))
      all_locations);
]

(* -- IdKey -- *)

let idkey_tests = "idkey_property_tests" >::: [
  "roundtrip" >:: repeat 2000 (fun () ->
    let sub = gen_word () and rg = gen_word () and name = gen_word () in
    let key = IdKey.of_strings sub rg name in
    assert_equal ~msg:(IdKey.show key)
      (sub, rg, name) (IdKey.to_strings key));
]

let suite = "property_tests" >::: [
  ipv4_tests;
  mask_tests;
  cidr_tests;
  protocol_tests;
  port_tests;
  location_tests;
  idkey_tests;
]
