
module BinaryAssociation = struct
  
  type ('a, 'b) t = {
    address : string;
    r1 : 'a;
    r2 : 'b;
  }

  let make r1 r2 address : ('a, 'b) t = 
    { r1; r2; address }

  let get_r1 assoc = assoc.r1
  
  let get_r2 assoc = assoc.r2

  let get_address assoc = assoc.address

end