type expr =
  | IntLit of int
  | StringLit of string
  | Ident of string
  | Cidr of int * int * int * int * int
  | PortProto of int * string
  | Wildcard
  | Range of expr * expr
  | BinOp of binop * expr * expr
  | UnOp of unop * expr
  | Dot of expr * string
  | Index of expr * expr
  | List of expr list  (* for [...] *)

and binop =
  | Lt | Le | Gt | Ge | Eq | Ne
  | And | Or

and unop =
  | Not

type flow_path = expr list  (* sequence of nodes in a flow *)

type flow_block = {
  paths: flow_path list;
  where_clause: (string * expr) list option;  (* variable bindings *)
}

type enforce_stmt = {
  flows: flow_spec list;
  where_clause: expr option;
  via: expr list option;
  avoiding: expr list option;
  within: expr option;
}

and flow_spec =
  | Flow of expr * expr
  | NegFlow of expr * expr

type stmt =
  | Let of string * expr
  | FlowBlock of flow_block
  | When of {
      selector: expr;
      binding: string option;
      body: enforce_stmt list;
    }

type program = stmt list