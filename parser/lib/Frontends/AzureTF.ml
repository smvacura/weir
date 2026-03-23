module AzureTFParser = struct
  open Yojson
  open Parser.Azure_types
  open Parser.Network_types
  open Parser.Tf_types
  open Azureir


  type raw_world = {
    rgs : Safe.t list;
    vnets : Safe.t list;
    subnets : Safe.t list;
    nsgs : Safe.t list;
    nics : Safe.t list;
    pips : Safe.t list;
  }

  let raw_world_empty = {
    rgs = [];
    vnets = [];
    subnets = [];
    nsgs = [];
    nics = [];
    pips = [];
  }


  type subnet_inv_idx = Vnet.t IdKeyMap.t

  type address_index = string IdKeyMap.t

  let subnet_inv_idx_empty : subnet_inv_idx = IdKeyMap.empty

  let show_inv_idx (index : subnet_inv_idx) = 
    "{" ^
    (index
    |> IdKeyMap.bindings
    |> List.map (fun (k,v) -> (IdKey.show k) ^ ":" ^ Vnet.show v)
    |> String.concat ",")
    ^ "}"

  
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

    Ok (Rg.make 
      ~name:name 
      ~subscription:"DEFAULT" 
      ~address:address 
      ~location:location 
      ~managed_by:managed_by 
      ~tags:tags)

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
      let* address = Safe.Util.member "address" json
        |> generate_parse_string_result_required "address" name "subnet" in
      let* subnet_block = Safe.Util.member "subnet" json
        |> string_list_of_json_opt
        |> (fun l_opt -> 
          match l_opt with
          | Some l -> get_subnet_cidr_block name l
          | None -> (Ok []))
      in
      let rg = Vnet.get_rg vnet in
      Ok (Subnet.make 
      ~name:name 
      ~subscription:"DEFAULT" 
      ~address:address 
      ~resource_group:rg 
      ~vnet:vnet 
      ~addresses:subnet_block)
    
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
    let* address = Safe.Util.member "address" json 
      |> generate_parse_string_result_required "address" name "resource_group" in
    let* location = match Safe.Util.member "location" values with
    | `String s -> loc_of_string_opt s |> generate_loc_parse_result name "vnet"
    | _ -> Error ("Cannot parse field location in resource " ^ name ^ " of type vnet")
    in
    let* rg_name = Safe.Util.member "resource_group_name" values
      |> generate_parse_string_result_required "resource_group_name" name "vnet"
    in
    let* rg = World.get_resource_group world "DEFAULT" rg_name
      |> Option.to_result ~none:("Could not find resource_group " ^ rg_name ^ " required by vnet " ^ name)
    in
    let addresses = Safe.Util.member "address_space" values
    in
    let* cidr_list = parse_address_block_opt addresses
      |> Option.to_result ~none:("Cannot parse address block of vnet " ^ name)
    in
    let vnet = (Vnet.make 
      ~name:name 
      ~subscription:"DEFAULT" 
      ~address:address 
      ~location:location 
      ~resource_group:rg 
      ~addresses:cidr_list) in
    let inline_subnets = begin
    match Safe.Util.member "subnet" values with
    | `List subnet_json -> inline_subnets_of_json vnet subnet_json
    | `Null -> []
    | _ -> []
    end in
    Ok (vnet, inline_subnets)

  let subnet_of_json world index json =
    let values = Safe.Util.member "values" json in
    let (let*) = Result.bind in
    let* name = Safe.Util.member "name" values 
      |> generate_parse_string_result_required "name" "" "subnet"
    in
    let* address = Safe.Util.member "address" json 
      |> generate_parse_string_result_required "address" name "vnet" in
    let* rg_name = Safe.Util.member "resource_group_name" values
      |> generate_parse_string_result_required "resource_group_name" name "subnet"
    in
    let* vnet_name = Safe.Util.member "virtual_network_name" values
      |> generate_parse_string_result_required "virtual_network_name" name "subnet"
    in
    let* rg = World.get_resource_group world "DEFAULT" rg_name
      |> Option.to_result ~none:("Could not find resource_group " ^ rg_name ^ " required by subnet " ^ name)
    in
    let* vnet = IdKeyMap.find_opt (IdKey.of_strings "DEFAULT" rg_name vnet_name) world.vnets
      |> Option.to_result ~none:("Cannot find vnet required by subnet " ^ address)
    in
    let addresses = Safe.Util.member "address_prefixes" values
    in
    let* cidr_list = parse_address_block_opt addresses
      |> Option.to_result ~none:("Cannot parse address block of subnet " ^ name)
    in
    Ok (Subnet.make 
      ~name:name 
      ~subscription:"DEFAULT" 
      ~address:address 
      ~resource_group:rg 
      ~vnet:vnet 
      ~addresses:cidr_list)

  let endpoint_of_element (json : Safe.t) (kind : string) =
    match json with
    | `String s -> Nsg.SecurityRule.endpoint_of_list_opt [Some s] kind
    | `List l -> Nsg.SecurityRule.endpoint_of_list_opt (List.map Safe.Util.to_string_option l) kind
    | _ -> None
  

  let is_nonempty_json_list (json : Safe.t) key =
    match Safe.Util.member key json with
    | `List l -> List.length l > 0 
    | _ -> false
  
  let is_nonempty_json_string (json : Safe.t) key =
    match Safe.Util.member key json with
    | `String s -> String.length s > 0
    | _ -> false
  
  let endpoint_of_json (json : Safe.t) target =
    if is_nonempty_json_string json (target ^ "_address_prefix")
    then Nsg.SecurityRule.endpoint_of_list_opt 
        [(Safe.Util.member (target ^ "_address_prefix") json |> Safe.Util.to_string_option)]
        "addresses"
    else if is_nonempty_json_list json (target ^ "_address_prefixes")
    then Nsg.SecurityRule.endpoint_of_list_opt 
        (Safe.Util.member (target ^ "_address_prefixes") json |> Safe.Util.to_list |> (List.map (Safe.Util.to_string_option)))
        "addresses"
    else if is_nonempty_json_list json (target ^ "_application_security_group_ids")
    then Nsg.SecurityRule.endpoint_of_list_opt 
        (Safe.Util.member (target ^ "_application_security_group_ids") json |> Safe.Util.to_list |> (List.map (Safe.Util.to_string_option)))
        "application"
    else None


  let sequence_rev xs = 
    List.fold_left (fun acc x ->
      match acc, x with
      | Some vs, Some v -> Some (v :: vs)
      | _ -> None)
      (Some [])
      xs

  let sequence_result_rev xs =
    List.fold_left (fun acc x ->
      match acc, x with
      | Ok vs, Ok v -> Ok (v :: vs)
      | _, Error v -> Error v)
    (Ok [])
    xs
    
    
  let port_list_of_json (json : Safe.t) target = 
    if is_nonempty_json_string json (target ^ "_port_range")
    then let (let*) = Option.bind in 
         let* port_range = Safe.Util.member (target ^ "_port_range") json |>
            Safe.Util.to_string_option in
          port_list_of_string_list_opt [port_range]
    else if is_nonempty_json_list json (target ^ "_port_ranges")
    then let (let*) = Option.bind in 
         let* port_ranges = Safe.Util.member (target ^ "_port_ranges") json |>
         Safe.Util.to_list |>
         List.map Safe.Util.to_string_option |>
         sequence_rev in
         port_list_of_string_list_opt port_ranges
    else None 

  let rule_of_json rule = 
    let (let*) = Result.bind in
    let* name = Safe.Util.member "name" rule |>
      generate_parse_string_result_required "name" "" "security_rule"
    in
    let* description = Safe.Util.member "description" rule |>
      generate_parse_string_result "description" name "security_rule"
    in
    let* access = Safe.Util.member "access" rule |>
      Safe.Util.to_string_option |>
      Option.value ~default:"" |>
      Nsg.SecurityRule.access_of_string_opt |>
      Option.to_result ~none:("Could not parse access of rule " ^ name)
    in
    let* direction = Safe.Util.member "direction" rule |>
      Safe.Util.to_string_option |>
      Option.value ~default:"" |>
      Nsg.SecurityRule.direction_of_string_opt |>
      Option.to_result ~none:("Could not parse direction of rule " ^ name)
    in
    let* protocol = Safe.Util.member "protocol" rule |>
      Safe.Util.to_string_option |>
      Option.value ~default:"" |>
      protocol_of_string_opt |>
      Option.to_result ~none:("Could not parse protocol of rule " ^ name)
    in
    let* dest_prefixes = endpoint_of_json rule "destination"|> 
      Option.to_result ~none:("Could not parse destination of rule " ^ name)
    in
    let* source_prefixes = endpoint_of_json rule "source"|> 
      Option.to_result ~none:("Could not parse source of rule " ^ name)
    in
    let* source_ports = port_list_of_json rule "source" |>
      Option.to_result ~none:("Could not parse source ports of rule " ^ name)
    in
    let* dest_ports = port_list_of_json rule "destination" |>
      Option.to_result ~none:("Could not parse destination ports of rule " ^ name)
    in
    let* priority = Safe.Util.member "priority" rule |>
      Safe.Util.to_int_option |>
      Option.to_result ~none:("Could not parse priority of rule " ^ name)
    in
    Ok (
      Nsg.SecurityRule.make
      ~name:name
      ~description:description
      ~protocol:protocol
      ~source_ports:source_ports
      ~destination_ports:dest_ports
      ~source:source_prefixes
      ~destination:dest_prefixes
      ~access:access
      ~priority:priority
      ~direction:direction
    )


  let nsg_of_json world json = 
    let values = Safe.Util.member "values" json in
    let (let*) = Result.bind in
    let* name = Safe.Util.member "name" values |>
      generate_parse_string_result_required "name" "" "nsg"
    in
    let* rg_name = Safe.Util.member "resource_group_name" values
      |> generate_parse_string_result_required "resource_group_name" name "subnet"
    in
    let* rg = World.get_resource_group world "DEFAULT" rg_name
      |> Option.to_result ~none:("Could not find resource_group " ^ rg_name ^ " required by nsg " ^ name)
    in
    let* address = Safe.Util.member "address" json 
      |> generate_parse_string_result_required "address" name "resource_group" in
    let* location = match Safe.Util.member "location" values with
    | `String s -> loc_of_string_opt s |> generate_loc_parse_result name "nsg"
    | _ -> Error ("Cannot parse field location in resource " ^ name ^ " of type nsg")
    in
    let* security_rules = Safe.Util.member "security_rule" values |>
      Safe.Util.to_list |>
      List.map (rule_of_json) |>
      sequence_result_rev
    in
    let tags = Safe.Util.member "tags" values 
      |> parse_tags_lenient 
      |> fst in 
     Ok 
     (Nsg.make 
     ~name:name
     ~subscription:"DEFAULT"
     ~address:address
     ~location:location
     ~resource_group:rg
     ~rule_list:security_rules
     ~tags:tags)
    
  let ip_configuration_of_json ip_config_json = 
    let (let*) = Result.bind in
    let* name = Safe.Util.member "name" ip_config_json |>
      generate_parse_string_result_required "name" "" "nsg"
    in
    let* ip_type_string = Safe.Util.member "private_ip_address_version" ip_config_json |>
      generate_parse_string_result_required "private_ip_address_version" name "ip_configuration"
    in 
    let* ip_type = 
      ip_type_of_string_opt ip_type_string |>
      Option.to_result ~none:("Could not parse private_ip_address_version of configuration" ^ name)
    in
    let* ip_allocation_string = Safe.Util.member "private_ip_address_allocation" ip_config_json |>
      generate_parse_string_result_required "private_ip_address_allocation" name "ip_configuration"
    in
    let* ip_string = Safe.Util.member "private_ip_address" ip_config_json |> 
      generate_parse_string_result "" "" "" 
    in
    let ip = match ip_allocation_string, ip_string with
     | "Static", Some ip -> IPv4.of_string_opt ip
     | _ -> None
    in
    let allocation = match ip with
      | Some ip -> Resolved (Static ip : private_ip_assignment)
      | _ -> Unresolved
    in
    Ok (Nic.IpConfiguration.make
    ~name:name
    ~subscription:"DEFAULT"
    ~subnet:Unresolved
    ~ip_address_version:ip_type
    ~pip:Unresolved
    ~private_address_allocation:allocation
    ~primary:Unresolved)

  (* TODO: tighten up into one pass *)
  let ip_config_block_of_json (ip_config_json : Safe.t) =
    match ip_config_json with
    | `List ell -> sequence_result_rev @@ List.map ip_configuration_of_json ell  
    | _ -> Error "Could not parse IP configuration list"

  let nic_of_json world json =
    let values = Safe.Util.member "values" json in
    let (let*) = Result.bind in
    let* name = Safe.Util.member "name" values |>
      generate_parse_string_result_required "name" "" "nsg"
    in
    let* rg_name = Safe.Util.member "resource_group_name" values
      |> generate_parse_string_result_required "resource_group_name" name "subnet"
    in
    let* rg = World.get_resource_group world "DEFAULT" rg_name
      |> Option.to_result ~none:("Could not find resource_group " ^ rg_name ^ " required by nsg " ^ name)
    in
    let* address = Safe.Util.member "address" json 
      |> generate_parse_string_result_required "address" name "resource_group" in
    let* location = match Safe.Util.member "location" values with
    | `String s -> loc_of_string_opt s |> generate_loc_parse_result name "nsg"
    | _ -> Error ("Cannot parse field location in resource " ^ name ^ " of type nsg")
    in
    let* ip_configurations = Safe.Util.member "ip_configuration" values |>
      ip_config_block_of_json
    in
     Ok 
     (Nic.make 
     ~name:name
     ~subscription:"DEFAULT"
     ~address:address
     ~resource_group:rg
     ~location:location
     ~ip_configurations:ip_configurations)

  let pip_of_json world json =
    let values = Safe.Util.member "values" json in
    let (let*) = Result.bind in
    let* name = Safe.Util.member "name" values |>
      generate_parse_string_result_required "name" "" "pip"
    in
    let* rg_name = Safe.Util.member "resource_group_name" values
      |> generate_parse_string_result_required "resource_group_name" name "pip"
    in
    let* rg = World.get_resource_group world "DEFAULT" rg_name
      |> Option.to_result ~none:("Could not find resource_group " ^ rg_name ^ " required by pip " ^ name)
    in
    let* address = Safe.Util.member "address" json 
      |> generate_parse_string_result_required "address" name "resource_group" in
    let* location = match Safe.Util.member "location" values with
    | `String s -> loc_of_string_opt s |> generate_loc_parse_result name "pip"
    | _ -> Error ("Cannot parse field location in resource " ^ name ^ " of type pip")
    in
    let* ip_allocation_string = Safe.Util.member "allocation_method" json 
      |> generate_parse_string_result_required "allocation method" name "resource_group" in
    let* ip_allocation = match ip_allocation_string with
      | "Static" -> Ok (Static)
      | "Dynamic" -> Ok (Dynamic)
      | _ -> Error ("Cannot parse field allocation_method in resource " ^ name ^ " of type pip")
    in
    Ok (Pip.make
      ~name:name
      ~subscription:"DEFAULT"
      ~address:address
      ~resource_group:rg
      ~location:location
      ~allocation:ip_allocation)


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
    let rgs' = IdKeyMap.add (Rg.get_id rg) rg world.resource_groups in
    { world with resource_groups = rgs' }

  let index_rg rg address_index = 
    (IdKeyMap.add (Rg.get_id rg) (Rg.get_address rg) address_index)
  
  let add_vnet (world : World.t) (vnet : Vnet.t) =
    let vnet_id = IdKey.of_strings
      "DEFAULT"
      (Rg.get_name (Vnet.get_rg vnet))
      (Vnet.get_name vnet)
    in
    let vnets' = IdKeyMap.add vnet_id vnet world.vnets in
    { world with vnets = vnets' }
  
  let index_vnet vnet address_index = 
    (IdKeyMap.add (Vnet.get_id vnet) (Vnet.get_address vnet) address_index)

  let add_to_index (vnet: Vnet.t) (subnets: Subnet.t list) (index : subnet_inv_idx) =
    let rec aux vnet subnets (index : subnet_inv_idx) = 
      match subnets with
      | h::t -> aux vnet t (IdKeyMap.add (Subnet.get_id h) vnet  index)
      | [] -> index
    in
    aux vnet subnets index

  let add_subnet (world : World.t) (subnet : Subnet.t) =
    let subnets' = IdKeyMap.add (Subnet.get_id subnet) subnet world.subnets in
    { world with subnets = subnets'}

  let index_subnet subnet address_index =
    IdKeyMap.add (Subnet.get_id subnet) (Subnet.get_address subnet) address_index

  let add_nsg (world : World.t) (nsg : Nsg.t) =
    let nsgs' = IdKeyMap.add (Nsg.get_id nsg) nsg world.nsgs in
    { world with nsgs = nsgs'}
  
  let index_nsg nsg address_index =
    IdKeyMap.add (Nsg.get_id nsg) (Nsg.get_address nsg) address_index
  
  let add_nic (world : World.t) (nic : Nic.t) =
    let nics' = IdKeyMap.add (Nic.get_id nic) nic world.nics in
    { world with nics = nics' }

  let index_nic nic address_index =
    IdKeyMap.add (Nic.get_id nic) (Nic.get_address nic) address_index

  let add_pip (world : World.t) (pip : Pip.t) =
    let pips' = IdKeyMap.add (Pip.get_id pip) pip world.pips in
    { world with pips = pips'}
  
  let index_pip pip address_index =
    IdKeyMap.add (Pip.get_id pip) (Pip.get_address pip) address_index
  
  let parse_resource_groups (world, address_index, err) rgs =
    let parse_rg (world, address_index, err) rg_json =
      match rg_of_json rg_json with
      | Ok rg -> (add_rg world rg, index_rg rg address_index, err)
      | Error e -> (world, address_index, e::err)
    in
    List.fold_left parse_rg (world, address_index, err) rgs

  
  let parse_vnets (world, address_index, err) index vnets =
    let parse_vnet (world, address_index, err, subnet_index) vnet_json =
      match vnet_of_json world vnet_json with
      | Ok (vnet, subnets) -> begin
        match partition_results subnets with 
        |  Ok subnets -> (add_vnet world vnet, (index_vnet vnet address_index), err, (add_to_index vnet subnets index))
        | Error errors -> (add_vnet world vnet, (index_vnet vnet address_index), err @ errors, index)
      end
      | Error e -> (world, address_index, e::err, index)
    in
    List.fold_left parse_vnet (world, address_index, err, index) vnets

  let parse_subnets (world, address_index, err) index subnets = 
    let parse_subnet (world, address_index, err, index) subnet_json =
      match subnet_of_json world index subnet_json with
      | Ok subnet -> (add_subnet world subnet, index_subnet subnet address_index, err, index)
      | Error e -> (world, address_index, e::err, index)
    in
    List.fold_left parse_subnet (world, address_index, err, index) subnets

  let parse_nsgs (world, address_index, err) nsgs = 
    let parse_nsg (world, address_index, err) nsg_json = 
      match nsg_of_json world nsg_json with
      | Ok nsg -> (add_nsg world nsg, index_nsg nsg address_index, err)
      | Error e -> (world, address_index, e::err)
    in
    List.fold_left parse_nsg (world, address_index, err) nsgs
  
  let parse_nics (world, address_index, err) nics = 
    let parse_nic (world, address_index, err) nic_json =
      match nic_of_json world nic_json with
      | Ok nic -> (add_nic world nic, index_nic nic address_index, err)
      | Error e -> (world, address_index, e::err)
    in
    List.fold_left parse_nic (world, address_index, err) nics

  let parse_pips (world, address_index, err) pips =
    let parse_pip (world, address_index, err) pip_json =
      match pip_of_json world pip_json with
      | Ok pip -> (add_pip world pip, index_pip pip address_index, err)
      | Error e -> (world, address_index, e::err)
    in
    List.fold_left parse_pip (world, address_index, err) pips
    
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
    | Some "azurerm_resource_group" -> begin
      let name = Safe.Util.member "name" json_resource |> parse_json_string_opt in
      match name with
      | Some s -> let rgs' = json_resource::world.rgs in
        ({world with rgs = rgs'}, err)
      | None -> (world, ("Malformed resource group: cannot parse name from " ^ Safe.show json_resource)::err)
    end
    | Some "azurerm_virtual_network" -> begin
      let name = Safe.Util.member "name" json_resource |> parse_json_string_opt in
      match name with
      | Some s -> let vnets' = json_resource::world.vnets in
        ({world with vnets = vnets'}, err)
      | None -> (world, ("Malformed resource group: cannot parse name from " ^ Safe.show json_resource)::err)
    end
    | Some "azurerm_subnet" -> begin
      let name = Safe.Util.member "name" json_resource |> parse_json_string_opt in
      match name with
      | Some s -> let subnets' = json_resource::world.subnets in
        ({world with subnets = subnets'}, err)
      | None -> (world, ("Malformed resource group: cannot parse name from " ^ Safe.show json_resource)::err)
    end
    | Some "azurerm_network_security_group" -> begin
      let name = Safe.Util.member "name" json_resource |> parse_json_string_opt in
      match name with
      | Some s -> let nsgs' = json_resource::world.nsgs in
      ({world with nsgs = nsgs'}, err)
    end
    | Some "azurerm_network_interface" -> begin
      let name = Safe.Util.member "name" json_resource |> parse_json_string_opt in
      match name with
      | Some s -> let nics' = json_resource::world.nics in
      ({world with nics = nics'}, err)
    end
    | Some "azurerm_public_ip" -> begin
      let name = Safe.Util.member "name" json_resource |> parse_json_string_opt in
      match name with
      | Some s -> let pips' = json_resource::world.pips in
      ({world with pips = pips'}, err)
    end
    | _ -> (world, ("Unknown resource type from " ^ Safe.show json_resource)::err)

  
  let raw_parse_resources json =
    match json with
    | Some arr ->
      List.fold_left (fun (world, err) r -> raw_parse_resource r world err) (raw_world_empty, []) arr
    | None -> (raw_world_empty, ["Could not parse resource array"])


  let print_string_list ell =
    let rec aux = function
    | [] -> ()
    | h::t -> print_string (h ^ "\n"); aux t;
  in
  aux ell


  let get_resources file =
    let json = json_resources file in
    let raw_world, err = raw_parse_resources json in
    let world, address_index, err = parse_resource_groups (World.empty, IdKeyMap.empty, err) raw_world.rgs in
    let world, address_index, err, vnet_inv_index = parse_vnets (world, address_index, err) subnet_inv_idx_empty raw_world.vnets in
    let world, address_index, err, vnet_inv_index = parse_subnets (world, address_index, err) vnet_inv_index raw_world.subnets in
    let world, address_index, err = parse_nsgs (world, address_index, err) raw_world.nsgs in 
    let world, address_index, err = parse_nics (world, address_index, err) raw_world.nics in
    let world, address_index, err = parse_pips (world, address_index, err) raw_world.pips in
    if List.length err > 0 then print_string_list err; 
    world




end