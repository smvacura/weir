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

val loc_of_string_opt : string -> azure_location option

type azure_address_prefix

type tag

val make_tag : string -> string -> tag
