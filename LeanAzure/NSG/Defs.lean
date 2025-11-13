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

structure AzureSecurityRule where
  name : String
  rule_priority : Nat
  direction : Direction
  access : Access
  protocol : Protocol
  source_port_range : PortList
  destination_port_range : PortList
  source_address_prefix : AzureAddressPrefix
  destination_address_prefix : AzureAddressPrefix


instance : LT AzureSecurityRule where
  lt r₁ r₂ := r₁.rule_priority > r₂.rule_priority

instance : Max AzureSecurityRule where
  max r₁ r₂ := if r₁ < r₂ then r₂ else r₁


def unique_priority (rules : Finset AzureSecurityRule) : Prop :=
  ∀ {r r'}, r ∈ rules → r' ∈ rules → r ≠ r' → r.rule_priority ≠ r'.rule_priority

structure AzureNSG where
  name : String
  location : AzureLocation
  resource_group : AzureResourceGroup
  rules : Finset AzureSecurityRule
  rule_priority_uniqueness: unique_priority rules
  tags : List Tag


def portInPorts (p : Nat) (P : PortList) :=
  match P with
  | .All => True
  | .Specific ℓ => p ∈ ℓ


def trafficMatchesRule (ip : IP) (r : AzureSecurityRule) :=
  ipInAddressPrefix ip r.destination_address_prefix


def isMinimalMatchingRule (ips ipd : IP) (ports portd : Nat) (rule : AzureSecurityRule) (nsg : AzureNSG) :=
  ipInAddressPrefix ips rule.source_address_prefix
  ∧ ipInAddressPrefix ipd rule.destination_address_prefix
  ∧ portInPorts ports rule.source_port_range
  ∧ portInPorts portd rule.destination_port_range
  ∧ ∀rule' ∈ nsg.rules,
    ipInAddressPrefix ips rule'.source_address_prefix
    → ipInAddressPrefix ipd rule'.destination_address_prefix
    → portInPorts ports rule'.source_port_range
    → portInPorts portd rule'.destination_port_range
    → rule.direction = rule'.direction
    → rule' ≠ rule
    → rule' < rule


def addressInboundAllowed (ips ipd : IP) (ports portd : Nat) (nsg : AzureNSG) : Prop :=
  ∃rule ∈ nsg.rules, isMinimalMatchingRule ips ipd ports portd rule nsg
    ∧ rule.direction = .Inbound
    ∧ rule.access = .Allow

def inboundAllowedAddresses (ipd : IP) (portd : Nat) (nsg : AzureNSG) : Set FullAddress :=
  fun (ips, ports) => addressInboundAllowed ips ipd ports portd nsg
