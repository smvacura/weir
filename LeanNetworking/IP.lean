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
  ((BitVec.allOnes w <<< m)[i]) = decide (i ≥ m) := by
  simp_all only [BitVec.getElem_shiftLeft, BitVec.getElem_allOnes, Bool.and_true, ge_iff_le, Bool.not_eq_eq_eq_not]
  simp [←decide_not]

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


theorem subnet_subset_width {a : IP} {m₁ m₂ : SubnetMask} :
  subnet a m₁ ⊆ subnet a m₂ ↔ m₂ ≤ m₁ := by
  sorry

-- theorem subnet_containement
--   (a b : IP) (m₁ m₂ : SubnetMask) :
--   (subnet a m₁) ⊆ (subnet b m₂) ↔ (m₂ ≤ m₁ ∧ applySubnetMask a m₂ = applySubnetMask b m₂) := by
--   constructor
--   intro h
--   constructor
--   unfold _root_.Subset at h
--   have hx : subnet a m₁ a := by
--   -- show that the base address `a` is in its own subnet
--     simp [subnet, applySubnetMask]
--   have hₜ := h hx
--   have x := a
--   have h₂ : applySubnetMask a m₁ = applySubnetMask a m₁ := by rfl


--   sorry
--   have s₁ := subnet a m₁
--   have s₂ := subnet b m₂
--   have ha_mem : a ∈ subnet a m₁ := by
--   -- a ∈ {x | mask x m₁ = mask a m₁}
--     simp [mem_subnet_iff_mask_eq]
--   have hb_mem : a ∈ subnet b m₂ := h ha_mem
--   have hmask : applySubnetMask a m₂ = applySubnetMask b m₂ := by
--     simpa [mem_subnet_iff_mask_eq, eq_comm] using hb_mem
--   exact hmask

--   sorry


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
