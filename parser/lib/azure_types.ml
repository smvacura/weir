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

let loc_of_string_opt = function
  | "australiacentral"      -> Some AustraliaCentral
  | "australiacentral2"     -> Some AustraliaCentral2
  | "australiaeast"         -> Some AustraliaEast
  | "australiasoutheast"    -> Some AustraliaSoutheast
  | "austriaeast"           -> Some AustriaEast
  | "belgiumcentral"        -> Some BelgiumCentral
  | "brazilsouth"           -> Some Brazilsouth
  | "brazilsoutheast"       -> Some Brazilsoutheast
  | "canadacentral"         -> Some CanadaCentral
  | "canadaeast"            -> Some CanadaEast
  | "centralindia"          -> Some CentralIndia
  | "centralus"             -> Some CentralUs
  | "chilecentral"          -> Some ChileCentral
  | "eastasia"              -> Some EastAsia
  | "eastus"                -> Some EastUs
  | "eastus2"               -> Some EastUs2
  | "francecentral"         -> Some FranceCentral
  | "francesouth"           -> Some FranceSouth
  | "germanynorth"          -> Some GermanyNorth
  | "germanywestcentral"    -> Some GermanyWestCentral
  | "indonesiacentral"      -> Some IndonesiaCentral
  | "israelcentral"         -> Some IsraelCentral
  | "italynorth"            -> Some ItalyNorth
  | "japaneast"             -> Some JapanEast
  | "japanwest"             -> Some JapanWest
  | "koreacentral"          -> Some KoreaCentral
  | "koreasouth"            -> Some KoreaSouth
  | "malaysiawest"          -> Some MalaysiaWest
  | "mexicocentral"         -> Some MexicoCentral
  | "newzealandnorth"       -> Some NewZealandNorth
  | "northcentralus"        -> Some NorthCentralUs
  | "northeurope"           -> Some NorthEurope
  | "norwayeast"            -> Some NorwayEast
  | "norwaywest"            -> Some NorwayWest
  | "polandcentral"         -> Some PolandCentral
  | "qatarcentral"          -> Some QatarCentral
  | "southafricanorth"      -> Some SouthAfricaNorth
  | "southafricawest"       -> Some SouthAfricaWest
  | "southcentralus"        -> Some SouthCentralUs
  | "southindia"            -> Some SouthIndia
  | "southeastasia"         -> Some SoutheastAsia
  | "spaincentral"          -> Some SpainCentral
  | "swedencentral"         -> Some SwedenCentral
  | "swedensouth"           -> Some SwedenSouth
  | "switzerlandnorth"      -> Some SwitzerlandNorth
  | "switzerlandwest"       -> Some SwitzerlandWest
  | "uaecentral"            -> Some UaeCentral
  | "uaenorth"              -> Some UaeNorth
  | "uksouth"               -> Some UkSouth
  | "ukwest"                -> Some UkWest
  | "westcentralus"         -> Some WestCentralUs
  | "westeurope"            -> Some WestEurope
  | "westindia"             -> Some WestIndia
  | "westus"                -> Some WestUs
  | "westus2"               -> Some WestUs2
  | "westus3"               -> Some WestUs3
  | _                       -> None


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
  key : string;
  value : string
}

let make_tag k v = {key = k; value = v}


type azure_resource_group = {
  name : string;
  location : azure_location;
  managed_by : string;
  tags : tag list
}

let make_rg name location managed_by tags = {
  name = name;
  location = location;
  managed_by = managed_by;
  tags = tags
}