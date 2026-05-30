module AzureTFParser = struct
  open Yojson
  open Parser.Azure_types
  open Parser.Network_types
  open Parser.Tf_types
  open Terraform_ir

  exception Parse_error of string


  type raw_world = {
    rgs : Safe.t list;
    vnets : Safe.t list;
    subnets : Safe.t list;
    nsgs : Safe.t list;
    nics : Safe.t list;
    pips : Safe.t list;
    route_tables : Safe.t list;
    vnet_peerings : Safe.t list;
    asgs : Safe.t list;
    route_table_associations : Safe.t list;
    nsg_associations : Safe.t list;
    nic_nsg_associations : Safe.t list;
    nic_asg_associations : Safe.t list;
  }

  let raw_world_empty = {
    rgs = [];
    vnets = [];
    subnets = [];
    nsgs = [];
    nics = [];
    pips = [];
    route_tables = [];
    vnet_peerings = [];
    asgs = [];
    route_table_associations = [];
    nsg_associations = [];
    nic_nsg_associations = [];
    nic_asg_associations = [];
  }


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

  let subnet_of_json world json =
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
    let* vnet =
      AddressMap.fold (fun _ v acc ->
        if Vnet.get_name v = vnet_name && Rg.get_name (Vnet.get_rg v) = rg_name
        then Some v else acc)
        world.vnets None
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
      | Some ip -> (Static ip : private_ip_assignment)
      | _ -> Dynamic
    in
    Ok (Nic.IpConfiguration.make
    ~name:name
    ~subscription:"DEFAULT"
    ~subnet:Unresolved
    ~ip_address_version:ip_type
    ~pip:Unresolved
    ~private_address_allocation:allocation
    ~primary:None)

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
    let* ip_allocation_string = Safe.Util.member "allocation_method" values 
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

  let route_of_json json = 
    let (let*) = Result.bind in
    let* name = Safe.Util.member "name" json |>
      generate_parse_string_result_required "name" "" "route"
    in
    let* prefix = match Safe.Util.member "address_prefix" json with
    | `String s -> CIDR.of_string_opt s |> Option.to_result ~none:("Could not parse resource " ^ name ^ " of type route")
    | _ -> Error ("Could not parse resource " ^ name ^ " of type route")
    in
    let ip_opt = match Safe.Util.member "next_hop_in_ip_address" json with
    | `String s -> IPv4.of_string_opt s
    | _ -> None
    in
    let next_hop_in_ip_address = match ip_opt with
    | Some ip -> Resolved (StaticAppliance ip)
    | None -> Unresolved
    in
    let* next_hop = match Safe.Util.member "next_hop_type" json with
    | `String s -> next_hop_of_string_opt s ~ip:ip_opt |>
      Option.to_result ~none:("Could not parse next hop of route " ^ name)
    | _ -> Error ("Could not parse next hop of route " ^ name)
    in
    Ok (
      Route_table.Route.make
        ~name:name
        ~address_prefix:prefix
        ~next_hop:next_hop
        ~next_hop_in_ip_address:next_hop_in_ip_address
        ~source:UserDefined
    )
    

  let route_table_of_json world json =
    let values = Safe.Util.member "values" json in
    let (let*) = Result.bind in
    let* name = Safe.Util.member "name" values |>
      generate_parse_string_result_required "name" "" "pip"
    in
    let* rg_name = Safe.Util.member "resource_group_name" values
      |> generate_parse_string_result_required "resource_group_name" name "pip"
    in
    let* rg = World.get_resource_group world "DEFAULT" rg_name
      |> Option.to_result ~none:("Could not find resource_group " ^ rg_name ^ " required by route table " ^ name)
    in
    let* address = Safe.Util.member "address" json 
      |> generate_parse_string_result_required "address" name "resource_group" in
    let* location = match Safe.Util.member "location" values with
    | `String s -> loc_of_string_opt s |> generate_loc_parse_result name "pip"
    | _ -> Error ("Cannot parse field location in resource " ^ name ^ " of type route table")
    in
    let* bgp_route_propagation_enabled = match Safe.Util.member "bgp_route_propagation_enabled" values with
    | `Bool b -> Ok b
    | _ -> Ok true
    in
    let tags = Safe.Util.member "tags" values 
      |> parse_tags_lenient 
      |> fst in 
    let* routes = match Safe.Util.member "route" values with
      | `List l -> List.map route_of_json l |> sequence_result_rev
      | _ -> Error ("Could not parse field routes of resource " ^ name ^ " of type route table")
    in
    Ok (
      Route_table.make
      ~name:name
      ~subscription:"DEFAULT"
      ~address:address
      ~location:location
      ~resource_group:rg
      ~bgp_route_propagation_enabled:bgp_route_propagation_enabled
      ~routes:routes
      ~tags:tags
    )
    



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
  
    let json_config file = 
    match from_file_robust file
    |> Safe.Util.member "configuration"
    |> Safe.Util.member "root_module"
    |> Safe.Util.member "resources"
    with
    | `Null -> None
    | arr -> Some (Safe.Util.to_list arr)

  
  let add_rg (world : World.t) (rg : Rg.t) =
    let rgs' = AddressMap.add (Rg.get_address rg) rg world.resource_groups in
    { world with resource_groups = rgs' }

  let add_vnet (world : World.t) (vnet : Vnet.t) =
    let vnets' = AddressMap.add (Vnet.get_address vnet) vnet world.vnets in
    { world with vnets = vnets' }

  let add_subnet (world : World.t) (subnet : Subnet.t) =
    let subnets' = AddressMap.add (Subnet.get_address subnet) subnet world.subnets in
    { world with subnets = subnets'}

  let add_nsg (world : World.t) (nsg : Nsg.t) =
    let nsgs' = AddressMap.add (Nsg.get_address nsg) nsg world.nsgs in
    { world with nsgs = nsgs'}

  let add_nic (world : World.t) (nic : Nic.t) =
    let nics' = AddressMap.add (Nic.get_address nic) nic world.nics in
    { world with nics = nics' }

  let add_pip (world : World.t) (pip : Pip.t) =
    let pips' = AddressMap.add (Pip.get_address pip) pip world.pips in
    { world with pips = pips'}

  let add_route_table (world : World.t) (rt : Route_table.t) =
  let route_tables' = AddressMap.add (Route_table.get_address rt) rt world.route_tables in
  { world with route_tables = route_tables' }
  
  let parse_resource_groups world rgs =
    let parse_rg world rg_json =
      match rg_of_json rg_json with
      | Ok rg -> add_rg world rg
      | Error e -> Logs.err (fun m -> m "%s" e); raise (Parse_error e)
    in
    List.fold_left parse_rg world rgs

  let parse_vnets world vnets =
    let parse_vnet world vnet_json =
      match vnet_of_json world vnet_json with
      | Ok (vnet, subnets) ->
        (match partition_results subnets with
        | Error errors -> List.iter (fun e -> Logs.warn (fun m -> m "%s" e)) errors
        | Ok _ -> ());
        add_vnet world vnet
      | Error e -> Logs.err (fun m -> m "%s" e); raise (Parse_error e)
    in
    List.fold_left parse_vnet world vnets

  let parse_subnets world subnets =
    let parse_subnet world subnet_json =
      match subnet_of_json world subnet_json with
      | Ok subnet -> add_subnet world subnet
      | Error e -> Logs.err (fun m -> m "%s" e); raise (Parse_error e)
    in
    List.fold_left parse_subnet world subnets

  let parse_nsgs world nsgs =
    let parse_nsg world nsg_json =
      match nsg_of_json world nsg_json with
      | Ok nsg -> add_nsg world nsg
      | Error e -> Logs.warn (fun m -> m "%s" e); world
    in
    List.fold_left parse_nsg world nsgs

  let parse_nics world nics =
    let parse_nic world nic_json =
      match nic_of_json world nic_json with
      | Ok nic -> add_nic world nic
      | Error e -> Logs.err (fun m -> m "%s" e); raise (Parse_error e)
    in
    List.fold_left parse_nic world nics

  let parse_pips world pips =
    let parse_pip world pip_json =
      match pip_of_json world pip_json with
      | Ok pip -> add_pip world pip
      | Error e -> Logs.warn (fun m -> m "%s" e); world
    in
    List.fold_left parse_pip world pips

  let parse_route_tables world route_tables =
    let parse_route_table world rt_json =
      match route_table_of_json world rt_json with
      | Ok route_table -> add_route_table world route_table
      | Error e -> Logs.warn (fun m -> m "%s" e); world
    in
    List.fold_left parse_route_table world route_tables
    
  let parse_resource json_resource (world : World.t) err =
    let resource_type : string option = Safe.Util.member "type" json_resource |> parse_json_string_opt in
    match resource_type with
    | Some "azurerm_resource_group" -> 
      (match rg_of_json json_resource with
      | Ok rg -> (add_rg world rg, err)
      | Error e -> (world, e::err))
    | None -> (world, err)


  let raw_parse_resource json_resource (world : raw_world) =
    let resource_type : string option = Safe.Util.member "type" json_resource |> parse_json_string_opt in
    match resource_type with
    | Some "azurerm_resource_group" -> begin
      match Safe.Util.member "name" json_resource |> parse_json_string_opt with
      | Some _ -> { world with rgs = json_resource :: world.rgs }
      | None ->
        Logs.warn (fun m -> m "Malformed resource_group: cannot parse name");
        world
    end
    | Some "azurerm_virtual_network" -> begin
      match Safe.Util.member "name" json_resource |> parse_json_string_opt with
      | Some _ -> { world with vnets = json_resource :: world.vnets }
      | None ->
        Logs.warn (fun m -> m "Malformed virtual_network: cannot parse name");
        world
    end
    | Some "azurerm_subnet" -> begin
      match Safe.Util.member "name" json_resource |> parse_json_string_opt with
      | Some _ -> { world with subnets = json_resource :: world.subnets }
      | None ->
        Logs.warn (fun m -> m "Malformed subnet: cannot parse name");
        world
    end
    | Some "azurerm_network_security_group" -> begin
      match Safe.Util.member "name" json_resource |> parse_json_string_opt with
      | Some _ -> { world with nsgs = json_resource :: world.nsgs }
      | None ->
        Logs.warn (fun m -> m "Malformed network_security_group: cannot parse name");
        world
    end
    | Some "azurerm_network_interface" -> begin
      match Safe.Util.member "name" json_resource |> parse_json_string_opt with
      | Some _ -> { world with nics = json_resource :: world.nics }
      | None ->
        Logs.warn (fun m -> m "Malformed network_interface: cannot parse name");
        world
    end
    | Some "azurerm_public_ip" -> begin
      match Safe.Util.member "name" json_resource |> parse_json_string_opt with
      | Some _ -> { world with pips = json_resource :: world.pips }
      | None ->
        Logs.warn (fun m -> m "Malformed public_ip: cannot parse name");
        world
    end
    | Some "azurerm_route_table" -> begin
      match Safe.Util.member "name" json_resource |> parse_json_string_opt with
      | Some _ -> { world with route_tables = json_resource :: world.route_tables }
      | None ->
        Logs.warn (fun m -> m "Malformed route_table: cannot parse name");
        world
    end
    | Some "azurerm_virtual_network_peering" -> begin
      match Safe.Util.member "name" json_resource |> parse_json_string_opt with
      | Some _ -> { world with vnet_peerings = json_resource :: world.vnet_peerings }
      | None ->
        Logs.warn (fun m -> m "Malformed virtual_network_peering: cannot parse name");
        world
    end
    | Some "azurerm_subnet_route_table_association" ->
      { world with route_table_associations = json_resource :: world.route_table_associations }
    | Some "azurerm_subnet_network_security_group_association" ->
      { world with nsg_associations = json_resource :: world.nsg_associations }
    | Some "azurerm_network_interface_security_group_association" ->
      { world with nic_nsg_associations = json_resource :: world.nic_nsg_associations }
    | Some "azurerm_application_security_group" -> begin
      match Safe.Util.member "name" json_resource |> parse_json_string_opt with
      | Some _ -> { world with asgs = json_resource :: world.asgs }
      | None ->
        Logs.warn (fun m -> m "Malformed application_security_group: cannot parse name");
        world
    end
    | Some "azurerm_network_interface_application_security_group_association" ->
      { world with nic_asg_associations = json_resource :: world.nic_asg_associations }
    | Some t ->
      Logs.debug (fun m -> m "Skipping unknown resource type: %s" t);
      world
    | None ->
      Logs.warn (fun m -> m "Resource with no type field");
      world

  
  let raw_parse_resources json =
    match json with
    | Some arr ->
      List.fold_left (fun world r -> raw_parse_resource r world) raw_world_empty arr
    | None ->
      Logs.warn (fun m -> m "Could not parse resource array");
      raw_world_empty


  let is_resolvable json =
    let is_id_field address = 
      let address_list = String.split_on_char '.' address in
      match List.rev address_list with
      | "id"::t -> true
      | _ -> false
    in
    let resources = Safe.Util.member "references" json in
    match resources with
    | `List l -> begin 
      match List.filter is_id_field (Safe.Util.filter_string l) with 
      | h::t -> true
      | [] -> false
    end
    | _ -> false
  

  let get_configuration_resource address json_list =
    let rec aux address ell =
    match ell with
    | h::t -> 
      if Safe.Util.member "address" h |> Safe.Util.to_string = address
      then Some h 
      else aux address t
    | [] -> None
    in
    aux address json_list

  let resolve_ip_config_dependencies ipconfig (world : World.t) ip_config_json =
    let resolved_subnet =
      let subnet_references =
        match Safe.Util.member "subnet_id" ip_config_json with
        | `Null -> []
        | json -> Safe.Util.member "references" json |>
                  Safe.Util.to_list |>
                  Safe.Util.filter_string
      in
      match subnet_references with
      | [_id; address] -> AddressMap.find_opt address world.subnets
      | _ -> None
    in
    let resolved_pip =
      let pip_references = 
      match Safe.Util.member "public_ip_address_id" ip_config_json with
      | `Null -> []
      | json -> Safe.Util.member "references" json |> 
                Safe.Util.to_list |>
                Safe.Util.filter_string
      in 
      match pip_references with
      | [id; address] -> AddressMap.find_opt address world.pips
      | _ -> None
    in
    match resolved_subnet with
    | Some subnet -> Ok (Nic.IpConfiguration.resolve ipconfig ~subnet:subnet ~pip:resolved_pip)
    | None -> Error ("Could not resolve subnet for NIC " ^ (Nic.IpConfiguration.get_name ipconfig))


  let find_ip_config_json ipconfig json =
    let is_name json name = 
      match Safe.Util.member "name" json |> Safe.Util.member "constant_value" with
      | `String s -> s = name
      | _ -> false
    in
    let rec aux json_list name = 
      match json_list with
      | h::t -> if is_name h name then Some h else aux t name
      | [] -> None
    in
    let name = Nic.IpConfiguration.get_name ipconfig in
    aux json name

  let resolve_ip_configurations ipconfigs world json = 
    let (let*) = Result.bind in
    let rec aux ipconfigs acc =
      match ipconfigs with
      | h::t -> 
        let* ipconfig_json = find_ip_config_json h json |> Option.to_result ~none:"Missing IPconfig" in
        let* resolved_ipconfig = resolve_ip_config_dependencies h world ipconfig_json in
        aux t (resolved_ipconfig::acc)
      | [] -> Ok acc
    in
    aux ipconfigs []
  
  let resolve_nic_dependencies nics world config_json =
    let resolve_nic_dependency nic =
      let (let*) = Result.bind in
      let* resource = get_configuration_resource (Nic.get_address nic) config_json
        |> Option.to_result ~none:("Could not resolve ids for nic " ^ (Nic.get_name nic)) in
      let expressions = Safe.Util.member "expressions" resource in
      let ip_config = Safe.Util.member "ip_configuration" expressions in
      match ip_config with
      | `List l -> begin
        match resolve_ip_configurations (Nic.get_ipconfigs nic) world l with
        | Ok l -> Ok (Nic.resolve_ipconfigs nic l)
        | Error e -> Error e
      end
      | _ -> Error "Malformed NIC in configuration"
    in
    let nics' =
      AddressMap.fold (fun addr nic ok_map ->
        match resolve_nic_dependency nic with
        | Ok nic' -> AddressMap.add addr nic' ok_map
        | Error e -> Logs.err (fun m -> m "%s" e); raise (Parse_error e))
        nics AddressMap.empty
    in
    { world with nics = nics' }
  
  let add_route_table_association assoc (world : World.t) =
    let associations' = AddressMap.add (Association.BinaryAssociation.get_address assoc) assoc world.route_table_associations in
    { world with route_table_associations = associations'}

  let add_nsg_association assoc (world : World.t) =
    let associations' = AddressMap.add (Association.BinaryAssociation.get_address assoc) assoc world.nsg_associations in
    { world with nsg_associations = associations' }

  let add_nic_nsg_association assoc (world : World.t) =
    let associations' = AddressMap.add (Association.BinaryAssociation.get_address assoc) assoc world.nic_nsg_associations in
    { world with nic_nsg_associations = associations' }

  let resolve_association  ~first_id_type:first_id_type ~address:address ~second_id_type:second_id_type ~json:config_json = 
    let (let*) = Result.bind in
    let* resource = get_configuration_resource address config_json 
      |> Option.to_result ~none:("Could not resolve ids for route table association " ^ address) in
    let expressions = Safe.Util.member "expressions" resource in
    let* first_resolved = begin
      let first_references = Safe.Util.member first_id_type expressions |>
        Safe.Util.member "references" |> 
        Safe.Util.to_list |>
        Safe.Util.filter_string in
      match first_references with
      | [id; address] -> Some address
      | _ -> None
    end
      |> Option.to_result ~none:("Could not resolve " ^ first_id_type ^ " of association " ^ address)
    in
    let* second_resolved = begin
      let second_references = Safe.Util.member second_id_type expressions |>
        Safe.Util.member "references" |> 
        Safe.Util.to_list |>
        Safe.Util.filter_string in
      match second_references with
      | [id; address] -> Some address
      | _ -> None
    end
      |> Option.to_result ~none:("Could not resolve " ^ second_id_type ^ " of association " ^ address)
    in
    Ok (first_resolved, second_resolved)
    
  let resolve_route_table_associations (world : World.t) config_json rt_associations =
    let (let*) = Result.bind in
    let resolve_route_table_association rt_association_json =
      let values = Safe.Util.member "values" rt_association_json in
      let (let*) = Result.bind in
      let* address = Safe.Util.member "address" rt_association_json
        |> generate_parse_string_result_required "address" "" "route_table_association" in
      let* first_address, second_address =
        resolve_association
          ~address:address
          ~first_id_type:"route_table_id"
          ~second_id_type:"subnet_id"
          ~json:config_json
      in
      let* route_table = AddressMap.find_opt first_address world.route_tables
        |> Option.to_result ~none:("Could not find route table " ^ first_address ^ " required by association " ^ address) in
      let* subnet = AddressMap.find_opt second_address world.subnets
        |> Option.to_result ~none:("Could not find subnet " ^ first_address ^ " required by association " ^ address) in
      Ok (Association.BinaryAssociation.make route_table subnet address)
    in
    List.fold_left (fun world assoc_json ->
      match resolve_route_table_association assoc_json with
      | Ok rt_assoc -> add_route_table_association rt_assoc world
      | Error e -> Logs.warn (fun m -> m "%s" e); world)
    world rt_associations

  let resolve_nsg_associations (world : World.t) config_json nsg_assocs =
    let (let*) = Result.bind in
    let resolve_nsg_association assoc_json =
      let (let*) = Result.bind in
      let* address = Safe.Util.member "address" assoc_json
        |> generate_parse_string_result_required "address" "" "nsg_association" in
      let* first_address, second_address =
        resolve_association
          ~address:address
          ~first_id_type:"network_security_group_id"
          ~second_id_type:"subnet_id"
          ~json:config_json
      in
      let* nsg = AddressMap.find_opt first_address world.nsgs
        |> Option.to_result ~none:("Could not find NSG " ^ first_address ^ " required by association " ^ address) in
      let* subnet = AddressMap.find_opt second_address world.subnets
        |> Option.to_result ~none:("Could not find subnet " ^ second_address ^ " required by association " ^ address) in
      Ok (Association.BinaryAssociation.make nsg subnet address)
    in
    List.fold_left (fun world assoc_json ->
      match resolve_nsg_association assoc_json with
      | Ok nsg_assoc -> add_nsg_association nsg_assoc world
      | Error e -> Logs.warn (fun m -> m "%s" e); world)
    world nsg_assocs

  let resolve_nic_nsg_associations (world : World.t) config_json nic_nsg_assocs =
    let (let*) = Result.bind in
    let resolve_nic_nsg_association assoc_json =
      let (let*) = Result.bind in
      let* address = Safe.Util.member "address" assoc_json
        |> generate_parse_string_result_required "address" "" "nic_nsg_association" in
      let* first_address, second_address =
        resolve_association
          ~address:address
          ~first_id_type:"network_security_group_id"
          ~second_id_type:"network_interface_id"
          ~json:config_json
      in
      let* nsg = AddressMap.find_opt first_address world.nsgs
        |> Option.to_result ~none:("Could not find NSG " ^ first_address ^ " required by association " ^ address) in
      let* nic = AddressMap.find_opt second_address world.nics
        |> Option.to_result ~none:("Could not find NIC " ^ second_address ^ " required by association " ^ address) in
      Ok (Association.BinaryAssociation.make nsg nic address)
    in
    List.fold_left (fun world assoc_json ->
      match resolve_nic_nsg_association assoc_json with
      | Ok nic_nsg_assoc -> add_nic_nsg_association nic_nsg_assoc world
      | Error e -> Logs.warn (fun m -> m "%s" e); world)
    world nic_nsg_assocs

  let parse_bool_opt json =
    match json with
    | `Bool b -> Some b
    | _ -> None

  let parse_string_list_opt json =
    match json with
    | `List l -> Some (List.filter_map Safe.Util.to_string_option l)
    | _ -> None

  let vnet_peering_of_json world json =
    let values = Safe.Util.member "values" json in
    let (let*) = Result.bind in
    let* name = Safe.Util.member "name" values
      |> generate_parse_string_result_required "name" "" "vnet_peering"
    in
    let* address = Safe.Util.member "address" json
      |> generate_parse_string_result_required "address" name "vnet_peering"
    in
    let* rg_name = Safe.Util.member "resource_group_name" values
      |> generate_parse_string_result_required "resource_group_name" name "vnet_peering"
    in
    let* rg = World.get_resource_group world "DEFAULT" rg_name
      |> Option.to_result ~none:("Could not find resource_group " ^ rg_name ^ " required by vnet peering " ^ name)
    in
    let* vnet_name = Safe.Util.member "virtual_network_name" values
      |> generate_parse_string_result_required "virtual_network_name" name "vnet_peering"
    in
    let local_vnet =
      AddressMap.fold (fun _ v acc ->
        if Vnet.get_name v = vnet_name && Rg.get_name (Vnet.get_rg v) = rg_name
        then Some v else acc)
        world.vnets None
    in
    let allow_virtual_network_access =
      parse_bool_opt (Safe.Util.member "allow_virtual_network_access" values)
    in
    let allow_forwarded_traffic =
      parse_bool_opt (Safe.Util.member "allow_forwarded_traffic" values)
    in
    let allow_gateway_transit =
      parse_bool_opt (Safe.Util.member "allow_gateway_transit" values)
    in
    let use_remote_gateways =
      parse_bool_opt (Safe.Util.member "use_remote_gateways" values)
    in
    let local_subnet_names =
      parse_string_list_opt (Safe.Util.member "local_subnet_names" values)
    in
    let remote_subnet_names =
      parse_string_list_opt (Safe.Util.member "remote_subnet_names" values)
    in
    let peer_complete_virtual_networks_enabled =
      parse_bool_opt (Safe.Util.member "peer_complete_virtual_networks_enabled" values)
    in
    Ok (Vnet_peering.make
      ~name:name
      ~subscription:"DEFAULT"
      ~address:address
      ~resource_group:rg
      ~local_vnet:(match local_vnet with Some v -> Resolved v | None -> Unresolved)
      ~remote_vnet:Unresolved
      ~allow_virtual_network_access:allow_virtual_network_access
      ~allow_forwarded_traffic:allow_forwarded_traffic
      ~allow_gateway_transit:allow_gateway_transit
      ~use_remote_gateways:use_remote_gateways
      ~local_subnet_names:local_subnet_names
      ~remote_subnet_names:remote_subnet_names
      ~peer_complete_virtual_networks_enabled:peer_complete_virtual_networks_enabled)

  let asg_of_json world json =
    let values = Safe.Util.member "values" json in
    let (let*) = Result.bind in
    let* name = Safe.Util.member "name" values
      |> generate_parse_string_result_required "name" "" "asg"
    in
    let* address = Safe.Util.member "address" json
      |> generate_parse_string_result_required "address" name "asg"
    in
    let* rg_name = Safe.Util.member "resource_group_name" values
      |> generate_parse_string_result_required "resource_group_name" name "asg"
    in
    let* rg = World.get_resource_group world "DEFAULT" rg_name
      |> Option.to_result ~none:("Could not find resource_group " ^ rg_name ^ " required by asg " ^ name)
    in
    let* location = match Safe.Util.member "location" values with
    | `String s -> loc_of_string_opt s |> generate_loc_parse_result name "asg"
    | _ -> Error ("Cannot parse field location in resource " ^ name ^ " of type asg")
    in
    let tags = Safe.Util.member "tags" values
      |> parse_tags_lenient
      |> fst
    in
    Ok (Asg.make
      ~name:name
      ~subscription:"DEFAULT"
      ~address:address
      ~location:location
      ~resource_group:rg
      ~tags:tags)

  let add_vnet_peering (world : World.t) (peering : Vnet_peering.t) =
    let vnet_peerings' = AddressMap.add (Vnet_peering.get_address peering) peering world.vnet_peerings in
    { world with vnet_peerings = vnet_peerings' }

  let parse_vnet_peerings world peerings =
    let parse_vnet_peering world peering_json =
      match vnet_peering_of_json world peering_json with
      | Ok peering -> add_vnet_peering world peering
      | Error e -> Logs.warn (fun m -> m "%s" e); world
    in
    List.fold_left parse_vnet_peering world peerings

  let add_asg (world : World.t) (asg : Asg.t) =
    let asgs' = AddressMap.add (Asg.get_address asg) asg world.asgs in
    { world with asgs = asgs' }

  let parse_asgs world asgs =
    let parse_asg world asg_json =
      match asg_of_json world asg_json with
      | Ok asg -> add_asg world asg
      | Error e -> Logs.warn (fun m -> m "%s" e); world
    in
    List.fold_left parse_asg world asgs

  let add_nic_asg_association assoc (world : World.t) =
    let associations' = AddressMap.add (Association.BinaryAssociation.get_address assoc) assoc world.nic_asg_associations in
    { world with nic_asg_associations = associations' }

  let resolve_nic_asg_associations (world : World.t) config_json nic_asg_assocs =
    let resolve_nic_asg_association assoc_json =
      let (let*) = Result.bind in
      let* address = Safe.Util.member "address" assoc_json
        |> generate_parse_string_result_required "address" "" "nic_asg_association" in
      let* first_address, second_address =
        resolve_association
          ~address:address
          ~first_id_type:"application_security_group_id"
          ~second_id_type:"network_interface_id"
          ~json:config_json
      in
      let* asg = AddressMap.find_opt first_address world.asgs
        |> Option.to_result ~none:("Could not find ASG " ^ first_address ^ " required by association " ^ address) in
      let* nic = AddressMap.find_opt second_address world.nics
        |> Option.to_result ~none:("Could not find NIC " ^ second_address ^ " required by association " ^ address) in
      Ok (Association.BinaryAssociation.make asg nic address)
    in
    List.fold_left (fun world assoc_json ->
      match resolve_nic_asg_association assoc_json with
      | Ok nic_asg_assoc -> add_nic_asg_association nic_asg_assoc world
      | Error e -> Logs.warn (fun m -> m "%s" e); world)
    world nic_asg_assocs

  let resolve_vnet_peering_remote_ref peering config_json (world : World.t) =
    let (let*) = Result.bind in
    let* resource = get_configuration_resource (Vnet_peering.get_address peering) config_json
      |> Option.to_result ~none:("Could not resolve ids for vnet peering " ^ (Vnet_peering.get_name peering))
    in
    let expressions = Safe.Util.member "expressions" resource in
    let remote_refs =
      Safe.Util.member "remote_virtual_network_id" expressions |>
      Safe.Util.member "references" |>
      Safe.Util.to_list |>
      Safe.Util.filter_string
    in
    let* remote_address = match remote_refs with
      | [_id; address] -> Ok address
      | _ -> Error ("Could not resolve remote_virtual_network_id of peering " ^ (Vnet_peering.get_name peering))
    in
    let* remote_vnet = AddressMap.find_opt remote_address world.vnets
      |> Option.to_result ~none:("Could not find remote vnet " ^ remote_address ^ " required by peering " ^ (Vnet_peering.get_name peering))
    in
    Ok (Vnet_peering.resolve_remote_vnet remote_vnet peering)

  let resolve_vnet_peering_dependencies (world : World.t) config_json =
    let peerings' =
      AddressMap.fold (fun addr peering ok_map ->
        match resolve_vnet_peering_remote_ref peering config_json world with
        | Ok peering' -> AddressMap.add addr peering' ok_map
        | Error e -> Logs.warn (fun m -> m "%s" e); ok_map)
        world.vnet_peerings AddressMap.empty
    in
    { world with vnet_peerings = peerings' }

  let get_route_nics (json : Safe.t list) nics =
    List.fold_left (
      fun set json -> match json with
      | `String s when AddressMap.mem s nics ->  AddressSet.add s set
      | _ -> set
    ) AddressSet.empty json 
    |> AddressSet.elements

  let resolve_routes rt niclist = 
    let resolve_route route =
      if not @@ Route_table.Route.next_hop_is_unresolved route
      then route
      else match niclist with
      | [] -> Route_table.Route.resolve_next_hop route
      | [address] -> Route_table.Route.resolve_next_hop ~address route
      | list -> Route_table.Route.resolve_next_hop ~list route
    in
    let routes = List.map resolve_route (Route_table.get_routes rt) in
    Route_table.resolve_routes routes rt

  let resolve_route_table_dynamic_ips (world : World.t) config_json =
    let rts = world.route_tables in
    let resolve_route_table_dynamic_ip rt =
      let (let*) = Result.bind in
      let* resource = get_configuration_resource (Route_table.get_address rt) config_json
        |> Option.to_result ~none:("Could not resolve ids for route table " ^ (Route_table.get_name rt)) in
      let expressions = Safe.Util.member "expressions" resource in
      let route = Safe.Util.member "route" expressions in
      match Safe.Util.member "references" route with
      | `List l -> Ok (resolve_routes rt (get_route_nics l world.nics))
      | `Null -> Ok rt
      | _ -> Error "Malformed route table in configuration"
    in
    let rts' =
      AddressMap.fold (fun addr rt ok_map ->
        match resolve_route_table_dynamic_ip rt with
        | Ok rt' -> AddressMap.add addr rt' ok_map
        | Error e -> Logs.warn (fun m -> m "%s" e); ok_map)
        rts AddressMap.empty
    in
    { world with route_tables = rts' }
      

  let build_nic_ip_map (world : World.t) =
    let add_nic_to_ip_map address nic ip_map =
      let add_ipconfig_to_ip_map map ipconfig =
        match Nic.IpConfiguration.get_private_ip ipconfig with
        | Some ip -> IPMap.add ip nic map 
        | None -> ip_map
      in
      List.fold_left add_ipconfig_to_ip_map ip_map (Nic.get_ipconfigs nic)
    in
    AddressMap.fold add_nic_to_ip_map world.nics IPMap.empty

  let index_nic_ips (world : World.t) (ipworld : Ipworld.t) =
    { ipworld with nics = build_nic_ip_map world}

  let build_subnet_cidr_map (world : World.t) =
    let add_subnet_to_cidr_map _address subnet cidr_map =
      List.fold_left (fun map cidr -> CIDRMap.add cidr subnet map)
        cidr_map (Subnet.get_cidrs subnet)
    in
    AddressMap.fold add_subnet_to_cidr_map world.subnets CIDRMap.empty

  let build_route_cidr_map (world : World.t) =
    let add_routes_to_cidr_map _address route_table cidr_map =
      List.fold_left (fun map route -> CIDRMap.add (Route_table.Route.get_prefix route) route map)
        cidr_map (Route_table.get_routes route_table)
    in
    AddressMap.fold add_routes_to_cidr_map world.route_tables CIDRMap.empty

  let build_nic_cidr_map (world : World.t) =
    let add_nic_to_cidr_map _address nic cidr_map =
      let add_ipconfig_to_cidr_map map ipconfig =
        match Nic.IpConfiguration.get_private_cidr ipconfig with
        | Some cidrs -> List.fold_left (fun m cidr -> CIDRMap.add cidr nic m) map cidrs
        | None -> cidr_map
      in
      List.fold_left add_ipconfig_to_cidr_map cidr_map (Nic.get_ipconfigs nic)
    in
    AddressMap.fold add_nic_to_cidr_map world.nics CIDRMap.empty

  let index_subnet_cidrs (world : World.t) (cidrworld : Cidrworld.t) =
    { cidrworld with subnets = build_subnet_cidr_map world }

  let index_route_cidrs (world : World.t) (cidrworld : Cidrworld.t) =
    { cidrworld with routes = build_route_cidr_map world }

  let index_nic_cidrs (world : World.t) (cidrworld : Cidrworld.t) =
    { cidrworld with nics = build_nic_cidr_map world }


  let get_resources file =
    let json = json_resources file in
    let config_json = json_config file in
    let raw_world = raw_parse_resources json in
    let world = parse_resource_groups World.empty raw_world.rgs in
    let world = parse_vnets world raw_world.vnets in
    let world = parse_subnets world raw_world.subnets in
    let world = parse_nsgs world raw_world.nsgs in
    let world = parse_nics world raw_world.nics in
    let world = parse_pips world raw_world.pips in
    let world = parse_route_tables world raw_world.route_tables in
    let world = parse_vnet_peerings world raw_world.vnet_peerings in
    let world = parse_asgs world raw_world.asgs in
    let world = resolve_nic_dependencies world.nics world (Option.get config_json) in
    let world = resolve_route_table_dynamic_ips world (Option.get config_json) in
    let world = resolve_route_table_associations world (Option.get config_json) raw_world.route_table_associations in
    let world = resolve_nsg_associations world (Option.get config_json) raw_world.nsg_associations in
    let world = resolve_nic_nsg_associations world (Option.get config_json) raw_world.nic_nsg_associations in
    let world = resolve_nic_asg_associations world (Option.get config_json) raw_world.nic_asg_associations in
    resolve_vnet_peering_dependencies world (Option.get config_json)

  let get_ip_index world =
    let ipworld = index_nic_ips world (Ipworld.empty) in
    ipworld

  let get_cidr_index world =
    let cidrworld = index_subnet_cidrs world Cidrworld.empty in
    let cidrworld = index_route_cidrs world cidrworld in
    let cidrworld = index_nic_cidrs world cidrworld in
    cidrworld




end