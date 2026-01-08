module AzureTFParser = struct
  open Yojson
  open Parser.Azure_types
  open Azureir

  type t = string list

  type raw_world = {
    rgs : Safe.t list;
    vnets : Safe.t list;
    subnets : Safe.t list;
  }

  let raw_world_empty = {
    rgs = [];
    vnets = [];
    subnets = [];
  }

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
    let* id = Safe.Util.member "id" values
      |> parse_json_string_opt
      |> generate_parse_result "id" name "resource_group" in
    let* managed_by = Safe.Util.member "managed_by" values 
      |> parse_json_string_opt 
      |> generate_parse_result "managed_by" name "resource_group" in
    let tags = parse_tags_lenient json |> fst in 
    let* location = match Safe.Util.member "location" values with
    | `String s -> loc_of_string_opt s |> generate_loc_parse_result name "resource_group"
    | _ -> Error ("Cannot parse field location in resource " ^ name ^ " of type resource group")
    in

    Ok (Rg.make_rg name (Rg.Id.of_string id) location managed_by tags)

  let vnet_of_json world json =
    let values = Safe.Util.member "values" json in
    let (let*) = Result.bind in 
    let* name = Safe.Util.member "name" values 
      |> parse_json_string_opt 
      |> generate_parse_result "name" "" "vnet" in
    let* id = Safe.Util.member "id" values
      |> parse_json_string_opt
      |> generate_parse_result "id" name "vnet" in
    let* location = match Safe.Util.member "location" values with
    | `String s -> loc_of_string_opt s |> generate_loc_parse_result name "vnet"
    | _ -> Error ("Cannot parse field location in resource " ^ name ^ " of type vnet")
    in
    let* rg_name = Safe.Util.member "resource_group" values
      |> parse_json_string_opt
      |> generate_parse_result "resource_group" name "vnet"
    in
    let* rg = World.get_resource_group world rg_name
      |> Option.to_result ~none:("Could not find resource_group " ^ rg_name ^ " required by vnet " ^ name)
    in
    Ok (Vnet.make_vnet name (Vnet.Id.of_string id) location rg)

  let parse_subnet json =
    let values = Safe.Util.member "values" json in
    let name = Safe.Util.member "name" values in
    let rg_name = Safe.Util.member "resource_group_name" values in
    Subnet.make_subnet

  let json_resources file = 
    match Safe.from_file file
    |> Safe.Util.member "planned_values"
    |> Safe.Util.member "root_module"
    |> Safe.Util.member "resources"
    with
    | `Null -> None
    | arr -> Some (Safe.Util.to_list arr)

  
  let add_rg (world : World.t) (rg : Rg.t) = 
    let rgs' = Rg.Map.add (Rg.get_name rg) rg world.resource_groups in
    { world with resource_groups = rgs'}

  let add_subnet (world : World.t) (subnet : Subnet.t) =
    let subnets' = Subnet.Map.add (Subnet.get_name subnet) subnet world.subnets in
    { world with subnets = subnets'}
  
  let parse_resource_groups (world, err) rgs =
    let parse_rg (world, err) rg_json =
      match rg_of_json rg_json with
      | Ok rg -> (add_rg world rg, err)
      | Error e -> (world, e::err)
    in
    List.fold_left parse_rg (world, err) rgs
    
  let parse_resource json_resource (world : World.t) err =
    let resource_type : string option = Safe.Util.member "type" json_resource |> parse_json_string_opt in
    match resource_type with
    | Some "azurerm_resource_group" -> 
      (match rg_of_json json_resource with
      | Ok rg -> (add_rg world rg, err)
      | Error e -> (world, e::err))
    | None -> (world, err)


  let raw_parse_resource json_resource (world : raw_world) err =
    let resource_type : string option = Safe.Util.member "type" json_resource |> parse_json_string_opt in
    match resource_type with
    | Some "azurerm_resource_group" ->
      let name = Safe.Util.member "name" json_resource |> parse_json_string_opt in
      match name with
      | Some s -> let rgs' = json_resource::world.rgs in
        ({world with rgs = rgs'}, err)
      | None -> (world, ("Malformed resource group: cannot parse name from " ^ Safe.show json_resource)::err)
    | Some "azurerm_virtual_network" ->
      let name = Safe.Util.member "name" json_resource |> parse_json_string_opt in
      match name with
      | Some s -> let vnets' = json_resource::world.vnets in
        ({world with vnets = vnets'}, err)
      | None -> (world, ("Malformed resource group: cannot parse name from " ^ Safe.show json_resource)::err)
    | Some "azurerm_subnet" ->
      let name = Safe.Util.member "name" json_resource |> parse_json_string_opt in
      match name with
      | Some s -> let subnets' = json_resource::world.subnets in
        ({world with subnets = subnets'}, err)
      | None -> (world, ("Malformed resource group: cannot parse name from " ^ Safe.show json_resource)::err)
    | None -> (world, ("Unknown resource type from " ^ Safe.show json_resource)::err)

  
  let raw_parse_resources json =
    match json with
    | Some arr ->
      List.fold_left (fun (world, err) r -> raw_parse_resource r world err) (raw_world_empty, []) arr
    | None -> (raw_world_empty, ["Could not parse resource array"])

  let get_resources s = [String.capitalize_ascii s]

end