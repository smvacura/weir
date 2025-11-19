import LeanNetworking.Subnet.Defs
import LeanNetworking.Subnet.Theorems


/-- A CIDR block. It has a base address, a mask, and the requirement that the base address be aligned-/
@[ext] structure CIDR where
  (base : IP)
  (mask : SubnetMask)
  deriving DecidableEq


@[ext] structure AlignedCIDR extends CIDR where
  (aligned: applySubnetMask base mask = base)
  deriving DecidableEq


instance : Coe AlignedCIDR CIDR where
  coe c := CIDR.mk c.base c.mask

/-- The underlying subnet from a CIDR block-/
def cidr.toSet (c : CIDR) :=
  subnet c.base c.mask


/-- CIDR blocks are disjoint if their asociated subnets have no IPs in common-/
def cidr.disjoint (c₁ c₂ : CIDR) :=
  cidr.toSet c₁ ∩ cidr.toSet c₂ = ∅


/-- External -/
def cidr.isAligned (c : CIDR) (m : SubnetMask) :=
  applySubnetMask c.base m = c.base


def cidr.areAligned (c₁ c₂ : CIDR) :=
  c₁.base = c₂.base


/-- ≤ instance for CIDR blocks. Equivalent to subset of their subnets-/
instance : LE CIDR where
  le c₁ c₂ := cidr.toSet c₁ ⊆ cidr.toSet c₂


/-- < instance for CIDR blocks. Equivalent to strict subset of their subnets-/
instance : LT CIDR where
  lt c₁ c₂ := cidr.toSet c₁ ⊆  cidr.toSet c₂ ∧ ¬ cidr.toSet c₂ ⊆ cidr.toSet c₁


/-- ≤ instance for Aligned CIDR blocks. Equivalent to subset of their subnets-/
instance : LE AlignedCIDR where
  le c₁ c₂ := cidr.toSet c₁ ⊆ cidr.toSet c₂


/-- < instance for Aligned CIDR blocks. Equivalent to strict subset of their subnets-/
instance : LT AlignedCIDR where
  lt c₁ c₂ := cidr.toSet c₁ ⊆  cidr.toSet c₂ ∧ ¬ cidr.toSet c₂ ⊆ cidr.toSet c₁


/-- cidr.toSet is injective is both CIDR blocks are aligned-/
theorem cidr.aligned_toSet_inj
  {c₁ c₂ : AlignedCIDR}:
  cidr.toSet c₁ = cidr.toSet c₂ ↔ c₁ = c₂ := by

  apply Iff.intro

  -- (→) toSet c₁ = toSet c₂ → c₁ = c₁
  intro h
  ext i hi

  -- proving bases equal
  unfold toSet at h
  rw [subnet_eq_iff_mask_network_eq] at h
  have ⟨happly, hmask⟩ := h
  rw [c₁.aligned] at happly
  rw [c₂.aligned] at happly

  exact congrArg (fun x => x[i]) happly

  -- proving masks equal
  unfold toSet at h
  rw [subnet_eq_iff_mask_network_eq] at h
  exact h.right

  -- (←) c₁ = c₂ → toSet c₁ = toSet c₂
  intro h
  have hCIDR : (c₁ : CIDR) = (c₂ : CIDR) := congrArg AlignedCIDR.toCIDR h
  exact congrArg cidr.toSet hCIDR


theorem cidr.le_refl {c : CIDR} : c ≤ c := by
  simp only [instLECIDR]
  exact subset_refl (toSet c)


theorem cidr.le_trans {c₁ c₂ c₃ : CIDR} : c₁ ≤ c₂ → c₂ ≤ c₃ → c₁ ≤ c₃ := by
  intro h1 h2
  simp only [instLECIDR]
  exact subset_trans h1 h2


/- LE is symmetric only on Aligned CIDRS-/
theorem cidr.aligned_le_antisymm {c₁ c₂ : AlignedCIDR} : c₁ ≤ c₂ → c₂ ≤ c₁ → c₁ = c₂ := by
  simp only [instLEAlignedCIDR]
  intros h1 h2
  have heq := subset_antisymm h1 h2
  exact cidr.aligned_toSet_inj.mp heq


/-- CIDR blocks form a preorder, with subset of subnets as R-/
instance : Preorder CIDR where
  le_refl := fun c => cidr.le_refl
  le_trans := fun c₁ c₂ c₃ => cidr.le_trans


/-- CIDR blocks form a partial order, with subset of subnets as R-/
instance : PartialOrder AlignedCIDR where
  le_refl := fun c => cidr.le_refl
  le_trans := fun c₁ c₂ c₃ => cidr.le_trans
  le_antisymm := fun c₁ c₂ => cidr.aligned_le_antisymm


/-- CIDR blocks are adjacent iff they share a mask and their base addresses
differ by the common subnet size-/
def cidr.isAdjacent (c₁ c₂ : CIDR) :=
  c₁.mask = c₂.mask ∧ |intOfIP c₁.base - intOfIP c₂.base| = subnetSize c₁.mask


/-- Prop for mask sharing -/
def cidr.sameMask (c₁ c₂ : CIDR) :=
  c₁.mask = c₂.mask


/-- Prop for a CIDR block being covered by some supernet `s`-/
def cidr.inSupernet (c s : CIDR) := c < s


/-- The supernet formed that contains all the members of `ℓ`-/
def cidr.supernetOfList (ℓ : List CIDR) (h : ℓ ≠ []) : CIDR :=
  let b₀ := (ℓ.head h).base
  let m := (ℓ.head h).mask
  let n := Nat.log2 ℓ.length
  let M := SubnetMask.mk $ m - n
  CIDR.mk (applySubnetMask b₀ M) M


/-- A list of CIDR blocks are mergeable iff:

 i. No blocks in the list overlap

 ii. All blocks share a mask

 iii. All blocks are adjacent

 iv. The number of blocks is a power of two

 v. There exists a block that is aligned to the new supernet-/
def cidr.isMergeable (ℓ : List CIDR) (h : ℓ ≠ []):=
  List.Pairwise cidr.disjoint ℓ
  ∧ List.Pairwise cidr.sameMask ℓ
  ∧ List.Forall (λ c => cidr.inSupernet c (cidr.supernetOfList ℓ h)) ℓ
  ∧ Nat.isPowerOfTwo ℓ.length
