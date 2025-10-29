import Mathlib.Tactic.ApplyFun
import Mathlib.Data.BitVec

import LeanNetworking.Util

namespace BitVecUtil

@[simp]
theorem bitvec_and_left_idempotence (n : Nat) (u v : BitVec n) :
  u &&& v = u &&& u &&& v := by

  rw [BitVec.and_self]

@[simp]
theorem bitvec_and_right_idempotence (n : Nat) (u v : BitVec n) :
  (u &&& v) &&& v = u &&& v := by

  rw [BitVec.and_assoc]
  rw [BitVec.and_self]


/-- If two bitvectors are elementwise equal, the vectors are equal-/
lemma bitvec_eq_of_forall_bits {w} {u v : BitVec w}
  (h : ∀ (i : ℕ) (hi : i < w), u[i] = v[i]) : u = v := by

  ext j hj
  exact h j hj


/-- If two bitvectors are not equal, there exists an element `i` that differs between them-/
lemma exists_ne_bit_of_ne {w : Nat} {u v : BitVec w} (h : u ≠ v) :
  ∃ (i : ℕ) (hi : i < w), u[i] ≠ v[i] := by

  simp_all only [ne_eq]
  by_contra hne
  simp only [not_exists, Decidable.not_not] at hne
  replace hne := bitvec_eq_of_forall_bits hne
  contradiction


/-- If two bitvectors differ at bit `i`, the vectors are not equal-/
lemma ne_of_exists_ne_bit {w : Nat} {u v : BitVec w}
  (h : ∃ (i : ℕ) (hi : i < w), u[i] ≠ v[i]) : u ≠ v := by

  rcases h with ⟨i, hi, h_neq⟩
  simp_all only [ne_eq]
  apply Aesop.BuiltinRules.not_intro
  intro a
  subst a
  simp_all only [not_true_eq_false]


/-- Left-shifting by more than the bitvector width zeroes out the vector-/
lemma ge_w_allones_left_shift_eq_zero {w : Nat} {m : Nat} (hm : m ≥ w) :
  BitVec.allOnes w <<< m = 0#w := by

  simp_all only [ge_iff_le, BitVec.shiftLeft_eq_zero]

/-- Left-shifting an all-ones vector by less than the width has at least one 1-bit-/
lemma lt_w_allones_left_shift_ne_zero {w : Nat} {m : Nat} (hm : m < w) :
  BitVec.allOnes w <<< m ≠ 0#w := by

  simp_all only [ne_eq, BitVec.msb_shiftLeft, BitVec.getMsbD_allOnes, decide_true, BitVec.ne_zero_of_msb_true,
    not_false_eq_true]

/-- Left-shifting by zero preserves the all-one input vector-/
lemma zero_allones_left_shift_eq_one {w : Nat} {m : Nat} (hm : m = 0) :
  BitVec.allOnes w <<< m = BitVec.allOnes w := by

  subst hm
  simp_all only [BitVec.shiftLeft_zero]

/-- Left-shifting an all-ones vector by more than one yields a vector not equal to all ones-/
lemma gt_zero_allones_left_shift_ne_one {w : Nat} {m : Nat} (hw : 1 ≤ w) (hm : m > 0) :
  BitVec.allOnes w <<< m ≠ BitVec.allOnes w := by

  simp_all only [gt_iff_lt, ne_eq]
  by_contra a
  replace a := congrArg BitVec.toNat a
  rw [BitVec.toNat_shiftLeft] at a
  repeat rw [BitVec.toNat_allOnes] at a
  repeat rw [Nat.shiftLeft_eq] at a
  have h : m = 0 := by sorry
  replace hm := Nat.ne_of_gt hm
  contradiction

