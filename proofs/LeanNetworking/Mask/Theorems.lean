import LeanNetworking.Util
import LeanNetworking.Mask.Defs
import LeanNetworking.Mask.BitVec

open BitVecUtil

/-- le_antisymm but on masks-/
theorem mask_le_antisymm {m₁ m₂ : SubnetMask} :
  m₁ ≤ m₂ → m₂ ≤ m₁ → m₁ = m₂ := by

  intro h1 h2

  simp_all only [SubnetMask.instLE]
  have heq := Nat.le_antisymm h1 h2

  exact Subtype.coe_inj.mp heq


lemma mask_zero_index_lt_32 {m : SubnetMask} (h : 0 < m.val) :
  m.val - 1 < 32 := by

  rw [Nat.sub_lt_iff_lt_add]
  --(→) ↑m < 32 + 1
  · simp only [Nat.reduceAdd]
    rw [Nat.lt_succ_iff]
    exact m.property.right
  --(←) 0 < ↑m
  · exact Nat.succ_le.mpr h


/--Any all one vector index is true-/
lemma bit_allOnes_true {n k : Nat} (hk : k < n) :
    (BitVec.allOnes n)[k]'hk = true := by

  exact BitVec.getElem_allOnes k hk


/--Applying the same mask twice yields the same vector-/
theorem mask_idempotence (ip : IP) (mask : SubnetMask) :
  applySubnetMask (applySubnetMask ip mask) mask = applySubnetMask ip mask := by

  simp [-bitvec_and_left_idempotence, -bitvec_and_right_idempotence]
  rw [bitvec_and_right_idempotence]


lemma min_mask_32_is_mask (mask : SubnetMask) :
  min mask.val 32 = mask.val := by

  have h := Nat.min_le_left mask.val 32
  apply Nat.min_eq_left
  apply SubnetMask.subnet_le_32

/-- The minimum of two masks is equal to the minimum of their values-/
lemma mask_min_val_nat (mask₁ mask₂ : SubnetMask):
  (mask₁.min mask₂).val = Nat.min mask₁.val mask₂.val := by

  simp only [SubnetMask.min, SubnetMask.mk]
  simp only [Nat.min_assoc, le_inf_iff, Nat.zero_le, and_self, sup_of_le_right]
  rw [min_mask_32_is_mask]


/-- The minimum of two masks is within the mask bounds-/
lemma min_within_bounds
  {m₁ m₂ : SubnetMask} :
  0 ≤ m₁.val.min m₂.val ∧ m₁.val.min m₂.val ≤ 32 := by

  apply And.intro
  · simp only [le_inf_iff, Nat.zero_le, and_self]
  · rw [←mask_min_val_nat]; exact SubnetMask.mask_min_le_32

/-- The index `i` of a mask vector is true iff `i ≥ m`-/
lemma mask_vec_decide {w : Nat} {m i : Nat} (hi : i < w):
  (BitVec.allOnes w <<< m)[i] = decide (i ≥ m) := by

  simp_all only
    [BitVec.getElem_shiftLeft, BitVec.getElem_allOnes,
    Bool.and_true, ge_iff_le, Bool.not_eq_eq_eq_not]
  simp only [←decide_not, not_le]

/-- The index `i` of a host vector is true iff `i < w - m`-/
lemma host_vec_decide {w : Nat} {m i : Nat} (hi : i < w):
  (BitVec.allOnes w >>> m)[i] = decide (i < w - m) := by

  simp_all only [BitVec.getElem_ushiftRight, BitVec.getLsbD_allOnes, decide_eq_decide]
  apply Iff.intro
  · intro a
    rw [Nat.add_comm] at a
    exact Nat.lt_sub_of_add_lt a
  · intro a
    exact Nat.add_lt_of_lt_sub' a

/-- The index `i` of a mask vector is true iff `i ≥ m`-/
lemma maskvec_bit {m i} (h : i < 32):
  ((BitVec.allOnes 32 <<< (32 - m))[i]) = decide (i ≥ 32 - m) := by

  simp only [BitVec.getElem_shiftLeft, ge_iff_le, Nat.sub_le_iff_le_add]
  have hbit : ((BitVec.allOnes 32)[i - (32 - m)]) = true := by
    apply bit_allOnes_true
  rw [hbit]
  rw [Bool.and_true]
  have h₀ : (¬ i < 32 - m) ↔ 32 ≤ i + m := by
    simp only [not_lt, Nat.sub_le_iff_le_add]
  by_cases h : 32 ≤ i + m
  · have : ¬ i < 32 - m := h₀.mpr h
    simp only [this, h, decide_false, Bool.not_false, decide_true]
  · have : i < 32 - m := by
      rw [←Nat.not_lt] at h
      simp only [not_lt, not_le] at h
      apply Nat.lt_sub_of_add_lt h
    simp only [this, h, decide_true, Bool.not_true, decide_false]


