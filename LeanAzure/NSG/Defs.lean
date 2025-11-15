import LeanNetworking.CIDR.Defs
import LeanAzure.Defs
import LeanNetworking.Util

abbrev Priority := Util.BoundedNat 100 4096

namespace Priority


--TODO: simplify Aesop proof
theorem priority_bounds_correct (n : Nat) :
  100 ≤ max 100 (min n 4096) ∧ (max 100 (min n 4096)) ≤ 4096 := by

  simp_all only [le_sup_left, sup_le_iff, Nat.reduceLeDiff, inf_le_right, and_self]


def mk (n : ℕ) : Priority :=
  ⟨max 100 (min n 4096), priority_bounds_correct n⟩

def toPriority? (n : ℕ) : Option Priority :=
  if h : 100 ≤ n ∧ n ≤ 4096 then
    some ⟨n, h⟩
  else
    none

def toPriority?_injective : ∀ (a a' : ℕ) (b : Priority),
  toPriority? a = some b → toPriority? a' = some b → a = a':= by
  intros a a'

  unfold toPriority?
  intro b a_1 a_2
  simp_all only [Option.dite_none_right_eq_some, Option.some.injEq]
  obtain ⟨w, h⟩ := a_1
  obtain ⟨w_1, h_1⟩ := a_2
  obtain ⟨left, right⟩ := w
  obtain ⟨left_1, right_1⟩ := w_1
  subst h_1
  sorry

def prioritiesFrom (s : Finset ℕ) : Finset Priority :=
  Finset.filterMap toPriority? s toPriority?_injective


instance : Coe Priority Nat where
  coe p := p.val

instance : LT Priority where
  lt p₁ p₂ := (p₁ : ℕ) < (p₂ : ℕ)

instance : Min Priority where
  min p₁ p₂ := Priority.mk (Nat.min (p₁ : ℕ) (p₂ : ℕ))

noncomputable instance : DecidableEq Priority := by
  intros p q
  classical
  exact decEq p q

def allPriorities_Nat : Finset ℕ :=
  (Finset.range (4096 + 1)).filter fun n => 100 ≤ n


noncomputable def all : Finset Priority :=
  Finset.image mk allPriorities_Nat

end Priority

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
  rule_priority : Priority
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


def rulePriorityAvailable (p : Priority) (n : AzureNSG) :=
  ¬∃r ∈ n.rules, r.rule_priority ≠ p


def lowestAvailablePriority (n : AzureNSG) :=
  {p ∈ Priority.all | rulePriorityAvailable p n}

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
