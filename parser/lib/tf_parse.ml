module TFParser = struct
  open Yojson
  open Azure_types

  type t = string list

  let parse_json_string (json : Safe.t) =
    match json with
    | `String s -> Some s
    | _ -> None

  let parse_tags_lenient (json : Yojson.Safe.t) : tag list * string list =
  match json with
  | `Assoc fields ->
      List.fold_left
        (fun (acc, errors) (k, v) ->
          match v with
          | `String s ->
              ((make_tag k s) :: acc, errors)
          | _ ->
              let err =
                Printf.sprintf "skipping tag '%s': non-string value %s"
                  k (Yojson.Safe.to_string v)
              in
              (acc, err :: errors))
        ([], [])
        fields
      |> fun (tags, errors) -> (List.rev tags, List.rev errors)
  | _ ->
      ([], [ "expected JSON object for tags" ])


  let parse_rg json = 
    let values = Safe.Util.member "values" json in
    let (let*) = Option.bind in
    let* name = Safe.Util.member "name" values |> parse_json_string in
    let* managed_by = Safe.Util.member "managed_by" values |> parse_json_string in
    let tags = parse_tags_lenient json |> fst in 
    let* location = match Safe.Util.member "location" values with
    | `String s -> loc_of_string_opt s
    | _ -> None in

    Some (make_rg name location managed_by tags)

  let parse_subnet json =
    let values = Safe.Util.member "values" json in
    let name = Safe.Util.member "name" values in
    let rg_name = Safe.Util.member "resource_group_name" values in
    ""

  let json_resources file = 
    match Safe.from_file file
    |> Safe.Util.member "planned_values"
    |> Safe.Util.member "root_module"
    |> Safe.Util.member "resources"
    with
    | `Null -> None
    | arr -> Some arr

  let get_resources s = [String.capitalize_ascii s]

end