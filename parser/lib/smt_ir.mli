type smt_sort = 
| Int
| Bool
| BitVec of int

type smt_term =
| Symbol of string
| Num of int 
| Bool of bool
| BV of int * int
| Eq of smt_term * smt_term
| LT of smt_term * smt_term
| LE of smt_term * smt_term
| ITE of smt_term * smt_term * smt_term
| And of smt_term list
| Or of smt_term list
| Not of smt_term
| Imp of smt_term * smt_term


type smt_cmd =
| SetLogic of string
| DeclareConst of string * smt_sort
| Assert of smt_term
| CheckSat
| GetModel