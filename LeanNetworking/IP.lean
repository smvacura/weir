import Std.Tactic.BVDecide

macro "lemma" n:declId sig:declSig val:declVal : command =>
  `(theorem $n:declId $sig:declSig $val:declVal)

abbrev Set (α : Type u) := α → Prop

notation:50 x:51 " ∈ " S:51 => S x

def Subset {α : Type u} (A B : Set α) :=
  ∀ {x : α}, x ∈ A → x ∈ B

infix:50 " ⊆ " => Subset

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




instance : LT SubnetMask where
  lt a b := a.val < b.val

instance : LE SubnetMask where
  le a b := a.val ≤ b.val

lemma eq_impl_le (m₁ m₂ : SubnetMask) :
  m₁ = m₂ → m₁ ≤ m₂ := by
  intro h
  simp [SubnetMask.instLE]
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
  rw [←Nat.min_eq_min]
  simp [Nat.min_eq_left h]

theorem min_eq_right {m₁ m₂ : SubnetMask} (h : m₂ ≤ m₁) : SubnetMask.min m₁ m₂ = m₂ := by
  rw [SubnetMask.min, SubnetMask.mk]
  apply Subtype.ext
  simp [min_val_32_eq_val]
  rw [←Nat.min_eq_min]
  simp [Nat.min_eq_right h]

lemma name_later {m n k : Nat} (h₁ : m ≤ k) (h₂ : n ≤ k) : Min.min m n ≤ k := by
  by_cases hmn : m ≤ n
  · rw [Nat.min_eq_left hmn]; exact h₁;
  · rw [Nat.not_le] at hmn; have hnm := Nat.le_of_lt hmn; rw [Nat.min_eq_right hnm]; exact h₂


theorem mask_min_le_32 {m₁ m₂ : SubnetMask} : (SubnetMask.min m₁ m₂).val ≤ 32 := by
  simp [SubnetMask.min, SubnetMask.mk, SubnetMask.min_val_32_eq_val]
  apply name_later m₁.property.right m₂.property.right


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

lemma mask_zero_index_lt_32 (m : SubnetMask) (h : 0 < m.val): m.val - 1 < 32 := by
  rw [Nat.sub_lt_iff_lt_add]
  · simp; rw [Nat.lt_succ_iff]; exact m.property.right
  · exact Nat.succ_le.mpr h

@[simp]
theorem allOnes_bit (m : SubnetMask) (h : 0 < m.val):
  (BitVec.allOnes 32)[m.val - 1]'(mask_zero_index_lt_32 m h) = true := by
  simp
  sorry

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


lemma maskVec_bit {m i} (h : i < 32) :
  ((BitVec.allOnes 32 <<< (32 - m))[i]'h) = decide (i ≥ 32 - m) := by
  simp
  sorry


@[simp]
theorem maskVec_and_eq_maskVec_min (mask₁ mask₂ : SubnetMask) : (maskVec mask₁) &&& (maskVec mask₂) = maskVec (SubnetMask.min mask₁ mask₂) := by
  simp  only [maskVec]
  rw [SubnetMask.min_val, Nat.min_eq_min]
  have h₁ := mask₁.property
  have h₂ := mask₂.property
  generalize hk₁ : 32 - mask₁.val = k₁
  generalize hk₂ : 32 - mask₂.val = k₂
  generalize hkₘ : 32 - Nat.min mask₁.val mask₂.val = kₘ
  sorry


lemma test (x : Nat) (h : x > 0) : (BitVec.allOnes 1) <<< 1 = 0#1 := by
  bv_decide




def sameSubnet (ip₁ ip₂ : IP) (mask : SubnetMask) : Prop :=
  applySubnetMask ip₁ mask = applySubnetMask ip₂ mask


def Subnet ip₁ mask := {ip₂ // sameSubnet ip₁ ip₂ mask}

def subnet (a : IP) (m : SubnetMask) : Set IP :=
  fun ip => applySubnetMask ip m = applySubnetMask a m


def subnetSize (mask : SubnetMask) := 2^(32-mask.val)




theorem mask_composition (ip : IP) (mask₁ mask₂ : SubnetMask) : applySubnetMask (applySubnetMask ip mask₁ ) mask₂ = applySubnetMask ip (SubnetMask.min mask₁ mask₂) := by
  simp only [applySubnetMask, maskVec]
  repeat rw [BitVec.and_self]
  repeat rw [BitVec.and_eq]
  have h₁ := mask₁.property
  have h₂ := mask₂.property
  sorry

lemma mask_vec_get (m : SubnetMask) (i : Fin 32): (maskVec m).getLsbD i = decide (i < m.val) := by
  simp
  sorry


-- lemma mask_vec_cancel (mask₁ mask₂ : SubnetMask) : mask₁ = mask₂ ↔ maskVec mask₁ = maskVec mask₂ := by
--   constructor

--   intro h
--   have h₁ : maskVec mask₁ = maskVec mask₂ := by rw [h]
--   exact h₁

--   intro h
--   apply Subtype.ext
--   have h₁ := mask₁.property.right
--   have h₂ := mask₂.property.right
--   cases Nat.eq_or_lt_of_le h₁ with
--   | inl heq₁ =>
--     rw [heq₁]
--     cases Nat.eq_or_lt_of_le h₂ with
--     | inl heq₂ =>
--       exact heq₂.symm
--     | inr hlt₂ =>
--       let i : Fin 32 := ⟨mask₂.val, hlt₂⟩
--       have hi :
--         (maskVec mask₁).getLsbD i = (maskVec mask₂).getLsbD i := by
--         rw [h]
--       have : False := by
--         simp [maskVec, i, heq₁, hlt₂] at hi
--       contradiction
--   | inr hlt₁ =>
--     cases Nat.eq_or_lt_of_le h₂ with
--     | inl heq₂ =>
--       let i : Fin 32 := ⟨mask₁.val, hlt₁⟩
--       have hi :
--         (maskVec mask₁).getLsbD i = (maskVec mask₂).getLsbD i := by
--         rw [h]
--       have : False := by
--         simp [maskVec, i, heq₂, hlt₁] at hi
--       contradiction
--     | inr hlt₂ =>
--       let i : Fin 32 := ⟨mask₁.val, hlt₁⟩
--       have hi : BitVec.getLsbD (maskVec mask₁) i
--           = BitVec.getLsbD (maskVec mask₂) i := by
--           rw [h]
--       simp [maskVec, i, hlt₁] at hi
--       let j : Fin 32 := ⟨mask₂.val, hlt₂⟩
--       have hj : BitVec.getLsbD (maskVec mask₂) j
--           = BitVec.getLsbD (maskVec mask₁) j := by
--           rw [h]
--       simp [maskVec, j, hlt₂] at hj
--       have h' := Nat.le_antisymm hi hj
--       exact h'.symm


theorem mask_vec_left_absorb_of_le
  {m₁ m₂ : SubnetMask} (h : m₁ ≤ m₂):
  maskVec m₁ &&& maskVec m₂ = maskVec m₁ := by
  sorry


lemma mask_vec_right_absorb_of_le
  {m₁ m₂ : SubnetMask} (h : m₁ ≤ m₂) :
  maskVec m₂ &&& maskVec m₁ = maskVec m₁ := by
  rw [BitVec.and_comm]
  rw [mask_vec_left_absorb_of_le h]


theorem apply_absorb_left_of_le
  {ip : IP} {m₁ m₂ : SubnetMask} (h : m₁ ≤ m₂) :
  applySubnetMask (applySubnetMask ip m₁) m₂ = applySubnetMask ip m₁ := by
  simp only [mask_composition]
  rw [SubnetMask.min_eq_left h]


theorem apply_absorb_right_of_le
  {ip : IP} {m₁ m₂ : SubnetMask} (h : m₁ ≤ m₂) :
  applySubnetMask (applySubnetMask ip m₂) m₁ = applySubnetMask ip m₁ := by
  simp only [mask_composition]
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
  simp only [subnet]
  have h : m ≤ m := by simp [SubnetMask.eq_impl_le]
  exact apply_absorb_left_of_le h

lemma mask_delta_drop {a : IP} {m₁ m₂ : SubnetMask}
    (h : m₁ < m₂) :
  applySubnetMask (delta m₂) m₁ = 0 := by
  unfold applySubnetMask delta maskVec
  sorry




lemma witness_between_prefixes {a : IP} {m₁ m₂ : SubnetMask} :
  m₁ < m₂ → ∃x, applySubnetMask x m₁ = applySubnetMask a m₁ ∧ applySubnetMask x m₂ ≠ applySubnetMask a m₂ := by
  intro h
  have x := (applySubnetMask a m₁) ^^^ delta m₂
  exists x
  constructor
  · sorry
  · sorry




theorem subnet_subset_width {a : IP} {m₁ m₂ : SubnetMask} :
  subnet a m₁ ⊆ subnet a m₂ ↔ m₂ ≤ m₁ := by
  constructor
  unfold _root_.Subset
  intro h
  apply Classical.byContradiction
  intro not_m2_le_m1
  have m1_lt_l2 : m₁ < m₂ := by exact SubnetMask.lt_of_not_le not_m2_le_m1
  unfold subnet at h
  simp only [applySubnetMask] at h
  sorry
  intro h
  unfold _root_.Subset
  intros x ha
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
