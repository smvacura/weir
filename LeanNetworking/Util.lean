import Mathlib.Data.Nat.ModEq
open Nat

lemma test {x : Nat}: x ≤ x := Nat.le_refl x

namespace Util

/-- Generic type for a Nat with upper and lower bounds with `h ≤ n ≤ k` -/
def BoundedNat (h k: Nat) := { n : Nat // h ≤ n ∧ n ≤ k }

def BoundedNat.toVal {lo hi : Nat} (b : BoundedNat lo hi) := b.val

instance {lo hi : Nat} : CoeOut (BoundedNat lo hi) Nat where
  coe (b : BoundedNat lo hi) := b.val

instance (lo hi : Nat) : LE (BoundedNat lo hi) where
  le b₁ b₂ := b₁.val ≤ b₂.val

instance (lo hi : Nat) : LT (BoundedNat lo hi) where
  lt b₁ b₂ := b₁.val < b₂.val

lemma BoundedNat.not_le {lo hi : Nat} {b₁ b₂ : BoundedNat lo hi} :
  ¬b₁ ≤ b₂ ↔ b₂ < b₁ := by

  apply Iff.intro

  intro h
  unfold instLEBoundedNat at h
  unfold instLTBoundedNat
  simp_all only [Subtype.coe_le_coe, _root_.not_le, Subtype.coe_lt_coe]

  intro h
  unfold instLTBoundedNat at h
  unfold instLEBoundedNat
  simp_all only [Subtype.coe_le_coe, _root_.not_le, Subtype.coe_lt_coe]

lemma BoundedNat.le_of_lt {lo hi : Nat} {b₁ b₂ : BoundedNat lo hi} :
  b₁ < b₂ → b₁ ≤  b₂ := by

  intro h
  unfold instLTBoundedNat at h
  unfold instLEBoundedNat
  change ((b₁ : Nat) ≤ (b₂ : Nat))
  replace h : Nat.succ (b₁ : Nat) ≤ (b₂ : Nat) :=
      Nat.succ_le_of_lt h
  exact Nat.le_trans (Nat.le_succ _) h

instance (lo hi : Nat) : LinearOrder (BoundedNat lo hi) where
  le := (· ≤ ·)
  lt := (· < ·)
  le_refl b₁ := Nat.le_refl b₁.val
  le_trans b₁ b₂ b₃ := Nat.le_trans
  le_antisymm b₁ b₂ h₁ h₂ := by
    apply Subtype.ext
    exact Nat.le_antisymm h₁ h₂
  le_total b₁ b₂ := by
    by_cases h : b₁ ≤ b₂
    · apply Or.inl
      exact h
    · simp_all only [false_or]
      replace h := BoundedNat.not_le.mp h
      exact BoundedNat.le_of_lt h
  toDecidableLE := by
    intro x y
    by_cases h : x.val ≤ y.val
    · apply isTrue
      simp_all only [Subtype.coe_le_coe]
    · apply isFalse
      simp_all only [Subtype.coe_le_coe, not_le]
      exact BoundedNat.not_le.mpr h
  lt_iff_le_not_ge b₁ b₂ := by
    apply Iff.intro

    intro h
    have hle := BoundedNat.le_of_lt h
    simp_all only [true_and]
    apply Not.intro
    intro hble
    have h' := BoundedNat.not_le.mpr h
    contradiction

    intro ⟨hle, hnle⟩
    exact BoundedNat.not_le.mp hnle

instance (lo hi : Nat) : DecidableEq (BoundedNat lo hi) := by
  intro x y

  by_cases h : x.val = y.val
  · apply isTrue
    cases x
    cases y
    cases h
    rfl
  · apply isFalse
    intro hxy
    apply h
    exact congrArg BoundedNat.toVal hxy

theorem sub_right_inj {a m n : Nat} (h₁ : m ≤ a) (h₂ : n ≤ a) : a - m = a - n → m = n := by
  intro h
  have hₘ : (a - m) + m = a := by
    rw [Nat.add_comm]
    exact Nat.add_sub_of_le h₁
  have hₙ : (a - n) + n = a := by
    rw [Nat.add_comm]
    exact Nat.add_sub_of_le h₂
  have : (a - m) + m = (a - n) + n := by
    rw [hₘ, ← hₙ]
    repeat rw [Nat.sub_add_cancel]
    repeat exact h₂
  rw [h] at this
  exact Nat.add_left_cancel this


--TODO: clean up a bit
theorem Mod.two_pow_inj {a b m : Nat} (ha : a ≤ m) (hb : b ≤ m) (hmod : 2 ^ a ≡ 2 ^ b [MOD 2 ^ m]) : a = b := by
  by_cases h : a = m ∨ b = m
  -- case a = m ∨ b = m
  · cases h with
  -- case a = m
  | inl h_1 =>
    subst h_1
    simp_all only [le_refl]
    simp [ModEq.eq_1] at hmod
    have hbmod : 2 ^ b % 2 ^ a = 0 := by
      simpa [Nat.mod_self] using hmod.symm
    have hdiv : 2 ^ a ∣ 2 ^ b := Nat.dvd_of_mod_eq_zero hbmod
    have hle  : a ≤ b := (pow_dvd_pow_iff_le_right (by decide : 1 < (2 :ℕ))).mp hdiv
    exact Nat.le_antisymm hle hb
  -- case b = m
  | inr h_2 =>
    subst h_2
    simp_all only [le_refl]
    simp [ModEq.eq_1] at hmod
    have hdiv : 2 ^ b ∣ 2 ^ a := Nat.dvd_of_mod_eq_zero hmod
    have hle  : b ≤ a := (pow_dvd_pow_iff_le_right (by decide : 1 < (2 :ℕ))).mp hdiv
    exact Nat.le_antisymm ha hle
  -- a ≠ m ∧ b ≠ m
  · simp_all only [not_or]
    have ⟨left, right⟩ := h
    replace ha : a < m := lt_of_le_of_ne ha left
    replace hb : b < m := lt_of_le_of_ne hb right
    have hm : m > 0 := zero_lt_of_lt ha
    replace ha : 2 ^ a < 2 ^ m := Nat.pow_lt_pow_right (by decide) ha
    replace hb : 2 ^ b < 2 ^ m := Nat.pow_lt_pow_right (by decide) hb
    have heq := ModEq.eq_of_lt_of_lt hmod ha hb
    exact (Nat.pow_right_inj (by decide)).mp heq



theorem gcd_pred_is_one {a : Nat} (ha : 1 ≤ a): gcd a (a - 1) = 1 := by
  have h := Nat.coprime_sub_self_left ha
  simp_all only [coprime_one_right_eq_true, gcd_self_sub_right, gcd_one_right]

end Util
