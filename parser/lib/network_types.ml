
module IPv4 = struct
  open Int32

  let ( +% ) = Int32.add
  let ( -% ) = Int32.sub
  let ( *% ) = Int32.mul

  type t = int32
  [@@deriving show]

  let in_bounds w =
    w >= 0 && w < 256

  let octet_to_int32 o pos = 
    o lsl (24 - (8 * pos)) 
    |> of_int

  let of_octets_opt w x y z =
    if in_bounds w && in_bounds x && in_bounds y && in_bounds z
    then
      Some (
        octet_to_int32 w 0 +%
        octet_to_int32 x 1 +%
        octet_to_int32 y 2 +%
        octet_to_int32 z 3
      )
    else None
    
  let of_string_opt s = 
    let blocks = String.split_on_char '.' s 
    |> List.map int_of_string_opt in
    match blocks with
    | [Some w; Some x; Some y; Some z] -> of_octets_opt w x y z
    | _ -> None
    
  let show ip =
    let open Int32 in
    let a = to_int (shift_right_logical ip 24) land 0xFF in
    let b = to_int (shift_right_logical ip 16) land 0xFF in
    let c = to_int (shift_right_logical ip 8) land 0xFF in
    let d = to_int ip land 0xFF in
    Printf.sprintf "%d.%d.%d.%d" a b c d

    let of_int32 (i : int32) : t = i
end

module IPv4Mask = struct

  type t = int32

  let mask_of_prefix n =
  if n < 0 || n > 32 then invalid_arg "mask_of_prefix: 0 <= n <= 32";
  let open Int32 in
  if n = 0 then zero
  else
    let shift = 32 - n in
    logand (shift_left 0xffffffffl shift) 0xffffffffl

  
 let make_opt prefix =
  if prefix >= 0 && prefix <= 32
  then 
    let mask = Int32.shift_left 0xFFFFFFFFl (32 - prefix) in
    Some mask
  else None

  let of_string_opt s =
    match int_of_string_opt s with
    | Some m -> make_opt m
    | None -> None

  let of_int32 (i : int32) : t =
    i
  
  let show mask =
  (* count leading 1s *)
    let rec count_bits m acc =
      if m = 0l then acc
      else count_bits (Int32.shift_left m 1) (acc + 1)
    in
    string_of_int (count_bits mask 0)

  let pp fmt mask = 
    Format.fprintf fmt "%s" (show mask)
end

module CIDR = struct
  type t = {
    ip : IPv4.t;
    mask : IPv4Mask.t
  }

  let make ip mask = {
    ip=ip;
    mask=mask;
  }

  let of_string_opt s = 
    match String.split_on_char '/' s with
    | [s_ip; s_m] -> begin
      match IPv4.of_string_opt s_ip, IPv4Mask.of_string_opt s_m with
      | Some ip, Some m -> Some {ip=ip; mask=m}
      | _ -> None
    end
    | _ -> None
  
  let of_opt_string_opt s_opt = 
    match s_opt with
    | Some s -> of_string_opt s
    | None -> None
  
  let of_list_res l = 
    let rec aux l acc =
      match l with
      | h::t -> begin
        match of_string_opt h with
        | Some cidr -> aux t (cidr::acc)
        | None -> Error "Malformed CIDR block"
      end
      | [] -> Ok acc
      in
      aux l []

  let of_list_opt_strict l = 
    let rec aux l acc =
      match l with
      | h::t -> begin
        match of_opt_string_opt h with
        | Some cidr -> aux t (cidr::acc)
        | None -> None
      end
      | [] -> Some acc
      in
      aux l []

  let show cidr =
    Printf.sprintf "%s/%s" (IPv4.show cidr.ip) (IPv4Mask.show cidr.mask)
  let show_list cidrs = 
    let rec aux cidrs acc =
    match cidrs with
    | [] -> (acc ^ "]")
    | h::t -> aux t (acc ^ (show h) ^ ",")
    in
    aux cidrs "["

  let pp fmt cidr =
    Format.fprintf fmt "%s" (show cidr)
end

type protocol =
 | Tcp 
 | Udp 
 | Icmp 
 | Any

let protocol_of_string_opt protocol_string =
  match protocol_string with
  | "Tcp" -> Some Tcp
  | "Udp" -> Some Udp
  | "Icmp" -> Some Icmp
  | "*" -> Some Any
  | _ -> None

let show_protocol protocol = 
  match protocol with
  | Tcp -> "TCP"
  | Udp -> "UDP"
  | Icmp -> "ICMP"
  | Any -> "*"

let pp_protocol fmt protocol = 
  Format.fprintf fmt "%s" (show_protocol protocol)


type port = 
 | Single of int 
 | Range of int * int 
 | Any


let port_of_string_opt port_str =
  match  String.split_on_char '-' port_str with
  | ["*"] -> Some Any
  | [lo; hi] -> 
    let (let*) = Option.bind in
    let* ilo = int_of_string_opt lo in
    let* ihi = int_of_string_opt hi in
    Some (Range (ilo, ihi))
  | [port] -> 
    let (let*) = Option.bind in
    let* iport = int_of_string_opt port in
    Some (Single iport)

let port_list_of_string_list_opt port_str_list = 
  List.fold_left 
    (fun acc port_str ->
      match acc, port_of_string_opt port_str with
      | Some ps, Some Any -> Some [Any]
      | Some ps, Some p -> Some (p :: ps)
      | _ -> None)
    (Some []) port_str_list

let show_port port = 
  match port with
  | Single p -> string_of_int p
  | Range (lo, hi) -> "[" ^ (string_of_int lo) ^ ".." ^ (string_of_int hi) ^ "]"
  | Any -> "*"

let pp_port fmt port = 
  Format.fprintf fmt "%s" (show_port port)

let string_of_port_list ports = 
  let rec aux ports acc = 
    match ports with
    | [] -> acc
    | h::t -> aux t (acc ^ (show_port h ^ ","))
  in
  (aux ports "[") ^ "]"

type ip_assignment =
  | Static of IPv4.t
  | Dynamic of CIDR.t
  [@@deriving show]