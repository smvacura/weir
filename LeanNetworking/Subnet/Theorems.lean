import LeanNetworking.Subnet.Defs

lemma mem_subnet {a m ip} : (ip ∈ subnet a m) ↔ applySubnetMask ip m = applySubnetMask a m := Iff.rfl

theorem mem_subnet_iff_mask_eq
  (ip a : IP) (m : SubnetMask) :
  ip ∈ subnet a m ↔ applySubnetMask a m = applySubnetMask ip m :=
    ⟨by intro h; exact h.symm, by intro h; exact h.symm⟩


theorem subnet_align_base {a b : IP} {m : SubnetMask}
    (hb : b ∈ subnet a m) :
  subnet a m = subnet b m := by
  apply Set.ext
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

theorem subnet_subset_width {a : IP} {m₁ m₂ : SubnetMask} :
  subnet a m₁ ⊆ subnet a m₂ ↔ m₂ ≤ m₁ := by
  constructor
  intro h
  contrapose h
  replace h : m₁ < m₂ := Nat.lt_of_not_le h
  let δ := (BitVec.ofNat 32 1 <<< ((32 - m₂ : ℕ)))
  have heq_m1 : applySubnetMask (a ^^^ δ) m₁ = applySubnetMask a m₁ := by
    --TODO: maybe replace by calc
    repeat rw [applySubnetMask]
    rw [BitVec.and_eq]
    rw [maskVec]
    rw [bitvec_and_xor_distrib_right]
    nth_rw 2 [BitVec.and_comm]
    rw [mask_and_delta_disjoint_le h m₂.property.right]
    rw [BitVec.ofNat_eq_ofNat]
    rw [BitVec.xor_zero]
    rw [BitVec.and_eq]

  have hneq_m2 : applySubnetMask (a ^^^ δ) m₂ ≠ applySubnetMask a m₂ := by
    apply flip_inside_prefix_imp_ne
    exists 32 - m₂
    have hlt : 32 - (m₂ : ℕ)  < 32 := by
      have : 0 < (m₂: ℕ) := lt_of_le_of_lt m₁.property.left h
      exact Nat.sub_lt (by decide) this
    exists hlt
    exists by rfl
    apply mt (bit_xor_decide hlt).mp
    rw [Bool.not_eq_false]
    simp only [δ, delta_decide, decide_true]
  have hmem_m1 : (a ^^^ δ) ∈ subnet a m₁ := by
    simp only [mem_subnet_iff_mask_eq]
    exact heq_m1.symm
  have hmem_m2 : (a ^^^ δ) ∉ subnet a m₂ := by
    simp only [mem_subnet_iff_mask_eq, ←ne_eq]
    exact hneq_m2.symm
  simp only [Set.subset_def, Classical.not_forall]
  exact ⟨a ^^^ δ, ⟨hmem_m1, hmem_m2⟩⟩


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

theorem subnet_antisymm {a b : IP} {m₁ m₂ : SubnetMask} :
  subnet a m₁ ⊆ subnet b m₂ ∧  subnet b m₂ ⊆ subnet a m₁ ↔
  subnet a m₁ = subnet b m₂ := by

  apply Iff.intro

  -- subnet a m₁ ⊆ subnet b m₂ ∧ subnet b m₂ ⊆ subnet a m₁ → subnet a m₁ = subnet b m₂
  intro ⟨ha, hb⟩

  ext x
  apply Iff.intro

  -- case x ∈ subnet a m₁
  · intro h
    exact ha h
  -- case x ∈ subnet b m₂
  · intro h
    exact hb h

  -- case subnet a m₁ = subnet b m₂ → subnet a m₁ ⊆ subnet b m₂ ∧ subnet b m₂ ⊆ subnet a m₁
  intro heq
  simp_all only [subset_refl, and_self]

theorem subnet_eq_iff_mask_network_eq {a b : IP} {m₁ m₂ : SubnetMask} :
  subnet a m₁ = subnet b m₂ ↔ applySubnetMask a m₁ = applySubnetMask b m₂ ∧ m₁ = m₂ := by

  apply Iff.intro
  -- case mp: subnet a m₁ = subnet a m₂ → a = b ∧ m₁ = m₂
  intro heq

  rw [←subnet_antisymm] at heq
  rcases heq with ⟨ha, hb⟩
  replace ha := subnet_containement.mp ha
  rcases ha with ⟨ham, haip⟩
  replace hb := subnet_containement.mp hb
  rcases hb with ⟨hbm, hbip⟩

  have heq := (mask_le_antisymm ham hbm).symm
  nth_rewrite 1 [heq] at hbip
  exact ⟨hbip.symm, heq⟩

  -- case applySubnetMask a m₁ = applySubnetMask b m₂ ∧ m₁ = m₂ → subnet a m₁ = subnet b m₂
  intro ⟨hip, hmask⟩
  -- extentionality: S₁ ⊆ S₂ → ∀x ∈ S₁, x ∈ S₂
  ext x

  apply Iff.intro

  --case  x ∈ subnet a m₁ → x ∈ subnet b m₂
  repeat rw [mem_subnet_iff_mask_eq]
  intro ha
  rw [hip] at ha
  nth_rw 2 [hmask.symm]
  exact ha

  --case x ∈ subnet b m₂ → x ∈ subnet a m₁
  repeat rw [mem_subnet_iff_mask_eq]
  intro hb
  rw [hip.symm] at hb
  nth_rw 2 [hmask]
  exact hb
