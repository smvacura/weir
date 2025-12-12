type azure_location

val loc_of_string_opt : string -> azure_location option

type azure_address_prefix

type tag

val make_tag : string -> string -> tag

type azure_resource_group

val make_rg : string -> azure_location -> string -> tag list -> azure_resource_group
