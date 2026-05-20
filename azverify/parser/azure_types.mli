open Network_types

type azure_location =
  | AustraliaCentral
  | AustraliaCentral2
  | AustraliaEast
  | AustraliaSoutheast
  | AustriaEast
  | BelgiumCentral
  | Brazilsouth
  | Brazilsoutheast
  | CanadaCentral
  | CanadaEast
  | CentralIndia
  | CentralUs
  | ChileCentral
  | EastAsia
  | EastUs
  | EastUs2
  | FranceCentral
  | FranceSouth
  | GermanyNorth
  | GermanyWestCentral
  | IndonesiaCentral
  | IsraelCentral
  | ItalyNorth
  | JapanEast
  | JapanWest
  | KoreaCentral
  | KoreaSouth
  | MalaysiaWest
  | MexicoCentral
  | NewZealandNorth
  | NorthCentralUs
  | NorthEurope
  | NorwayEast
  | NorwayWest
  | PolandCentral
  | QatarCentral
  | SouthAfricaNorth
  | SouthAfricaWest
  | SouthCentralUs
  | SouthIndia
  | SoutheastAsia
  | SpainCentral
  | SwedenCentral
  | SwedenSouth
  | SwitzerlandNorth
  | SwitzerlandWest
  | UaeCentral
  | UaeNorth
  | UkSouth
  | UkWest
  | WestCentralUs
  | WestEurope
  | WestIndia
  | WestUs
  | WestUs2
  | WestUs3
  [@@deriving show]

val loc_of_string_opt : string -> azure_location option

val string_of_loc : azure_location -> string

type azure_address_prefix

val show_azure_address_prefix : azure_address_prefix -> string

val pp_azure_address_prefix : Format.formatter -> azure_address_prefix -> unit

type tag

val make_tag : string -> string -> tag

val show_tag : tag -> string

val pp_tag : Format.formatter -> tag -> unit

type appliance_ref =
 | StaticAppliance of IPv4.t
 | DynamicNic of string
 | Unresolvable
 [@@deriving show]

type next_hop = 
 | Internet
 | VirtualNetwork
 | VirtualAppliance of appliance_ref
 | VirtualGateway
 | Drop
 [@@deriving show]

val next_hop_of_string_opt : string -> ?ip:IPv4.t option -> next_hop option

type route_source =
  | System
  | Bgp
  | UserDefined
  [@@deriving show]
