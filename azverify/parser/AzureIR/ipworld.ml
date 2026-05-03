open Parser.Tf_types

type t = {
  nics : Nic.t IPMap.t;
}

let equal t1 t2 =
  IPMap.equal (=) t1.nics t2.nics 

let empty = {
  nics = IPMap.empty;
}


let show world = 
  "Nics: " ^ Nic.show_nic_ip_map world.nics ^ "\n"