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

type smt_cmd = 
| SetLogic of string
| DeclareConst of string * smt_sort
| Assert of smt_term
| CheckSat
| GetModel
