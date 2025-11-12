import LeanAzure.NIC.Defs
import LeanAzure.NSG.Defs
import LeanAzure.Defs

def allRules (nic : AzureNIC) :=
  List.foldl (· ++ [·.rules]) ([] : List AzureSecurityRule) nic.nsgs