/-- Given two mask vectors `u, v`, `u AND v` is equivalent to the minimum of `u, v`-/
@[simp] theorem maskvec_and_eq_maskvec_min
  {mask₁ mask₂ : SubnetMask} :
  (maskVec mask₁) &&& (maskVec mask₂) = maskVec (SubnetMask.min mask₁ mask₂) := by

  simp only [maskVec]
  rw [SubnetMask.min_val, Nat.min_eq_min]
  ext i hi
  repeat rw [maskvec_bit]
  simp only
    [BitVec.getElem_and, BitVec.getElem_shiftLeft, ge_iff_le, Nat.sub_le_iff_le_add]
  have hbit₁ : ((BitVec.allOnes 32)[ i - (32 - mask₁.val)]) = true := by
    apply bit_allOnes_true
  have hbit₂ : ((BitVec.allOnes 32)[i - (32 - mask₂.val)]) = true := by
    apply bit_allOnes_true
  rw [hbit₁, hbit₂]
  repeat rw [Bool.and_true]
  simp only [←decide_not, not_lt, Nat.sub_le_iff_le_add, ←Bool.decide_and, decide_eq_decide]


  apply Iff.intro

  -- (→) 32 ≤ i + ↑mask₁ ∧ 32 ≤ i + ↑mask₂ → 32 ≤ i + min ↑mask₁ ↑mask₂
  by_cases hmask: mask₁.val < mask₂.val
  · intro h
    rw [Nat.min_eq_left]
    exact h.left
    apply Nat.le_of_lt
    exact hmask
  · intro h
    have hmask := Nat.lt_succ_iff.mp (Nat.not_le.mp hmask)
    rw [Nat.min_comm mask₁ mask₂]
    rw [Nat.min_eq_left hmask]
    exact h.right

  -- (←) 32 ≤ i + min ↑mask₁ ↑mask₂ → 32 ≤ i + ↑mask₁ ∧ 32 ≤ i + ↑mask₂
  intro h
  apply And.intro

  -- case 32 ≤ i + ↑mask₁
  have h₁ := Nat.min_le_left mask₁ mask₂
  have h₂ := Nat.add_le_add_left h₁ i
  exact Nat.le_trans h h₂

  -- case 32 ≤ i + ↑mask₂
  have h₁ := Nat.min_le_right mask₁ mask₂
  have h₂ := Nat.add_le_add_left h₁ i
  exact Nat.le_trans h h₂


/-- If a bit is flipped inside the prefix, two masked vectors are not equal-/
lemma flip_inside_prefix_imp_ne
  {m : SubnetMask} {a b : IP} :
  (∃ (i : Nat) (hi32 : i < 32), 32 - m.val ≤ i ∧ a[i] ≠ b[i]) → applySubnetMask a m ≠ applySubnetMask b m := by

  intro h
  rcases h with ⟨i, hi32, hkeep, hdiff⟩
  simp only [applySubnetMask, maskVec]
  simp only [BitVec.and_eq]
  apply ne_of_exists_ne_bit
  exists i
  exists hi32
  repeat rw [BitVec.getElem_and]
  rw [mask_vec_decide]
  simp only [ge_iff_le]
  simp_all only [Nat.sub_le_iff_le_add, ne_eq, decide_true, Bool.and_true, not_false_eq_true]


/-- Applying two masks to an IP is equivalent to applying the minimum of the two masks-/
theorem mask_composition
  (ip : IP) (mask₁ mask₂ : SubnetMask) :
  applySubnetMask (applySubnetMask ip mask₁ ) mask₂ = applySubnetMask ip (SubnetMask.min mask₁ mask₂) := by

  repeat rw [applySubnetMask]
  repeat rw [BitVec.and_eq]
  rw [BitVec.and_assoc]
  rw [maskvec_and_eq_maskvec_min]


theorem left_mask_composition_of_le
  {ip : IP} {m₁ m₂ : SubnetMask}
  (h : m₁ ≤ m₂) :
  applySubnetMask (applySubnetMask ip m₁ ) m₂ = applySubnetMask ip m₁ := by

  simp only [mask_composition]
  have hmin := SubnetMask.min_eq_left h
  rw [hmin]


theorem right_mask_composition_of_le
  {ip : IP} {m₁ m₂ : SubnetMask}
  (h : m₁ ≤ m₂) :
  applySubnetMask (applySubnetMask ip m₂) m₁ = applySubnetMask ip m₁ := by

  simp only [mask_composition]
  have hmin := SubnetMask.min_eq_right h
  rw [hmin]


