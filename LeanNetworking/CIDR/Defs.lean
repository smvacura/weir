import LeanNetworking.Subnet.Defs
import LeanNetworking.Subnet.Theorems



structure CIDR where
  (base : IP)
  (mask : SubnetMask)
  (aligned : applySubnetMask base mask = base)


def cidr.toSet (c : CIDR) :=
  subnet c.base c.mask


instance : LE CIDR where
  le c₁ c₂ := cidr.toSet c₁ ⊆ cidr.toSet c₂


instance : LT CIDR where
  lt c₁ c₂ := cidr.toSet c₁ ⊆  cidr.toSet c₂ ∧ c₁ ≠ c₂


lemma aligned_base {c : CIDR} : applySubnetMask c.base c.mask = c.base := by
  exact c.aligned

variable (a b : CIDR)


theorem cidr.toSet_cancel {c₁ c₂ : CIDR} : cidr.toSet c₁ = cidr.toSet c₂ ↔ c₁ = c₂ := by
  apply Iff.intro

  -- (→) toSet c₁ = toSet c₂ → c₁ = c₁
  intro h
  sorry

  -- (←) c₁ = c₂ → toSet c₁ = toSet c₂
  intro h
  exact congrArg cidr.toSet h


theorem cidr.le_refl {c : CIDR} : c ≤ c := by
  simp only [instLECIDR]
  exact subset_refl (toSet c)


theorem cidr.le_antisymm {c₁ c₂ : CIDR} : c₁ ≤ c₂ → c₂ ≤ c₁ → c₁ = c₂ := by
  simp only [instLECIDR]
  intros h1 h2
  have heq := subset_antisymm h1 h2
  exact cidr.toSet_cancel.mp heq
