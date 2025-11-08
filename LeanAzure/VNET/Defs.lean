import LeanAzure.Subnet.Defs
import LeanNetworking.CIDR.Defs


structure AzureVNet where
  name : String
  location : String
  address_space : CIDR

  subnets : List AzureSubnet
