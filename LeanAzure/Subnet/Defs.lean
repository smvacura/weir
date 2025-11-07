import LeanNetworking.CIDR.defs


inductive Action where
| TODO

structure Delegation where
  name : String
  delegation_name : String
  actions : List Action

structure AzureSubnet where
  name : String
  resource_group : String
  VNet : String
  address_prefixes : List CIDR

  delegations : List Delegation
