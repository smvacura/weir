module AzureTFParser = struct
  open Yojson
  open Parser.Azure_types

  type t = string list

  let parse_json_string_opt (json : Safe.t) =
    match json with
    | `String s -> Some s
    | _ -> None
      
  
  let generate_parse_result field_name resource_name resource_type res =
    match res with
    | Some s -> Ok s
    | None -> Error 
      ("Error: Could not parse field " 
      ^ field_name
      ^ " of resource "
      ^ resource_name
      ^ " of type "
      ^ resource_type)

  let generate_loc_parse_result resource_name resource_type res = 
    match res with
    | Some loc -> Ok loc
    | None -> Error
    ("Error: Could not parse field location of resource "
      ^ resource_name
      ^ " of type "
      ^ resource_type)

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


  let rg_of_json json = 
    let values = Safe.Util.member "values" json in
    let (let*) = Result.bind in
    let* name = Safe.Util.member "name" values 
      |> parse_json_string_opt 
      |> generate_parse_result "name" "" "resource_group" in
    let* managed_by = Safe.Util.member "managed_by" values 
      |> parse_json_string_opt 
      |> generate_parse_result "managed_by" name "resource_group" in
    let tags = parse_tags_lenient json |> fst in 
    let* location = match Safe.Util.member "location" values with
    | `String s -> loc_of_string_opt s |> generate_loc_parse_result name "resource_group"
    | _ -> Error ("Cannot parse field location in resource " ^ name ^ " of type resource group")
    in

    Ok (Azureir.Rg.make_rg name location managed_by tags)


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

  
  let add_rg (world : Azureir.World.t) (rg : Azureir.Rg.t) = 
    let name = "" in
    let rgs' = Azureir.Rg.Map.add (Azureir.Rg.Id.of_string name) rg world.resource_groups in
    { world with resource_groups = rgs'}
  
  let parse_resource json_resource (world : Azureir.World.t) err =
    let resource_type : string option = Safe.Util.member "type" json_resource |> parse_json_string_opt in
    match resource_type with
    | Some "azurerm_resource_group" -> 
      (match rg_of_json json_resource with
      | Ok rg -> (add_rg world rg, err)
      | Error e -> (world, e::err))
    | None -> (world, err)


  let get_resources s = [String.capitalize_ascii s]

end