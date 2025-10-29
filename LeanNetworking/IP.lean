import LeanNetworking.Util

abbrev IP := BitVec 32

/-- An IPv4 decimal block, which is a `Nat` bounded by `0` and `255`, inclusive -/
abbrev IPDecimalBlock := Util.BoundedNat 0 255

namespace IPDecimalBlock

/--  clipping the number into the interval `[0, 255]` puts the number into the required
interval for IP decimal blocks-/
lemma ip_bounds_correct (n : Nat) :
  0 ≤ max 0 (min n 255) ∧ (max 0 (min n 255)) ≤ 255 := by
  apply And.intro

  · apply Nat.zero_le
  · rw  [Nat.max_le]
    apply And.intro
    · decide
    · apply Nat.min_le_right


/-- Contstruct an IP decimal block from `n` by forcing `n` into `[0, 255]`-/
def mk (n : Nat) : IPDecimalBlock :=
  ⟨max 0 (min n 255), ip_bounds_correct n⟩

end IPDecimalBlock

/-- Construct a full 32-bit IPv4 address from four numbers `w, x, y, z`-/
def ipFromDecimal (w x y z : IPDecimalBlock) : IP :=
  let block_one := BitVec.ofNat 8 w.val
  let block_two := BitVec.ofNat 8 x.val
  let block_three := BitVec.ofNat 8 y.val
  let block_four := BitVec.ofNat 8 z.val

  0#0 ++ block_one ++ block_two ++ block_three ++ block_four
