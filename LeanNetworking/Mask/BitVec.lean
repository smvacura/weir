import Mathlib.Tactic.ApplyFun
import Mathlib.Data.BitVec

import LeanNetworking.Util

@[simp]
theorem bitvec_and_left_idempotence (n : Nat) (u v : BitVec n) : u &&& v = u &&& u &&& v := by
  rw [BitVec.and_self]

@[simp]
theorem bitvec_and_right_idempotence (n : Nat) (u v : BitVec n) : (u &&& v) &&& v = u &&& v := by
  rw [BitVec.and_assoc]
  rw [BitVec.and_self]


lemma bitvec_eq_of_forall_bits {w} {u v : BitVec w} (h : ∀ (i : ℕ) (hi : i < w), u[i] = v[i]) : u = v := by
  ext j hj
  exact h j hj


lemma exists_ne_bit_of_ne {w : Nat} {u v : BitVec w} (h : u ≠ v) : ∃ (i : ℕ) (hi : i < w), u[i] ≠ v[i] := by
  simp_all only [ne_eq]
  by_contra hne
  simp at hne
  replace hne := bitvec_eq_of_forall_bits hne
  contradiction


lemma ne_of_exists_ne_bit {w : Nat} {u v : BitVec w} (h : ∃ (i : ℕ) (hi : i < w), u[i] ≠ v[i]) : u ≠ v := by
  rcases h with ⟨i, hi, h_neq⟩
  simp_all only [ne_eq]
  apply Aesop.BuiltinRules.not_intro
  intro a
  subst a
  simp_all only [not_true_eq_false]


lemma ge_w_allones_left_shift_eq_zero {w : Nat} {m : Nat} (hm : m ≥ w) : BitVec.allOnes w <<< m = 0#w :=
  by simp_all only [ge_iff_le, BitVec.shiftLeft_eq_zero]

lemma lt_w_allones_left_shift_ne_zero {w : Nat} {m : Nat} (hm : m < w) : BitVec.allOnes w <<< m ≠ 0#w := by
  simp_all only [ne_eq, BitVec.msb_shiftLeft, BitVec.getMsbD_allOnes, decide_true, BitVec.ne_zero_of_msb_true,
    not_false_eq_true]

lemma zero_allones_left_shift_eq_one {w : Nat} {m : Nat} (hm : m = 0) : BitVec.allOnes w <<< m = BitVec.allOnes w := by
  subst hm
  simp_all only [BitVec.shiftLeft_zero]

lemma gt_zero_allones_left_shift_ne_one {w : Nat} {m : Nat} (hw : 1 ≤ w) (hm : m > 0) : BitVec.allOnes w <<< m ≠ BitVec.allOnes w := by
  simp_all only [gt_iff_lt, ne_eq]
  by_contra a
  replace a := congrArg BitVec.toNat a
  rw [BitVec.toNat_shiftLeft] at a
  repeat rw [BitVec.toNat_allOnes] at a
  repeat rw [Nat.shiftLeft_eq] at a
  have h : m = 0 := by sorry
  replace hm := Nat.ne_of_gt hm
  contradiction

