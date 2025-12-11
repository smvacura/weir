
module IPv4 = struct
  open Int32

  let ( +% ) = Int32.add
  let ( -% ) = Int32.sub
  let ( *% ) = Int32.mul


  type t = int32

  let in_bounds w =
    w >= 0 && w < 256

  let octet_to_int32 o pos = 
    o lsl (8 * pos) 
    |> of_int

  let of_octets w x y z =
    if in_bounds w && in_bounds x && in_bounds y && in_bounds z
    then
      Some (
        octet_to_int32 w 0 +%
        octet_to_int32 x 1 +%
        octet_to_int32 y 2 +%
        octet_to_int32 z 3
      )
    else None
    
  let of_string s = 
    let blocks = String.split_on_char '.' s 
    |> List.map int_of_string_opt in
    match blocks with
    | [Some w; Some x; Some y; Some z] -> of_octets w x y z
    | _ -> None
    
end

module IPv4Mask = struct
  open Int32

  type t = int

  let mask_of_prefix n =
  if n < 0 || n > 32 then invalid_arg "mask_of_prefix: 0 <= n <= 32";
  let open Int32 in
  if n = 0 then zero
  else
    let shift = 32 - n in
    logand (shift_left 0xffffffffl shift) 0xffffffffl
end

module CIDR = struct
  type t = {
    ip : IPv4.t;
    mask : IPv4Mask.t
  }
end