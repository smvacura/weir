type azure_location

val loc_of_string_opt : string -> azure_location option

type azure_address_prefix

type tag

val make_tag : string -> string -> tag
