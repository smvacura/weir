open Parser.Azure_types

module Id = struct
  type t = string

  let compare = String.compare
end

type t = {
    name : string;
    location : azure_location
  }

module Map = Map.Make(Id)