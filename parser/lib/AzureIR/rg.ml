open Parser.Azure_types

module Id = struct
  type t = string

  let compare = String.compare

  let of_string (s : string) : t = s
end

type t = {
    name : Id.t;
    location : azure_location;
    managed_by : string;
    tags : tag list
  }

let get_name rg = rg.name

let make_rg name location managed_by tags = {
  name = name;
  location = location;
  managed_by = managed_by;
  tags = tags
}

module Map = Map.Make(Id)