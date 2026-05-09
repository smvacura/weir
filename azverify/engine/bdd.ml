type manager = {
  man : MLBDD.man;
  nvars : int ref;
}

type bdd = MLBDD.t

(* Portable serialisation: MLBDD nodes are manager-local pointers; we fold
   each BDD to a tree before marshalling so it can survive across processes. *)
type bdd_tree =
  | TFalse
  | TTrue
  | TNot of bdd_tree
  | TIf of bdd_tree * int * bdd_tree

let init ?(vars = 0) ?(cache = 1024) () =
  ignore vars;
  { man = MLBDD.init ~cache (); nvars = ref 0 }

let quit _mgr = ()

let dtrue mgr = MLBDD.dtrue mgr.man
let dfalse mgr = MLBDD.dfalse mgr.man

let ithvar mgr v =
  if v + 1 > !(mgr.nvars) then mgr.nvars := v + 1;
  MLBDD.ithvar mgr.man v

let dand _mgr a b = MLBDD.dand a b
let dor _mgr a b = MLBDD.dor a b
let xor _mgr a b = MLBDD.xor a b
let dnot _mgr b = MLBDD.dnot b

(* MLBDD.ite takes (f_false, var_index, f_true); we need (cond_bdd, then, else). *)
let ite _mgr cond t f =
  MLBDD.dor (MLBDD.dand cond t) (MLBDD.dand (MLBDD.dnot cond) f)

(* vars is a BDD cube; its support is exactly the set of variables to quantify. *)
let exists _mgr ~vars bdd = MLBDD.exists (MLBDD.support vars) bdd
let forall _mgr ~vars bdd = MLBDD.forall (MLBDD.support vars) bdd

(* MLBDD has no care-set cofactor; returning bdd is always correct
   (the care set only permits simplification, not mutation). *)
let cofactor _mgr bdd ~care:_ = bdd

let equal = MLBDD.equal
let is_true = MLBDD.is_true
let is_false = MLBDD.is_false

(* Each cube from itersat is a partial assignment covering k of n variables;
   the remaining (n - k) are don't-cares, each doubling the count. *)
let sat_count mgr bdd =
  let n = !(mgr.nvars) in
  let acc = ref 0.0 in
  MLBDD.itersat (fun assignment ->
    let k = List.length assignment in
    acc := !acc +. 2.0 ** float_of_int (n - k)
  ) bdd;
  !acc

let allsat mgr bdd =
  let n = !(mgr.nvars) in
  List.map (fun assignment ->
    let arr = Array.make n None in
    List.iter (fun (polarity, var) ->
      if var < n then arr.(var) <- Some polarity
    ) assignment;
    arr
  ) (MLBDD.allsat bdd)

let itersat mgr bdd f =
  let n = !(mgr.nvars) in
  MLBDD.itersat (fun assignment ->
    let arr = Array.make n None in
    List.iter (fun (polarity, var) ->
      if var < n then arr.(var) <- Some polarity
    ) assignment;
    f arr
  ) bdd

let to_tree bdd =
  MLBDD.fold (fun e ->
    match e with
    | MLBDD.False -> TFalse
    | MLBDD.True -> TTrue
    | MLBDD.Not t -> TNot t
    | MLBDD.If (lo, v, hi) -> TIf (lo, v, hi)
  ) bdd

let of_tree man tree =
  let rec go = function
    | TFalse -> MLBDD.dfalse man
    | TTrue -> MLBDD.dtrue man
    | TNot t -> MLBDD.dnot (go t)
    | TIf (lo, v, hi) ->
      let lo' = go lo and hi' = go hi in
      let var_bdd = MLBDD.ithvar man v in
      MLBDD.dor (MLBDD.dand (MLBDD.dnot var_bdd) lo') (MLBDD.dand var_bdd hi')
  in
  go tree

let dump mgr bdds filename =
  let oc = open_out_bin filename in
  Marshal.to_channel oc (!(mgr.nvars), List.map to_tree bdds) [];
  close_out oc

let load mgr filename =
  let ic = open_in_bin filename in
  let (n, trees) : int * bdd_tree list = Marshal.from_channel ic in
  close_in ic;
  if n > !(mgr.nvars) then mgr.nvars := n;
  List.map (of_tree mgr.man) trees

let reduce_heap mgr = MLBDD.flush mgr.man
