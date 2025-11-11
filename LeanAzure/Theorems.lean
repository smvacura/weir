import LeanAzure.NIC.Defs
import LeanAzure.NSG.Defs
import LeanAzure.Defs

def allRules (nic : AzureNIC) :=
  List.foldl (· ++ [·.rules]) ([] : List AzureSecurityRule) nic.nsgs

def NICIsReachable {nic : AzureNIC} {port : Nat}: Prop :=
  ∃rule ∈ allRules nic,
  ((ipInAddressPrefix nic.ip rule.destination_address_prefix) ∧
  (portInPorts port rule.destination_port_range) ∧
  rule.direction = .Inbound ∧
  rule.access = .Allow)
