open Terraform_ir

module AzureTFParser : sig

    val get_resources : string -> World.t

    val get_ip_index : World.t -> Ipworld.t

    val get_cidr_index : World.t -> Cidrworld.t

end