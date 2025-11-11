import LeanNetworking.CIDR.Defs
import LeanAzure.Defs

inductive Direction where
  | Inbound
  | Outbound


inductive Access where
  | Allow
  | Deny

-- Tcp, Udp, Icmp, Esp, Ah or *
inductive Protocol where
  | TCP
  | UDP
  | ICMP
  | ESP
  | AH
  | All


inductive Port where
  | Specific (ℓ : List Nat)
  | All

structure AzureSecurityRule where
  name : String
  rule_priority : Nat
  direction : Direction
  access : Access
  protocol : Protocol
  source_port_range : Port
  destination_port_range : Port
  source_address_prefix : AzureAddressPrefix
  destination_address_prefix : AzureAddressPrefix


structure AzureNSG where
  name : String
  location : AzureLocation
  resource_group : AzureResourceGroup
  rules : AzureSecurityRule
  tags : List Tag


def portInPorts (p : Nat) (P : Port) :=
  match P with
  | .All => True
  | .Specific ℓ => p ∈ ℓ