lemma allones_left_shift_cancel {w : Nat} {m n : Nat} (hm : m ≤ w) (hn : n ≤ w): BitVec.allOnes w <<< m = BitVec.allOnes w <<< n → m = n := by
  intro h
  replace h : (BitVec.allOnes w <<< m).toNat = (BitVec.allOnes w <<< n).toNat := by
    exact congrArg BitVec.toNat h
  repeat rw [BitVec.toNat_shiftLeft] at h
  repeat rw [BitVec.toNat_allOnes] at h
  repeat rw [Nat.shiftLeft_eq] at h
  rw [←Nat.ModEq.eq_1] at h
  replace h := Nat.ModEq.cancel_left_of_coprime (Util.gcd_pred_is_one (by apply Nat.one_le_pow')) h
  exact Util.Mod.two_pow_inj hm hn h


--TODO: replace aesop proof
lemma one_hot_eq_iff_eq {w : Nat} {m n : Nat} (hm : m < w) (hn : n < w) : m = n ↔ (BitVec.ofNat w 1 <<< n)[m] = true := by
  simp_all only [BitVec.getElem_shiftLeft, BitVec.getElem_one, Bool.and_eq_true, Bool.not_eq_eq_eq_not, Bool.not_true,
    decide_eq_false_iff_not, not_lt, decide_eq_true_eq]
  apply Iff.intro
  · intro a
    subst a
    simp_all only [le_refl, Nat.sub_self, and_self]
  · intro a
    obtain ⟨left, right⟩ := a
    have h₁ := Nat.sub_eq_zero_iff_le.mp right
    exact Nat.le_antisymm h₁ left


lemma one_hot_neq_iff_neq {w : Nat} {m n : Nat} (hm : m < w) (hn : n < w) : m ≠ n ↔ (BitVec.ofNat w 1 <<< n)[m] = false := by
  apply Iff.intro
  · intro a
    have h' := mt (one_hot_eq_iff_eq hm hn).mpr a
    exact Bool.bool_eq_false h'
  · intro a
    have h' := Bool.bool_iff_false.mpr a
    exact mt (one_hot_eq_iff_eq hm hn).mp h'

--TODO replace aesop parts
lemma one_hot_decide {w : Nat} {i n : Nat} (hi : i < w) :
  (BitVec.ofNat w 1 <<< n)[i] = decide (i = n) := by
  by_cases h : i = n
  · subst h
    simp_all only [BitVec.getElem_shiftLeft, lt_self_iff_false, decide_false, Bool.not_false, Nat.sub_self,
    BitVec.getElem_one, decide_true, Bool.and_self]
  · simp_all only [BitVec.getElem_shiftLeft, BitVec.getElem_one, decide_false, Bool.and_eq_false_imp,
    Bool.not_eq_eq_eq_not, Bool.not_true, decide_eq_false_iff_not, not_lt]
    intro a
    apply Aesop.BuiltinRules.not_intro
    intro a₁
    replace a₁ := Nat.sub_eq_zero_iff_le.mp a₁
    have ha := Nat.le_antisymm a₁ a
    contradiction


lemma delta_decide {w : Nat} {m i : Nat} (hi : i < w) :
  (1#w <<< m)[i] = decide (i = m) := by
  simp_all only [BitVec.getElem_shiftLeft, BitVec.getElem_one]
  rw [←decide_not]
  rw [←Bool.decide_and]
  rw [decide_eq_decide]
  constructor

  intro ⟨h, h'⟩
  replace h := Nat.not_lt.mp h
  replace h' := Nat.sub_eq_zero_iff_le.mp h'
  exact Nat.le_antisymm h' h

  intro h
  constructor
  apply Nat.not_lt.mpr
  exact Nat.le_of_eq h.symm

  exact Nat.sub_eq_zero_iff_le.mpr $ Nat.le_of_eq h


lemma bitvec_and_xor_distrib_right {w : Nat} {x u v : BitVec w} : (u ^^^ v) &&& x = (u &&& x) ^^^ (v &&& x) := by
  apply_fun BitVec.toNat
  · simp only [BitVec.toNat_and, BitVec.toNat_xor]
    rw [Nat.and_xor_distrib_right]
  · exact BitVec.toNat_injective

lemma bit_xor_decide {w : Nat} {u v : BitVec w} {i : Nat} (hi : i < w) : (u ^^^ v)[i] = u[i] ↔ v[i] = false := by
  constructor
  intro h
  rw [BitVec.getElem_xor] at h
  by_contra hf
  simp_all only [Bool.bne_true, Bool.not_eq_eq_eq_not, Bool.eq_not_self]

  intro h
  rw [BitVec.getElem_xor]
  rw [h]
  exact Bool.xor_false u[i]
