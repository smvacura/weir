import Std.Tactic.BVDecide

import Mathlib.Data.Nat.ModEq
import Mathlib.Tactic.ApplyFun
import Mathlib.Data.BitVec

import LeanNetworking.Util

macro "lemma" n:declId sig:declSig val:declVal : command =>
  `(theorem $n:declId $sig:declSig $val:declVal)


axiom extensionality {α} (A B : Set α) : (∀x, x ∈ A ↔ x ∈ B) ↔ A = B

abbrev IP := BitVec 32


def BoundedNat (h k: Nat) := { n : Nat // h ≤ n ∧ n ≤ k }

abbrev IPDecimalBlock := BoundedNat 0 255

namespace IPDecimalBlock

theorem ip_bounds_correct (n : Nat) : 0 ≤ max 0 (min n 255) ∧ (max 0 (min n 255)) ≤ 255 := by
  constructor
  apply Nat.zero_le
  rw  [Nat.max_le]
  constructor
  decide
  apply Nat.min_le_right


def mk (n : Nat) : IPDecimalBlock :=
  ⟨max 0 (min n 255), ip_bounds_correct n⟩

end IPDecimalBlock

abbrev SubnetMask := BoundedNat 0 32
namespace SubnetMask

@[simp]
theorem subnet_bounds_correct (n : Nat) : 0 ≤ max 0 (min n 32) ∧ (max 0 (min n 32)) ≤ 32 := by
  constructor
  apply Nat.zero_le
  rw [Nat.max_le]
  constructor
  decide
  apply Nat.min_le_right

def mk (n : Nat) : SubnetMask :=
  ⟨max 0 (min n 32), subnet_bounds_correct n⟩

def min (mask₁ mask₂ : SubnetMask) :=
  SubnetMask.mk (Nat.min mask₁.val mask₂.val)

instance : Coe SubnetMask Nat where
  coe m := m.val

instance : LT SubnetMask where
  lt a b := (a : ℕ) < (b : ℕ)

instance : LE SubnetMask where
  le a b := (a : ℕ) ≤ (b : ℕ)


lemma eq_impl_le (m₁ m₂ : SubnetMask) :
  m₁ = m₂ → m₁ ≤ m₂ := by
  intro h
  rw [SubnetMask.instLE]
  simp [Subtype.eq_iff.mp h]


lemma subnet_le_32 (mask : SubnetMask) :  mask.val ≤ 32 := by
  exact mask.property.right

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

lemma name_later {m n k : Nat} (h₁ : m ≤ k) (h₂ : n ≤ k) : Min.min m n ≤ k := by
  by_cases hmn : m ≤ n
  · rw [Nat.min_eq_left hmn]; exact h₁;
  · rw [Nat.not_le] at hmn; have hnm := Nat.le_of_lt hmn; rw [Nat.min_eq_right hnm]; exact h₂


theorem mask_min_le_32 {m₁ m₂ : SubnetMask} : (SubnetMask.min m₁ m₂).val ≤ 32 := by
  simp [SubnetMask.min, SubnetMask.mk, SubnetMask.min_val_32_eq_val]
  exact Or.inl m₁.property.right


theorem lt_of_not_le {m₁ m₂ : SubnetMask} : ¬ m₁ ≤ m₂ → m₂ < m₁ := by
  intro h
  simp [SubnetMask.instLE] at h
  simp [SubnetMask.instLT]
  exact h

end SubnetMask

def delta (m : SubnetMask) : BitVec 32 :=
  BitVec.ofNat 32 (1 <<< (32 - m.val))


def ipFromDecimal (w x y z : IPDecimalBlock) : IP :=
  let block_one := BitVec.ofNat 8 w.val
  let block_two := BitVec.ofNat 8 x.val
  let block_three := BitVec.ofNat 8 y.val
  let block_four := BitVec.ofNat 8 z.val

  (BitVec.nil) ++ block_one ++ block_two ++ block_three ++ block_four


@[simp]
def onesThenZeros (m n : Nat) (hmn : m ≤ n) : BitVec n :=
by
  simpa [Nat.add_sub_of_le hmn]
    using ((BitVec.allOnes m) ++ (BitVec.zero (n - m)))

def maskVecCast (m : SubnetMask) : BitVec 32 :=
  cast (by
    rw [Nat.add_sub_of_le m.property.right]
  ) (BitVec.allOnes m.val ++ BitVec.zero (32 - m.val))

@[simp]
def maskVec (m : SubnetMask) : BitVec 32 :=
  BitVec.allOnes 32 <<< (32 - m.val)

lemma mask_zero_index_lt_32 {m : SubnetMask} (h : 0 < m.val): m.val - 1 < 32 := by
  rw [Nat.sub_lt_iff_lt_add]
  · simp; rw [Nat.lt_succ_iff]; exact m.property.right
  · exact Nat.succ_le.mpr h

lemma bit_allOnes_true {n k : Nat} (hk : k < n) :
    (BitVec.allOnes n)[k]'hk = true := by
  exact BitVec.getElem_allOnes k hk


@[simp]
def applySubnetMask (ip : IP) (mask : SubnetMask): IP :=
  let maskVector : IP := maskVec mask
  BitVec.and ip maskVector

@[simp]
theorem bitvec_and_left_idempotence (n : Nat) (u v : BitVec n) : u &&& v = u &&& u &&& v := by
  rw [BitVec.and_self]

@[simp]
theorem bitvec_and_right_idempotence (n : Nat) (u v : BitVec n) : (u &&& v) &&& v = u &&& v := by
  rw [BitVec.and_assoc]
  rw [BitVec.and_self]


theorem mask_idempotence (ip : IP) (mask : SubnetMask) : applySubnetMask (applySubnetMask ip mask) mask = applySubnetMask ip mask := by
  simp [-bitvec_and_left_idempotence, -bitvec_and_right_idempotence]
  rw [bitvec_and_right_idempotence]


lemma min_mask_32_is_mask (mask : SubnetMask) : min mask.val 32 = mask.val := by
  have h := Nat.min_le_left mask.val 32
  apply Nat.min_eq_left
  apply SubnetMask.subnet_le_32

lemma mask_min_val_nat (mask₁ mask₂ : SubnetMask):
  (mask₁.min mask₂).val = Nat.min mask₁.val mask₂.val := by
  simp [SubnetMask.min]
  simp [SubnetMask.mk]
  rw [min_mask_32_is_mask]


lemma min_within_bounds {m₁ m₂ : SubnetMask} : 0 ≤ m₁.val.min m₂.val ∧ m₁.val.min m₂.val ≤ 32 := by
  constructor
  · simp
  · rw [←mask_min_val_nat]; exact SubnetMask.mask_min_le_32


lemma mask_vec_decide {w : Nat} {m i : Nat} (hi : i < w):
  (BitVec.allOnes w <<< m)[i] = decide (i ≥ m) := by
  simp_all only [BitVec.getElem_shiftLeft, BitVec.getElem_allOnes, Bool.and_true, ge_iff_le, Bool.not_eq_eq_eq_not]
  simp [←decide_not]

lemma host_vec_decide {w : Nat} {m i : Nat} (hi : i < w):
  (BitVec.allOnes w >>> m)[i] = decide (i < w - m) := by
  simp_all only [BitVec.getElem_ushiftRight, BitVec.getLsbD_allOnes, decide_eq_decide]
  apply Iff.intro
  · intro a
    rw [Nat.add_comm] at a
    exact Nat.lt_sub_of_add_lt a
  · intro a
    exact Nat.add_lt_of_lt_sub' a

lemma maskvec_bit {m i} (h : i < 32):
  ((BitVec.allOnes 32 <<< (32 - m))[i]) = decide (i ≥ 32 - m) := by
  simp
  have hbit : ((4294967295#32 : BitVec 32)[i - (32 - m)]) = true := by
    apply bit_allOnes_true
  rw [hbit]
  rw [Bool.and_true]
  have h₀ : (¬ i < 32 - m) ↔ 32 ≤ i + m := by
    simp
  by_cases h : 32 ≤ i + m
  · have : ¬ i < 32 - m := h₀.mpr h
    simp [this, h]
  · have : i < 32 - m := by
      rw [←Nat.not_lt] at h
      simp at h
      apply Nat.lt_sub_of_add_lt h
    simp [this, h]

@[simp]
theorem maskvec_and_eq_maskvec_min {mask₁ mask₂ : SubnetMask} : (maskVec mask₁) &&& (maskVec mask₂) = maskVec (SubnetMask.min mask₁ mask₂) := by
  simp only [maskVec]
  rw [SubnetMask.min_val, Nat.min_eq_min]
  ext i hi
  repeat rw [maskvec_bit]
  simp
  have hbit₁ : ((4294967295#32 : BitVec 32)[i - (32 - mask₁.val)]) = true := by
    apply bit_allOnes_true
  have hbit₂ : ((4294967295#32 : BitVec 32)[i - (32 - mask₂.val)]) = true := by
    apply bit_allOnes_true
  rw [hbit₁, hbit₂]
  repeat rw [Bool.and_true]
  simp [←decide_not, ←Bool.decide_and]
  constructor

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

  intro h
  constructor

  have h₁ := Nat.min_le_left mask₁ mask₂
  have h₂ := Nat.add_le_add_left h₁ i
  exact Nat.le_trans h h₂

  have h₁ := Nat.min_le_right mask₁ mask₂
  have h₂ := Nat.add_le_add_left h₁ i
  exact Nat.le_trans h h₂


--TODO: cleanup
lemma bitvec_eq_of_forall_bits {w} {u v : BitVec w} (h : ∀ (i : Fin w), u[i]'i.prop = v[i]'i.prop) : u = v := by
  ext j hj
  replace h : ∀ (i : ℕ) (hi : i < w), u[i] = v[i] := by
    intro j hj
    show u[j] = v[j]
    have : (↑(⟨j, hj⟩ : Fin w) : ℕ) = j := by
      -- a lemma that cast from Fin to Nat gives the original j
      simp
    -- rewrite that and then apply h (on Fin)
    simpa [this] using h (⟨j, hj⟩ : Fin w)
  exact h j hj


lemma exists_ne_bit_of_ne {w : Nat} {u v : BitVec w} (h : u ≠ v) : ∃i : Fin w, u[i]'i.prop ≠ v[i]'i.prop := by
  simp_all only [ne_eq, Fin.getElem_fin]
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

--TODO: fix aesop simp
lemma flip_inside_prefix_imp_ne {m : SubnetMask} {a b : IP} : (∃ (i : Nat) (hi32 : i < 32), 32 - m.val ≤ i ∧ a[i] ≠ b[i]) → applySubnetMask a m ≠ applySubnetMask b m := by
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

def sameSubnet (ip₁ ip₂ : IP) (mask : SubnetMask) : Prop :=
  applySubnetMask ip₁ mask = applySubnetMask ip₂ mask

def Network m := {n // applySubnetMask n m = n}

def Hosts m n := {ip // applySubnetMask ip m = n}

def subnet (a : IP) (m : SubnetMask) : Set IP :=
  fun ip => applySubnetMask ip m = applySubnetMask a m


def subnetSize (mask : SubnetMask) := 2^(32-mask.val)


lemma mem_subnet {a m ip} : (ip ∈ subnet a m) ↔ applySubnetMask ip m = applySubnetMask a m := Iff.rfl

theorem mask_composition (ip : IP) (mask₁ mask₂ : SubnetMask) : applySubnetMask (applySubnetMask ip mask₁ ) mask₂ = applySubnetMask ip (SubnetMask.min mask₁ mask₂) := by
  repeat rw [applySubnetMask]
  repeat rw [BitVec.and_eq]
  rw [BitVec.and_assoc]
  rw [maskvec_and_eq_maskvec_min]

theorem left_mask_composition_of_le {ip : IP} {m₁ m₂ : SubnetMask} (h : m₁ ≤ m₂) : applySubnetMask (applySubnetMask ip m₁ ) m₂ = applySubnetMask ip m₁ := by
  simp only [mask_composition]
  have hmin := SubnetMask.min_eq_left h
  rw [hmin]


theorem right_mask_composition_of_le {ip : IP} {m₁ m₂ : SubnetMask} (h : m₁ ≤ m₂) : applySubnetMask (applySubnetMask ip m₂) m₁ = applySubnetMask ip m₁ := by
  simp only [mask_composition]
  have hmin := SubnetMask.min_eq_right h
  rw [hmin]

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


--TODO: cleanup
@[simp]
lemma mask_and_delta_disjoint_lt {w : Nat} {m n : Nat} (hm: m < n) (hnw : n < w) : BitVec.allOnes w <<< (w - m) &&& BitVec.ofNat w 1 <<< (w - n) = 0 := by
  ext i hi
  rw [BitVec.getElem_and]
  rw [BitVec.ofNat_eq_ofNat, BitVec.getElem_zero]
  rw [one_hot_decide, mask_vec_decide]
  rw [←Bool.decide_and]
  rw [decide_eq_false_iff_not]
  rw [not_and]
  intro h
  have hmw : m < w := Nat.lt_trans hm hnw
  have hmnw : w - n < w - m := Nat.sub_lt_sub_left hmw hm
  have hneq := Ne.symm $ Nat.ne_of_lt $ Nat.lt_of_lt_of_le hmnw h
  rw [←ne_eq]
  exact hneq

lemma mask_and_delta_disjoint_le {w : Nat} {m n : Nat} (hm: m < n) (hnw : n ≤ w) : BitVec.allOnes w <<< (w - m) &&& BitVec.ofNat w 1 <<< (w - n) = 0 := by
  by_cases h : n = w
  · replace hnw := h
    rw [hnw]
    clear h
    ext i hi
    rw [BitVec.getElem_and]
    rw [BitVec.ofNat_eq_ofNat, BitVec.getElem_zero]
    rw [one_hot_decide, mask_vec_decide]
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


lemma mask_vec_cancel (mask₁ mask₂ : SubnetMask) : mask₁ = mask₂ ↔ maskVec mask₁ = maskVec mask₂ := by
  constructor

  intro h
  rw [h]

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


theorem mem_subnet_iff_mask_eq
  (ip a : IP) (m : SubnetMask) :
  ip ∈ subnet a m ↔ applySubnetMask a m = applySubnetMask ip m :=
    ⟨by intro h; exact h.symm, by intro h; exact h.symm⟩


theorem subnet_align_base {a b : IP} {m : SubnetMask}
    (hb : b ∈ subnet a m) :
  subnet a m = subnet b m := by
  rw [←extensionality]
  intro x
  repeat rw [mem_subnet_iff_mask_eq]
  repeat rw [mem_subnet_iff_mask_eq] at hb
  constructor
  · intro h; rw [←hb]; exact h
  · intro h; rw [hb]; exact h

theorem subnet_contains_self
  (a : IP) (m : SubnetMask) :
  applySubnetMask a m ∈ subnet a m := by
  have h : m ≤ m := by simp [SubnetMask.eq_impl_le]
  exact apply_absorb_left_of_le h

lemma mask_delta_drop {m₁ m₂ : SubnetMask}
    (h : m₁ < m₂) :
  applySubnetMask (delta m₂) m₁ = 0 := by
  simp only [applySubnetMask, delta, maskVec]
  rw [BitVec.and_eq]
  rw [BitVec.and_comm]
  exact mask_and_delta_disjoint_le h (m₂.property.right)


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


theorem subnet_subset_width {a : IP} {m₁ m₂ : SubnetMask} :
  subnet a m₁ ⊆ subnet a m₂ ↔ m₂ ≤ m₁ := by
  constructor
  intro h
  contrapose h
  replace h : m₁ < m₂ := Nat.lt_of_not_le h
  let δ := (BitVec.ofNat 32 1 <<< ((32 - m₂ : ℕ)))
  have h' : applySubnetMask (a ^^^ δ) m₁ = applySubnetMask a m₁ := by
    repeat rw [applySubnetMask]
    rw [BitVec.and_eq]
    rw [maskVec]
    rw [bitvec_and_xor_distrib_right]
    nth_rw 2 [BitVec.and_comm]
    rw [mask_and_delta_disjoint_le h m₂.property.right]
    --TODO: refine simp
    rw [BitVec.ofNat_eq_ofNat]
    rw [BitVec.xor_zero]
    rw [BitVec.and_eq]

  have h'' : applySubnetMask (a ^^^ δ) m₂ ≠ applySubnetMask a m₂ := by
    apply flip_inside_prefix_imp_ne
    exists 32 - m₂
    have hlt : 32 - (m₂ : ℕ)  < 32 := by
      have : 0 < (m₂: ℕ) := lt_of_le_of_lt m₁.property.left h
      exact Nat.sub_lt (by decide) this
    exists hlt
    exists by rfl
    apply mt (bit_xor_decide hlt).mp
    rw [Bool.not_eq_false]
    simp [δ]
  have hmem₁ : (a ^^^ δ) ∈ subnet a m₁ := by
    simp only [mem_subnet_iff_mask_eq]
    exact h'.symm
  have hmem₂ : (a ^^^ δ) ∉ subnet a m₂ := by
    simp only [mem_subnet_iff_mask_eq, ←ne_eq]
    exact h''.symm
  simp only [Set.subset_def, Classical.not_forall]
  exact ⟨a ^^^ δ, ⟨hmem₁, hmem₂⟩⟩


  intro h
  simp only [Set.subset_def]
  intros x hx
  simp_all only [mem_subnet_iff_mask_eq]
  replace hx := congrArg (λ ip => applySubnetMask ip m₂) hx
  simp only [] at hx
  repeat rw [right_mask_composition_of_le h] at hx
  exact hx


--TODO: comment and clean up
theorem subnet_containement {a b : IP} {m₁ m₂ : SubnetMask} :
  (subnet a m₁) ⊆ (subnet b m₂) ↔ (m₂ ≤ m₁ ∧ applySubnetMask a m₂ = applySubnetMask b m₂) := by
  constructor

  intro h
  simp only [Set.subset_def, mem_subnet_iff_mask_eq] at h
  constructor
  contrapose h
  rw [Classical.not_forall]
  let δ := (1#32 <<< ((32 - m₂ : ℕ)))
  exists a ^^^ (~~~(a ^^^ b) &&& δ)
  replace h := Nat.not_le.mp h

  rw [Classical.not_imp]
  constructor
  simp only [applySubnetMask, maskVec, BitVec.and_eq]

  set M₁ : BitVec 32 := BitVec.allOnes 32 <<< (32 - ↑m₁) with hM₁
  set δ  : BitVec 32 := (1#32) <<< (32 - ↑m₂) with hδ
  set X  : BitVec 32 := (~~~(a ^^^ b)) &&& δ with hX

  have hδ0 : δ &&& M₁ = 0 := by
    rw [BitVec.and_comm]
    exact mask_and_delta_disjoint_le h m₂.property.right

  have hX0 : X &&& M₁ = 0 := by
    unfold X
    rw [BitVec.and_assoc]
    rw [hδ0]
    simp only [BitVec.ofNat_eq_ofNat]
    rw [BitVec.and_zero]

  have hx : ((a ^^^ X) &&& M₁) = (a &&& M₁) ^^^ (X &&& M₁) := by
    rw [←bitvec_and_xor_distrib_right]

  calc
    a &&& M₁
        = (a &&& M₁) ^^^ 0 := by simp
    _   = (a &&& M₁) ^^^ (X &&& M₁) := by simp [hX0]
    _   = ((a ^^^ X) &&& M₁) := by simp [hx]
    _   = ((a ^^^ ((~~~(a ^^^ b)) &&& δ)) &&& M₁) := by simp [hX]

  apply ne_of_exists_ne_bit
  simp only [applySubnetMask, maskVec, BitVec.and_eq]
  simp only [BitVec.getElem_and, mask_vec_decide, δ, delta_decide, BitVec.getElem_xor, BitVec.getElem_not]
  exists (32 - m₂)
  have hs : 0 < 32 := by decide
  have hgez : 0 < (m₂ : ℕ) := Nat.lt_of_le_of_lt m₁.property.left h
  exists (Nat.sub_lt (n:=32) (by decide) hgez)
  simp only [ge_iff_le, le_refl, decide_true, Bool.and_true, Bool.bne_not, Bool.bne_self_left,
    ne_eq, Bool.eq_not_self, not_false_eq_true]


  replace h := h a
  rw [eq_comm]
  apply h
  rfl

  --TODO: refactor into separate wording of width lemma
  intro h
  simp only [Set.subset_def, mem_subnet_iff_mask_eq]
  rw [←h.right]
  simp only [←mem_subnet_iff_mask_eq, ←Set.subset_def]
  exact subnet_subset_width.mpr h.left

#eval (ipFromDecimal
  (IPDecimalBlock.mk 123)
  (IPDecimalBlock.mk 64)
  (IPDecimalBlock.mk 33)
  (IPDecimalBlock.mk 13) >
  ipFromDecimal
  (IPDecimalBlock.mk 123)
  (IPDecimalBlock.mk 64)
  (IPDecimalBlock.mk 33)
  (IPDecimalBlock.mk 12))