--TODO: calc
@[simp]
lemma mask_and_delta_disjoint_lt
  {w : Nat} {m n : Nat} (hm: m < n)
  (hnw : n < w) :
  BitVec.allOnes w <<< (w - m) &&& BitVec.ofNat w 1 <<< (w - n) = 0 := by

  ext i hi
  rw [BitVec.getElem_and]
  rw [BitVec.ofNat_eq_ofNat, BitVec.getElem_zero]
  rw [lshift_one_hot_decide, mask_vec_decide]
  rw [←Bool.decide_and]
  rw [decide_eq_false_iff_not]
  rw [not_and]
  intro h
  have hmw : m < w := Nat.lt_trans hm hnw
  have hmnw : w - n < w - m := Nat.sub_lt_sub_left hmw hm
  have hneq := Ne.symm $ Nat.ne_of_lt $ Nat.lt_of_lt_of_le hmnw h
  rw [←ne_eq]
  exact hneq


/-- If a mask `m` is greater than a number `n`, the conjunction of the mask vec of `m`
  and delta vec of `n` is `0`-/
lemma mask_and_delta_disjoint_le
  {w : Nat} {m n : Nat}
  (hm: m < n) (hnw : n ≤ w) :
  BitVec.allOnes w <<< (w - m) &&& BitVec.ofNat w 1 <<< (w - n) = 0 := by

  by_cases h : n = w
  · replace hnw := h
    rw [hnw]
    clear h
    ext i hi
    rw [BitVec.getElem_and]
    rw [BitVec.ofNat_eq_ofNat, BitVec.getElem_zero]
    rw [lshift_one_hot_decide, mask_vec_decide]
    rw [←Bool.decide_and]
    rw [decide_eq_false_iff_not]
    rw [not_and]
    intro h
    rw [hnw] at hm
    have hwm : w - m ≥ 1 := by
      apply Nat.sub_pos_iff_lt.2
      exact hm
    rw [Nat.sub_eq_zero_of_le (by rfl)]
    apply Nat.ne_zero_iff_zero_lt.mpr
    have h' := Nat.le_trans hwm h
    exact h'
  · replace h: n < w := Nat.lt_of_le_of_ne hnw h
    exact mask_and_delta_disjoint_lt hm h


/-- maskVec is bijective-/
lemma mask_vec_cancel (mask₁ mask₂ : SubnetMask) :
  mask₁ = mask₂ ↔ maskVec mask₁ = maskVec mask₂ := by

  apply Iff.intro

  -- (→) mask₁ = mask₂ → maskVec mask₁ = maskVec mask₂
  intro h
  rw [h]

  -- (←) maskVec mask₁ = maskVec mask₂ → mask₁ = mask₂
  intro h
  apply Subtype.ext
  rw [maskVec] at h
  have allones_equal := allones_left_shift_cancel (w:=32) (m:=32-mask₁.val) (n:=32-mask₂.val)

  have hm := Nat.sub_le 32 mask₁.val
  have hn := Nat.sub_le 32 mask₂.val
  have h₁ := allones_equal hm hn h
  apply Util.sub_right_inj mask₁.property.right mask₂.property.right
  exact h₁


theorem mask_vec_left_absorb_of_le
  {m₁ m₂ : SubnetMask} (h : m₁ ≤ m₂):
  maskVec m₁ &&& maskVec m₂ = maskVec m₁ := by

  rw [maskvec_and_eq_maskvec_min]
  rw [←mask_vec_cancel]
  exact SubnetMask.min_eq_left h


lemma mask_vec_right_absorb_of_le
  {m₁ m₂ : SubnetMask} (h : m₁ ≤ m₂) :
  maskVec m₂ &&& maskVec m₁ = maskVec m₁ := by

  rw [BitVec.and_comm]
  rw [mask_vec_left_absorb_of_le h]


theorem apply_absorb_left_of_le
  {ip : IP} {m₁ m₂ : SubnetMask} (h : m₁ ≤ m₂) :
  applySubnetMask (applySubnetMask ip m₁) m₂ = applySubnetMask ip m₁ := by

  rw [mask_composition]
  rw [SubnetMask.min_eq_left h]


theorem apply_absorb_right_of_le
  {ip : IP} {m₁ m₂ : SubnetMask} (h : m₁ ≤ m₂) :
  applySubnetMask (applySubnetMask ip m₂) m₁ = applySubnetMask ip m₁ := by

  rw [mask_composition]
  rw [SubnetMask.min_eq_right h]
