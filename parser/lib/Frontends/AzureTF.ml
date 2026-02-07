module AzureTFParser = struct
  open Yojson
  open Parser.Azure_types
  open Azureir


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

  module SubnetIdMap = Map.Make(Subnet.Id)
  type subnet_inv_idx = Vnet.Id.t SubnetIdMap.t

  let subnet_inv_idx_empty : subnet_inv_idx = SubnetIdMap.empty

  
  let partition_results rs =
  let rec go oks errs = function
    | [] -> if errs = [] then Ok (List.rev oks) else Error (List.rev errs)
    | Ok x :: xs -> go (x :: oks) errs xs
    | Error e :: xs -> go oks (e :: errs) xs
  in go [] [] rs

  let parse_json_string_opt (json : Safe.t) =
    match json with
    | `String s -> Some s
    | _ -> None
      
  
  let generate_parse_string_result field_name resource_name resource_type (json : Safe.t) =
    match json with
    | `String s -> Ok (Some s)
    | `Null -> Ok None
    | _ -> Error 
      ("Error: Could not parse field " 
      ^ field_name
      ^ " of resource "
      ^ resource_name
      ^ " of type "
      ^ resource_type)
  
  let generate_parse_string_result_required field_name resource_name resource_type (json : Safe.t) =
  match json with
  | `String s -> Ok s
  | _ -> Error 
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
    let* address = Safe.Util.member "address" json 
      |> generate_parse_string_result_required "name" "" "resource_group" in
    let* name = Safe.Util.member "name" values 
      |> generate_parse_string_result_required "name" "" "resource_group" in
    let* managed_by = Safe.Util.member "managed_by" values 
      |> generate_parse_string_result "managed_by" name "resource_group" in
    let tags = Safe.Util.member "tags" json 
      |> parse_tags_lenient 
      |> fst in 
    let* location = match Safe.Util.member "location" values with
    | `String s -> loc_of_string_opt s |> generate_loc_parse_result name "resource_group"
    | _ -> Error ("Cannot parse field location in resource " ^ name ^ " of type resource group")
    in

    Ok (Rg.make_rg name (Rg.Id.of_string address) location managed_by tags)

  let list_of_json_opt (json_list : Safe.t) =
    match json_list with 
    | `List l -> Some l
    | _ -> None

  let string_list_of_json_opt (json_list : Safe.t) = 
    match json_list with
    | `List a -> Some (List.map Safe.Util.to_string_option a)
    | _ -> None
  
  let parse_address_block_opt addresses = 
    match string_list_of_json_opt addresses with
    | Some l -> Parser.Network_types.CIDR.of_list_opt_strict l
    | None -> None
    
  let inline_subnets_of_json vnet subnet_json = 
    let get_subnet_cidr_block subnet_name subnet_block =
      match Parser.Network_types.CIDR.of_list_opt_strict subnet_block with
      | Some l -> Ok l
      | None -> Error  ("Malformed addresses for subnet " ^ subnet_name)
    in

    let single_inline_of_json json = 
      let (let*) = Result.bind in 
      let* name = Safe.Util.member "name" json 
        |> generate_parse_string_result_required "name" "" "subnet" in
      let* id = Safe.Util.member "id" json
        |> generate_parse_string_result_required "id" name "subnet" in
      let* subnet_block = Safe.Util.member "subnet" json
        |> string_list_of_json_opt
        |> (fun l_opt -> 
          match l_opt with
          | Some l -> get_subnet_cidr_block name l
          | None -> (Ok []))
      in
      let rg = Vnet.get_rg vnet in
      Ok (Subnet.make_subnet name (Subnet.Id.of_string id) rg vnet subnet_block)
    
    in let rec aux json_list acc =
    match json_list with
    | h::t -> (single_inline_of_json h)::acc
    | [] -> acc
    in
    aux subnet_json []

  

  let vnet_of_json world json =
    let get_vnet_cidr_block vnet_name vnet_block =
      match Parser.Network_types.CIDR.of_list_opt_strict vnet_block with
      | Some l -> Ok l
      | None -> Error  ("Malformed addresses for subnet " ^ vnet_name)
    in
    let values = Safe.Util.member "values" json in
    let (let*) = Result.bind in 
    let* name = Safe.Util.member "name" values 
      |> generate_parse_string_result_required "name" "" "vnet" in
    let* id = Safe.Util.member "id" values
      |> generate_parse_string_result_required "id" name "vnet" in
    let* location = match Safe.Util.member "location" values with
    | `String s -> loc_of_string_opt s |> generate_loc_parse_result name "vnet"
    | _ -> Error ("Cannot parse field location in resource " ^ name ^ " of type vnet")
    in
    let* rg_name = Safe.Util.member "resource_group" values
      |> generate_parse_string_result_required "resource_group" name "vnet"
    in
    let* rg = World.get_resource_group world rg_name
      |> Option.to_result ~none:("Could not find resource_group " ^ rg_name ^ " required by vnet " ^ name)
    in
    let addresses = Safe.Util.member "addresses" values
    in
    let* cidr_list = parse_address_block_opt addresses
      |> Option.to_result ~none:("Cannot parse address block of vnet " ^ name)
    in
    let vnet = Vnet.make_vnet name (Vnet.Id.of_string id) location rg cidr_list in
    let inline_subnets = begin
    match Safe.Util.member "subnet" values with
    | `List subnet_json -> inline_subnets_of_json vnet subnet_json
    end in
    Ok (vnet, inline_subnets)

  let subnet_of_json world index json =
    let values = Safe.Util.member "values" json in
    let (let*) = Result.bind in
    let* name = Safe.Util.member "name" values 
      |> generate_parse_string_result_required "name" "" "subnet"
    in
    let* id = Safe.Util.member "id" values
      |> generate_parse_string_result_required "id" name "subnet" in
    let* location = match Safe.Util.member "location" values with
    | `String s -> loc_of_string_opt s |> generate_loc_parse_result name "subnet"
    | _ -> Error ("Cannot parse field location in resource " ^ name ^ " of type subnet")
    in
    let* rg_name = Safe.Util.member "resource_group" values
      |> generate_parse_string_result_required "resource_group" name "subnet"
    in
    let* rg = World.get_resource_group world rg_name
      |> Option.to_result ~none:("Could not find resource_group " ^ rg_name ^ " required by subnet " ^ name)
    in
    let* vnet = SubnetIdMap.find_opt (Subnet.Id.of_string id) index
      |> Option.to_result ~none:("Cannot find vnet required by subnet " ^ id)
    in
    let addresses = Safe.Util.member "addresses" values
    in
    let* cidr_list = parse_address_block_opt addresses
      |> Option.to_result ~none:("Cannot parse address block of vnet " ^ name)
    in
    Ok (Subnet.make_subnet name (Subnet.Id.of_string id) rg vnet cidr_list)


  let from_file_robust path =
    let content = In_channel.with_open_bin path In_channel.input_all in
    let content = 
      if String.length content >= 3 && 
        content.[0] = '\xEF' && content.[1] = '\xBB' && content.[2] = '\xBF'
      then String.sub content 3 (String.length content - 3)
      else content
    in
    Yojson.Safe.from_string content
  
  let json_resources file = 
    match from_file_robust file
    |> Safe.Util.member "planned_values"
    |> Safe.Util.member "root_module"
    |> Safe.Util.member "resources"
    with
    | `Null -> None
    | arr -> Some (Safe.Util.to_list arr)

  
  let add_rg (world : World.t) (rg : Rg.t) = 
    let rgs' = Rg.Map.add (Rg.get_name rg) rg world.resource_groups in
    { world with resource_groups = rgs' }
  
  let add_vnet (world : World.t) (vnet : Vnet.t) =
    let vnets' = Vnet.Map.add (Vnet.get_name vnet) vnet world.vnets in
    { world with vnets = vnets' }

  let add_to_index (vnet: Vnet.t) (subnets: Subnet.t list) (index : subnet_inv_idx) =
    let rec aux vnet_name subnets index = 
      match subnets with
      | h::t -> aux vnet_name t (SubnetIdMap.add (Subnet.get_name h) (Vnet.Id.of_string vnet_name)  index)
      | [] -> index
    in
    aux (Vnet.get_name_string vnet) subnets index

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

  
  let parse_vnets (world, err) index vnets =
    let parse_vnet (world, err, index) vnet_json =
      match vnet_of_json world vnet_json with
      | Ok (vnet, subnets) -> begin
        match partition_results subnets with 
        |  Ok subnets -> (add_vnet world vnet, err, (add_to_index vnet subnets index))
        | Error errors -> (add_vnet world vnet, err @ errors, index)
      end
      | Error e -> (world, e::err, index)
    in
    List.fold_left parse_vnet (world, err, index) vnets

  let parse_subnets (world, err) index subnets = 
    let parse_subnet (world, err, index) subnet_json =
      match subnet_of_json world index subnet_json with
      | Ok subnet -> (add_subnet world subnet, err, index)
      | Error e -> (world, e::err, index)
    in
    List.fold_left parse_subnet (world, err, index) subnets
    
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

  let get_resources file =
    let json = json_resources file in
    let raw_world, err = raw_parse_resources json in
    let world, err = parse_resource_groups (World.empty, err) raw_world.rgs in
    let world, err, vnet_inv_index = parse_vnets (world, err) subnet_inv_idx_empty raw_world.vnets in
    world




end