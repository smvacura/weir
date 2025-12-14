open Parser.Azure_types

module Id = struct
  type t = string

  let compare = String.compare
end

type t = {
    name : string
  }

module Map = Map.Make(Id)