import Mathlib.Data.Nat.ModEq
open Nat

namespace Util

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
  · cases h with
  | inl h_1 =>
    subst h_1
    simp_all only [le_refl]
    simp [ModEq.eq_1] at hmod
    have hbmod : 2 ^ b % 2 ^ a = 0 := by
      simpa [Nat.mod_self] using hmod.symm
    have hdiv : 2 ^ a ∣ 2 ^ b := Nat.dvd_of_mod_eq_zero hbmod
    have hle  : a ≤ b := (pow_dvd_pow_iff_le_right (by decide : 1 < (2 :ℕ))).mp hdiv
    exact Nat.le_antisymm hle hb
  | inr h_2 =>
    subst h_2
    simp_all only [le_refl]
    simp [ModEq.eq_1] at hmod
    --TODO: try to remove simp
    have hamod : 2 ^ a % 2 ^ b = 0 := by
      simp_all only
    have hdiv : 2 ^ b ∣ 2 ^ a := Nat.dvd_of_mod_eq_zero hamod
    have hle  : b ≤ a := (pow_dvd_pow_iff_le_right (by decide : 1 < (2 :ℕ))).mp hdiv
    exact Nat.le_antisymm ha hle
  · simp_all only [not_or]
    obtain ⟨left, right⟩ := h
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
