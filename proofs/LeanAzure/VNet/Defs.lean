import LeanAzure.Defs
import LeanAzure.Subnet.Defs
import LeanNetworking.CIDR.Defs


structure AzureVNet where
  name : String
  location : AzureLocation
  resource_group : AzureResourceGroup

  address_space : List CIDR

  subnets : List AzureSubnet

  dns_servers : List IP

  tags : List Tag
