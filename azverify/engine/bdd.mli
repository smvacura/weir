type manager
type bdd



val init  : ?vars:int -> ?cache:int -> unit -> manager

val quit  : manager -> unit

val dtrue   : manager -> bdd

val dfalse  : manager -> bdd

val ithvar  : manager -> int -> bdd

val dand    : manager -> bdd -> bdd -> bdd

val dor     : manager -> bdd -> bdd -> bdd

val xor     : manager -> bdd -> bdd -> bdd

val ite     : manager -> bdd -> bdd -> bdd -> bdd

val dnot    : manager -> bdd -> bdd

val exists  : manager -> vars:bdd -> bdd -> bdd

val forall  : manager -> vars:bdd -> bdd -> bdd

val cofactor : manager -> bdd -> care:bdd -> bdd

val equal   : bdd -> bdd -> bool

val is_true  : bdd -> bool

val is_false : bdd -> bool

val sat_count : manager -> bdd -> float

val allsat    : manager -> bdd -> bool option array list

val itersat   : manager -> bdd -> (bool option array -> unit) -> unit

val dump : manager -> bdd list -> string -> unit

val load : manager -> string -> bdd list

val reduce_heap : manager -> unit