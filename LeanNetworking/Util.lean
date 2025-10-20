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

lemma le_two_pow_of_le {a b : Nat} (h : a ≤ b) : a ≤ 2 ^ b := by
  induction b with
  | zero =>
    rw [Nat.pow_zero]
    rw [Nat.le_zero] at h
    rw [h]
    trivial
  | succ k ih =>
    rw [Nat.pow_succ]
    sorry



theorem Mod.two_pow_inj {a b m : Nat} (ha : a ≤ m) (hb : b ≤ m) (hmod : 2 ^ a ≡ 2 ^ b [MOD m]) : a = b := by
  sorry


theorem gcd_pred_is_one {a : Nat} (ha : 1 ≤ a): gcd a (a - 1) = 1 := by
  have h := Nat.coprime_sub_self_left ha
  simp_all only [coprime_one_right_eq_true, gcd_self_sub_right, gcd_one_right]

end Util
