open Parser.Tf_types

type t = {
  nics : Nic.t IPMap.t;
}

val empty : t

val equal : t -> t-> bool

val show : t -> string