/-- Cancellation lemma for shifting an all-one vector left-/
lemma allones_left_shift_cancel {w : Nat} {m n : Nat} (hm : m ≤ w) (hn : n ≤ w) :
  BitVec.allOnes w <<< m = BitVec.allOnes w <<< n → m = n := by

  intro h
  replace h : (BitVec.allOnes w <<< m).toNat = (BitVec.allOnes w <<< n).toNat := by
    exact congrArg BitVec.toNat h
  repeat rw [BitVec.toNat_shiftLeft] at h
  repeat rw [BitVec.toNat_allOnes] at h
  repeat rw [Nat.shiftLeft_eq] at h
  rw [←Nat.ModEq.eq_1] at h
  replace h := Nat.ModEq.cancel_left_of_coprime (Util.gcd_pred_is_one (by apply Nat.one_le_pow')) h
  exact Util.Mod.two_pow_inj hm hn h


/-- Given a one hot vector v, formed by left shifting a single-bit vector n bits, `v[m] = true` iff `m = n`-/
lemma one_hot_eq_iff_eq {w : Nat} {m n : Nat} (hm : m < w) (hn : n < w) :
  m = n ↔ (BitVec.ofNat w 1 <<< n)[m] = true := by

  simp_all only [BitVec.getElem_shiftLeft, BitVec.getElem_one, Bool.and_eq_true,
    Bool.not_eq_eq_eq_not, Bool.not_true,
    decide_eq_false_iff_not, not_lt, decide_eq_true_eq]
  apply Iff.intro
  · intro heq
    subst heq
    simp_all only [le_refl, Nat.sub_self, and_self]
  · intro h
    have ⟨left, right⟩ := h
    have h₁ := Nat.sub_eq_zero_iff_le.mp right
    exact Nat.le_antisymm h₁ left


/-- Given a one hot vector v, formed by left shifting a single-bit vector n bits, `v[m] = false` iff `m ≠ n`-/
lemma one_hot_neq_iff_neq {w : Nat} {m n : Nat} (hm : m < w) (hn : n < w) :
  m ≠ n ↔ (BitVec.ofNat w 1 <<< n)[m] = false := by

  apply Iff.intro
  · intro a
    have h' := mt (one_hot_eq_iff_eq hm hn).mpr a
    exact Bool.bool_eq_false h'
  · intro a
    have h' := Bool.bool_iff_false.mpr a
    exact mt (one_hot_eq_iff_eq hm hn).mp h'


/-- Getting a specific index `i` from a one-hot vector constructed by shifting the initial LSB 1 bit left `n` bits
    is equal to deciding if `i = n`-/
lemma lshift_one_hot_decide {w : Nat} {i n : Nat} (hi : i < w) :
  (BitVec.ofNat w 1 <<< n)[i] = decide (i = n) := by

  by_cases h_eq : i = n
  -- case i = n
  · subst h_eq
    simp_all only [BitVec.getElem_shiftLeft, lt_self_iff_false, decide_false, Bool.not_false, Nat.sub_self,
    BitVec.getElem_one, decide_true, Bool.and_self]
  -- case i ≠ n
  · simp_all only [BitVec.getElem_shiftLeft, BitVec.getElem_one, decide_false,
    Bool.and_eq_false_imp, Bool.not_eq_eq_eq_not, Bool.not_true,
    decide_eq_false_iff_not, not_lt]

    intro h_n_le_i
    apply Not.intro
    intro h_i_le_n
    replace h_i_le_n := Nat.sub_eq_zero_iff_le.mp h_i_le_n
    have heq := Nat.le_antisymm h_i_le_n h_n_le_i
    contradiction


/-- Getting a specific index `i` from a one-hot vector constructed by shifting the initial LSB 1 bit left `m` bits
    is equal to deciding if `i = m`-/
lemma delta_decide {w : Nat} {m i : Nat} (hi : i < w) :
  (1#w <<< m)[i] = decide (i = m) := by

  simp_all only [BitVec.getElem_shiftLeft, BitVec.getElem_one]
  rw [←decide_not]
  rw [←Bool.decide_and]
  rw [decide_eq_decide]

  apply Iff.intro

  -- (→)
  · intro ⟨h, h'⟩
    replace h := Nat.not_lt.mp h
    replace h' := Nat.sub_eq_zero_iff_le.mp h'
    exact Nat.le_antisymm h' h

  -- (←)
  · intro h

    apply And.intro
    -- ¬i < m
    · apply Nat.not_lt.mpr
      exact Nat.le_of_eq h.symm
    -- i - m = 0
    · exact Nat.sub_eq_zero_iff_le.mpr $ Nat.le_of_eq h


/--  AND distributes over XOR for bitvecs-/
lemma bitvec_and_xor_distrib_right {w : Nat} {x u v : BitVec w} :
  (u ^^^ v) &&& x = (u &&& x) ^^^ (v &&& x) := by

  apply_fun BitVec.toNat
  · simp only [BitVec.toNat_and, BitVec.toNat_xor]
    rw [Nat.and_xor_distrib_right]
  · exact BitVec.toNat_injective


/-- The bit `i` of two vectors u,v XOR is `i` of the first vector only if `i` of the second vector is `false`-/
lemma bit_xor_decide {w : Nat} {u v : BitVec w} {i : Nat}
  (hi : i < w) : (u ^^^ v)[i] = u[i] ↔ v[i] = false := by

  constructor
  intro h
  rw [BitVec.getElem_xor] at h
  by_contra hf
  simp_all only [Bool.bne_true, Bool.not_eq_eq_eq_not, Bool.eq_not_self]

  intro h
  rw [BitVec.getElem_xor]
  rw [h]
  exact Bool.xor_false u[i]

end BitVecUtil
