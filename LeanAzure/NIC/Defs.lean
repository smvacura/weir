import LeanNetworking.CIDR.Defs
import LeanAzure.NSG.Defs

inductive PrivateAllocation where
| Static
| Dynamic (ip: Option IP)


--TODO: replace publicIP, subnet with Azure resources
structure IPConfiguration where
  -- required attributes
  name : String
  subnet : CIDR
  private_allocation : PrivateAllocation

  -- optional attributes
  public_ip : Option IP
  primary : Bool



structure AzureNIC where
  -- required attributes
  name : String
  location : String
  rg : String
  ip_configs : List IPConfiguration
  nonempty_configs : ip_configs ≠ []

  -- optional attributes
  dns_servers : List IP
  edges_zone : Unit
  ip_forwarding_enabled : Bool
  nsgs : List AzureNSG


def isStatic (n : IPConfiguration) : Prop := n.private_allocation = PrivateAllocation.Static
def isDynamic (n : IPConfiguration) : Prop := n.private_allocation ≠  PrivateAllocation.Static


def reachableIPs (n : AzureNIC) : Set IP :=
  List.foldl (λa (b : IPConfiguration) => a ∪ (cidr.toSet b.subnet)) {} n.ip_configs
