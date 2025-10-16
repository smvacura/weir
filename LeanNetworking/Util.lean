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

end Util
