type expectation =
  | Reachable
  | Unreachable
[@@deriving show]

type header = {
  protocol : Parser.Network_types.protocol;
  ports    : Parser.Network_types.port list;
}
[@@deriving show]

type rule = {
  name   : string;
  src    : string;
  dst    : string;
  on     : header;
  expect : expectation;
}
[@@deriving show]

type policy = {
  version : int;
  rules   : rule list;
}
[@@deriving show]

let any_header =
  { protocol = Parser.Network_types.Any; ports = [ Parser.Network_types.Any ] }
