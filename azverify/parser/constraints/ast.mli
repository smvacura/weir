type expectation =
  | Reachable
  | Unreachable

type header = {
  protocol : Parser.Network_types.protocol;
  ports    : Parser.Network_types.port list;
}

type rule = {
  name   : string;
  src    : string;
  dst    : string;
  on     : header;
  expect : expectation;
}

type policy = {
  version : int;
  rules   : rule list;
}

val any_header : header

val show_expectation : expectation -> string

val show_header : header -> string

val show_rule : rule -> string

val show_policy : policy -> string

val pp_policy : Format.formatter -> policy -> unit
