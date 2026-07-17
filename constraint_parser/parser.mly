%{
    open Ast
%}

// keywords
%token WHEN AS ENFORCE LET PAIRS
%token FLOW WHERE VIA AVOIDING WITHIN
%token IF NOT AND OR

// operators
%token ASSIGN LT LE GT GE EQ NE
%token RANGE FLOW_ARROW NEGFLOW_ARROW WILDCARD

//network types
%token <int * int * int * int * int> CIDR
%token <int * string> PORT_PROTO

//delimiters
%token LPAREN RPAREN LBRACE RBRACE LBRACKET RBRACKET
%token COMMA DOT COLON SEMICOLON

//literals and vars
%token <int> INT
%token <string> IDENT
%token <string> STRING

(* Entry point and return type *)
%start <program> program

%%

prog:
  | ss = list(stmt) EOF {ss}

stmt:
  | LET i = ident ASSIGN e = expr {Let i e}
  | FLOW LBRACE ps = separated_list(SEMICOLON, flow_path) RBRACE WHERE LBRACE ws = separated_list(SEMICOLON, where_binding) RBRACE 
    { flow_block { paths = ps; where_clause = ws }}