open Azureir

module AzureTFParser : sig

    val get_resources : string -> World.t

    val get_ip_index : World.t -> Ipworld.t

end