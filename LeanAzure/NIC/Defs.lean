import LeanNetworking.CIDR.Defs

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



structure NIC where
  -- required attributes
  name : String
  location : String
  rg : String
  ip_configs : List IPConfiguration

  -- optional attributes
  dns_servers : List IP
  edges_zone : Unit
  ip_forwarding_enabled : Bool
