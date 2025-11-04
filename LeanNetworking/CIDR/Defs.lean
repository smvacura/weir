import LeanNetworking.Subnet.Defs
import LeanNetworking.Subnet.Theorems


@[ext]
structure CIDR where
  (base : IP)
  (mask : SubnetMask)
  (aligned : applySubnetMask base mask = base)


def cidr.toSet (c : CIDR) :=
  subnet c.base c.mask


def cidr.disjoint (c₁ c₂ : CIDR) :=
  cidr.toSet c₁ ∩ cidr.toSet c₂ = ∅


def cidr.isAligned (c : CIDR) (m : SubnetMask) :=
  applySubnetMask c.base m = c.base


def cidr.areAligned (c₁ c₂ : CIDR) :=
  c₁.base = c₂.base

instance : LE CIDR where
  le c₁ c₂ := cidr.toSet c₁ ⊆ cidr.toSet c₂


instance : LT CIDR where
  lt c₁ c₂ := cidr.toSet c₁ ⊆  cidr.toSet c₂ ∧ ¬ cidr.toSet c₂ ⊆ cidr.toSet c₁


lemma aligned_base {c : CIDR} : applySubnetMask c.base c.mask = c.base := by
  exact c.aligned





theorem cidr.toSet_inj {c₁ c₂ : CIDR} : cidr.toSet c₁ = cidr.toSet c₂ ↔ c₁ = c₂ := by
  apply Iff.intro

  -- (→) toSet c₁ = toSet c₂ → c₁ = c₁
  intro h
  ext i hi

  -- proving bases equal
  unfold toSet at h
  rw [subnet_eq_iff_mask_network_eq] at h
  have ⟨happly, hmask⟩ := h
  repeat rw [aligned_base] at happly

  exact congrArg (fun x => x[i]) happly

  -- proving masks equal
  unfold toSet at h
  rw [subnet_eq_iff_mask_network_eq] at h
  exact h.right

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
  exact cidr.toSet_inj.mp heq

theorem cidr.le_trans {c₁ c₂ c₃ : CIDR} : c₁ ≤ c₂ → c₂ ≤ c₃ → c₁ ≤ c₃ := by
  intro h1 h2
  simp only [instLECIDR]
  exact subset_trans h1 h2


instance : PartialOrder CIDR where
  le_refl := fun c => cidr.le_refl
  le_antisymm := fun c₁ c₂ => cidr.le_antisymm
  le_trans := fun c₁ c₂ c₃ => cidr.le_trans


def cidr.isAdjacent (c₁ c₂ : CIDR) :=
  c₁.mask = c₂.mask ∧ |intOfIP c₁.base - intOfIP c₂.base| = subnetSize c₁.mask


def cidr.sameMask (c₁ c₂ : CIDR) :=
  c₁.mask = c₂.mask


def cidr.inSupernet (c s : CIDR) := c < s



--TODO: fix signature issue
def cidr.supernetOfList (ℓ : List CIDR) (h : ℓ ≠ []) : CIDR :=
  let b₀ := (ℓ.head h).base
  let m := (ℓ.head h).mask
  let n := Nat.log2 ℓ.length
  let M := SubnetMask.mk $ m - n
  CIDR.mk (applySubnetMask b₀ M) M (by rw [mask_idempotence])


--TODO: maybe define predicates here
def cidr.isMergeable (ℓ : List CIDR) (h : ℓ ≠ []):=
  List.Pairwise cidr.disjoint ℓ
  ∧ List.Pairwise cidr.sameMask ℓ
  ∧ List.Forall (λ c => cidr.inSupernet c (cidr.supernetOfList ℓ h)) ℓ
  ∧ Nat.isPowerOfTwo ℓ.length
  ∧ ∃c ∈ ℓ, cidr.isAligned c (SubnetMask.mk $ Nat.log2 ℓ.length)
