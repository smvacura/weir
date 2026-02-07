open OUnit2
open Parser.Network_types

let ip_tests = "ipv4_tests" >::: [
  "zero_ip" >:: (fun _ -> 
    assert_equal (IPv4.of_string_opt "0.0.0.0") (Some (IPv4.of_int32 (0l))));
  "max_ip" >:: (fun _ ->
    assert_equal (Some (IPv4.of_int32 0xFFFFFFFFl)) (IPv4.of_string_opt "255.255.255.255"));
  "localhost" >:: (fun _ ->
    assert_equal (Some (IPv4.of_int32 0x7F000001l)) (IPv4.of_string_opt "127.0.0.1"));
  "invalid_octet" >:: (fun _ ->
    assert_equal None (IPv4.of_string_opt "256.0.0.1"));
  "too_few_octets" >:: (fun _ ->
    assert_equal None (IPv4.of_string_opt "192.168.1"));
  "too_many_octets" >:: (fun _ ->
    assert_equal None (IPv4.of_string_opt "192.168.1.1.1"));
  "non_numeric" >:: (fun _ ->
    assert_equal None (IPv4.of_string_opt "192.168.a.1"));
]

let mask_tests = "mask_tests" >::: [
  "zero" >:: (fun _ ->
    assert_equal (Some (IPv4Mask.of_int32 0l)) (IPv4Mask.of_string_opt "0"));
  "full_mask" >:: (fun _ ->
    assert_equal (Some (IPv4Mask.of_int32 0xFFFFFFFFl)) (IPv4Mask.of_string_opt "32"));
  "slash_24" >:: (fun _ ->
    assert_equal (Some (IPv4Mask.of_int32 0xFFFFFF00l)) (IPv4Mask.of_string_opt "24"));
  "slash_16" >:: (fun _ ->
    assert_equal (Some (IPv4Mask.of_int32 0xFFFF0000l)) (IPv4Mask.of_string_opt "16"));
  "slash_8" >:: (fun _ ->
    assert_equal (Some (IPv4Mask.of_int32 0xFF000000l)) (IPv4Mask.of_string_opt "8"));
  "invalid_too_large" >:: (fun _ ->
    assert_equal None (IPv4Mask.of_string_opt "33"));
  "invalid_negative" >:: (fun _ ->
    assert_equal None (IPv4Mask.of_string_opt "-1"));
  "invalid_non_numeric" >:: (fun _ ->
    assert_equal None (IPv4Mask.of_string_opt "abc"));
]

let make_cidr ip m = 
  CIDR.make (IPv4.of_int32 ip) (IPv4Mask.of_int32 m)
let cidr_tests = "cidr_tests" >::: [
  "zero" >:: (fun _ ->
    assert_equal (Some (make_cidr 0l 0l)) (CIDR.of_string_opt "0.0.0.0/0"));
  "single_host" >:: (fun _ ->
    assert_equal (Some (make_cidr 0xC0A80101l 0xFFFFFFFFl)) (CIDR.of_string_opt "192.168.1.1/32"));
  "slash_24" >:: (fun _ ->
    assert_equal (Some (make_cidr 0xC0A80100l 0xFFFFFF00l)) (CIDR.of_string_opt "192.168.1.0/24"));
  "slash_16" >:: (fun _ ->
    assert_equal (Some (make_cidr 0xC0A80000l 0xFFFF0000l)) (CIDR.of_string_opt "192.168.0.0/16"));
  "slash_8" >:: (fun _ ->
    assert_equal (Some (make_cidr 0x0A000000l 0xFF000000l)) (CIDR.of_string_opt "10.0.0.0/8"));
  "invalid_mask" >:: (fun _ ->
    assert_equal None (CIDR.of_string_opt "192.168.1.1/33"));
  "missing_slash" >:: (fun _ ->
    assert_equal None (CIDR.of_string_opt "192.168.1.1"));
  "invalid_ip" >:: (fun _ ->
    assert_equal None (CIDR.of_string_opt "256.1.1.1/24"));
]

let suite = "network_types_suite" >::: [
  ip_tests;
  mask_tests;
  cidr_tests;
]