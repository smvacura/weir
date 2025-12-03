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

type azure_address_prefix =
  | ActionGroup
  | ApiManagement
  | ApplicationInsightsAvailability
  | AppConfiguration
  | AppService
  | AzureActiveDirectory
  | AzureBackup
  | AzureCloud
  | AzureContainerRegistry
  | AzureCosmosDB
  | AzureLoadBalancer
  | Storage
  | Sql
  | Internet
  | VirtualNetwork
  | PrefixList 

type tag = {
  name : string;
  value : string
}


type azure_resource_group = {
  name : string;
  location : azure_location;
  managed_by : string;
  tags : tag list
}