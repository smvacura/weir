import LeanNetworking.CIDR.Defs


inductive PortList where
  | Specific (ℓ : List Nat)
  | All
  deriving DecidableEq

inductive AzureLocation
| australia_central
| australia_central2
| australia_east
| australia_southeast
| austria_east
| belgium_central
| brazilsouth
| brazilsoutheast
| canada_central
| canada_east
| central_india
| central_us
| chile_central
| east_asia
| east_us
| east_us2
| france_central
| france_south
| germany_north
| germany_west_central
| indonesia_central
| israel_central
| italy_north
| japan_east
| japan_west
| korea_central
| korea_south
| malaysia_west
| mexico_central
| new_zealand_north
| north_central_us
| north_europe
| norway_east
| norway_west
| poland_central
| qatar_central
| south_africa_north
| south_africa_west
| south_central_us
| south_india
| southeast_asia
| spain_central
| sweden_central
| sweden_south
| switzerland_north
| switzerland_west
| uae_central
| uae_north
| uk_south
| uk_west
| west_central_us
| west_europe
| west_india
| west_us
| west_us2
| west_us3


inductive AzureAddressPrefix
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
| PrefixList (ℓ : List CIDR)
deriving DecidableEq

structure Tag where
  name : String
  value : String


structure AzureResourceGroup where
  name : String
  location : AzureLocation
  managed_by : String
  tags : List Tag


def ipInAddressPrefix (ip : IP) (pre : AzureAddressPrefix) :=
  match pre with
  | .PrefixList ℓ => ∃c ∈ ℓ, ip ∈ cidr.toSet c
  | _ => False


abbrev FullAddress : Type :=
  IP × Nat
