{ 

  exception LexError of string

  (* helper to raise lexer errors with position info *)
  let error lexbuf msg =
    let pos = Lexing.lexeme_start_p lexbuf in
    raise (LexError (Printf.sprintf "Line %d, column %d: %s"
      pos.pos_lnum (pos.pos_cnum - pos.pos_bol) msg))

  (* helper to lex cidr blocks*)
  let parse_cidr s =
    Scanf.sscanf s "%d.%d.%d.%d/%d" (fun a b c d p -> CIDR (a, b, c, d, p))
}

(* helper regexes  *)
let digit = ['0'-'9']
let alpha = ['a'-'z' 'A'-'Z']
let alphanum = alpha | digit | '_'
let whitespace = [' ' '\t']+
let newline = '\r' | '\n' | "\r\n"
let octet = digit | digit digit | digit digit digit

rule token = parse
  (* skip whitespace *)
  | whitespace    { token lexbuf }

  (* track newlines for error reporting *)
  | newline       { Lexing.new_line lexbuf; token lexbuf }

  (* comments: skip everything until end of line *)
  | "//" [^ '\n' '\r']*  { token lexbuf }

  (* keywords *)
  | "when"         { WHEN }
  | "as"           { AS } 
  | "enforce"      { ENFORCE}
  | "flow"         { FLOW}
  | "where"        { WHERE }
  | "let"          { LET } 
  | "pairs"        { PAIRS }
  | "via"          { VIA }
  | "avoiding"     { AVOIDING }
  | "within"       { WITHIN }
  | "if"          { IF }
  | "not"         { NOT }
  | "and"         { AND }
  | "or"          { OR }


  (* operators *)
  | '='           { ASSIGN }
  | '<'           { LT }
  | "<="          { LE }
  | '>'           { GT }
  | ">="          { GE }
  | "=="          { EQ }
  | "!="          { NE }
  | ".."          { RANGE }
  | "->"          { FLOW_ARROW }
  | "!->"         { NEGFLOW_ARROW }
  | "*"           { WILDCARD }

 (* cidr block*)
  | (digit+ '.' digit+ '.' digit+ '.' digit+ '/' digit+) as cidr
    { parse_cidr cidr }  (* helper function to split it *)

  (* delimiters *)
  | '('           { LPAREN }
  | ')'           { RPAREN }
  | '{'           { LBRACE }
  | '}'           { RBRACE }
  | '['           { LBRACKET }
  | ']'           { RBRACKET } 
  | ','           { COMMA }
  | '.'           { DOT }
  | ':'           { COLON }

  (* port/protool (eg 443/tcp) *)
  | (digit+ as port) '/' (alpha+ as proto)  { PORT_PROTO (int_of_string port, proto) }

  (* Integer literals *)
  | digit+ as n   { INT (int_of_string n) }

  (* Identifiers *)
  | alpha alphanum* as id  { IDENT id }

  (* string literals*)
  | '"' ([^ '"' '\n']* as s) '"'  { STRING s }

  (* End of file *)
  | eof           { EOF }

  (* Catch-all for unexpected characters *)
  | _ as c        { error lexbuf (Printf.sprintf "Unexpected character: '%c'" c) }
