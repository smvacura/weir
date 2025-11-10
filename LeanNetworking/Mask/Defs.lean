import LeanNetworking.IP
import LeanNetworking.Util

/-- An IPv4 subnet mask-/
abbrev SubnetMask := Util.BoundedNat 0 32

namespace SubnetMask


/-- Clipping `n` into the interval `[0, 32]` is sufficient for constructing a SubnetMask-/
@[simp] theorem subnet_bounds_correct (n : Nat) :
  0 ≤ max 0 (min n 32) ∧ (max 0 (min n 32)) ≤ 32 := by

  apply And.intro

  -- case 0 ≤ max 0 (min n 32)
  apply Nat.zero_le
  rw [Nat.max_le]

  -- case 0 ≤ 32 ∧ min n 32 ≤ 32

  apply And.intro

  -- case 0 ≤ 32
  · decide
  -- case min n 32 ≤ 32
  · apply Nat.min_le_right


/-- The SubnetMask constructor. Clips `n` into the interval `[0, 32]`-/
def mk (n : Nat) : SubnetMask :=
  ⟨max 0 (min n 32), subnet_bounds_correct n⟩


/-- The coercion instance from `SubnetMask` to `ℕ`. Return the underlying bounded value.-/
instance : Coe SubnetMask Nat where
  coe m := m.val


/-- Returns the lesser of two masks by comparing their `ℕ` values

  Returns `m₁` if `(m₁ : ℕ) ≤ (m₂ : ℕ)`, or  `m₂` if `(m₂ : ℕ) ≤ (m₁ : ℕ)`-/
def min (m₁ m₂ : SubnetMask) :=
  SubnetMask.mk (Nat.min (m₁ : ℕ) (m₂ : ℕ))


/-- The `LT` instance for `SubnetMasks`. Equivalent to `LT` on the `ℕ` coercions -/
instance : LT SubnetMask where
  lt a b := (a : ℕ) < (b : ℕ)


/-- The `LE` instance for `SubnetMasks`. Equivalent to `LE` on the `ℕ` coercions -/
instance : LE SubnetMask where
  le a b := (a : ℕ) ≤ (b : ℕ)


instance : HAdd SubnetMask Nat SubnetMask where
  hAdd m n :=
    if (m : ℕ) + n > 32
    then SubnetMask.mk 32
    else SubnetMask.mk $ (m : ℕ) + n

instance : HSub SubnetMask Nat SubnetMask where
  hSub m n := SubnetMask.mk $ (m : ℕ) - n

lemma eq_impl_le (m₁ m₂ : SubnetMask) :
  m₁ = m₂ → m₁ ≤ m₂ := by
  intro h
  rw [SubnetMask.instLE]
  simp [Subtype.eq_iff.mp h]


lemma subnet_le_32 (m : SubnetMask) : (m : ℕ) ≤ 32 := by
  exact m.property.right

lemma min_val_32_eq_val (m : SubnetMask) : Nat.min m.val 32 = m.val := by
  have h := subnet_le_32 m
  apply Nat.min_eq_left h

lemma min_val (a b : SubnetMask) :
  (min a b).val = Nat.min a.val b.val := by
  rw [min, mk]
  simp [subnet_le_32]


theorem min_eq_left {m₁ m₂ : SubnetMask} (h : m₁ ≤ m₂) : SubnetMask.min m₁ m₂ = m₁ := by
  rw [SubnetMask.min, SubnetMask.mk]
  apply Subtype.ext
  simp [min_val_32_eq_val]
  exact h


theorem min_eq_right {m₁ m₂ : SubnetMask} (h : m₂ ≤ m₁) : SubnetMask.min m₁ m₂ = m₂ := by
  rw [SubnetMask.min, SubnetMask.mk]
  apply Subtype.ext
  simp [min_val_32_eq_val]
  exact h


theorem mask_min_le_32 {m₁ m₂ : SubnetMask} : (SubnetMask.min m₁ m₂).val ≤ 32 := by
  simp [SubnetMask.min, SubnetMask.mk, SubnetMask.min_val_32_eq_val]
  exact Or.inl m₁.property.right


theorem lt_of_not_le {m₁ m₂ : SubnetMask} : ¬ m₁ ≤ m₂ → m₂ < m₁ := by
  intro h
  simp [SubnetMask.instLE] at h
  simp [SubnetMask.instLT]
  exact h

end SubnetMask


/-- The vector representing `SubnetMask m`. Equivalent to a 32-bit word with the most significant `m` bits set to `true` and the rest `false`-/
@[simp] def maskVec (m : SubnetMask) : BitVec 32 :=
  BitVec.allOnes 32 <<< (32 - m.val)


@[simp]
def applySubnetMask (ip : IP) (m : SubnetMask): IP :=
  let maskVector : IP := maskVec m
  BitVec.and ip maskVector
