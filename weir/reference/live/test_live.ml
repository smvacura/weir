open Reference
open Parser.Network_types

type fidelity_result = {
  row : Csv.Row.t;
  result : bool;
  agrees : bool;
}

let read_tsv filename =
  Csv.Rows.load ~separator:'\t' ~has_header:true filename

let fail filename message =
  failwith (Printf.sprintf "%s: %s" filename message)

let parse_ip filename field ip = 
  match IPv4.of_string_opt ip with
  | Some ip -> IPv4.to_int32 ip
  | None -> fail filename (Printf.sprintf "malformed IP in field %s" field)

let parse_port filename field port =
  match int_of_string_opt port with
  | Some n when 0 <= n && n <= 65535 -> n
  | Some _ -> fail filename (Printf.sprintf "malformed port in field %s: value out of range" field)
  | None -> fail filename (Printf.sprintf "malformed port in field %s" field)

let parse_protocol filename protocol = 
  match protocol_of_string_opt protocol with
  | Some p -> p
  | None -> fail filename "malformed protocol"



let parse_subnet filename (world : Terraform_ir.World.t) src =
  if Parser.Tf_types.AddressMap.mem src world.subnets then src
  else fail filename (Printf.sprintf "no subnet %s in this plan" src)

let test_probe_result world graph filename row =
  let src = Csv.Row.find row "src_subnet" |> parse_subnet filename world in
  let src_ip = Csv.Row.find row "src_ip" |> parse_ip filename "src_ip" in
  let dest_ip = Csv.Row.find row "dest_ip" |> parse_ip filename "dest_ip" in
  let src_port = Csv.Row.find row "src_port" |> parse_port filename "src_port" in
  let dest_port = Csv.Row.find row "dest_port" |> parse_port filename "dest_port" in
  let protocol = Csv.Row.find row "protocol" |> parse_protocol filename in
  let live_result = Csv.Row.find row "result" in
  let packet = Packet.make
    ~src_ip
    ~dest_ip
    ~src_port
    ~dest_port
    ~protocol
  in
  let result = Reachability.reachable_in graph ~src packet in 
  let agrees = match live_result with 
  | "Connected" -> result
  | "Refused" -> result
  | "Dropped" -> not result
  | _ -> fail filename "malformed result"
  in { row; agrees; result } 

let test_live_file filename world graph =
  read_tsv filename |>
    List.map (fun row -> test_probe_result world graph filename row)

