import Init.Data.BitVec.Lemmas
import LeanNetworking.Subnet.Defs

open BitVecUtil


/-- An IP is a member of the subnet determined by `a, m` iff applying `m` to `ip` yields the same results
 as applying `m` to `a`-/
lemma mem_subnet {a m ip} : (ip ∈ subnet a m) ↔ applySubnetMask ip m = applySubnetMask a m := Iff.rfl


/-- An IP is a member of the subnet determined by `a, m` iff applying `m` to `ip` yields the same results
 as applying `m` to `a`-/
theorem mem_subnet_iff_mask_eq
  (ip a : IP) (m : SubnetMask) :
  ip ∈ subnet a m ↔ applySubnetMask a m = applySubnetMask ip m :=
    ⟨by intro h; exact h.symm, by intro h; exact h.symm⟩


/-- Conversion between subnet equality and the sameSubnet prop-/
theorem subnet_eq_iff_same_subnet {a b : IP} {m₁ m₂ : SubnetMask} :
  subnet a m₁ = subnet b m₂ ↔ sameSubnet (a:=a) (b:=b) (m₁:=m₁) (m₂:=m₂) := by

  apply Iff.intro
  -- (→) subnet a m₁ = subnet b m₂ → sameSubnet
  unfold sameSubnet
  intro h ip
  have h_ip := congrArg (fun S => ip ∈ S) h
  simp [] at h_ip
  repeat rw [mem_subnet_iff_mask_eq] at h_ip
  nth_rw 1 [eq_comm]
  nth_rw 2 [eq_comm]
  exact h_ip

  -- (←) sameSubnet → subnet a m₁ = subnet b m₂
  unfold sameSubnet
  intro h
  apply Set.ext
  intro ip
  repeat rw [mem_subnet_iff_mask_eq]
  nth_rw 1 [eq_comm]
  nth_rw 2 [eq_comm]
  apply h


/-- If `b` is in the subnet defined by `a, m`, the subnet formed by `b, m` must be equal
  to the subnet defined by `a, m`-/
theorem subnet_align_base {a b : IP} {m : SubnetMask}
    (hb : b ∈ subnet a m) :
  subnet a m = subnet b m := by
  apply Set.ext
  intro x
  repeat rw [mem_subnet_iff_mask_eq]
  repeat rw [mem_subnet_iff_mask_eq] at hb
  apply Iff.intro
  · intro h; rw [←hb]; exact h
  · intro h; rw [hb]; exact h


/-- The IP formed by applying `m` to `a` is a member of the subnet defined by `a, m`-/
theorem subnet_contains_self
  (a : IP) (m : SubnetMask) :
  a ∈ subnet a m := by
  unfold subnet
  simp only [Set.mem_setOf_eq]


theorem base_is_lowest
  {a ip : IP} {m : SubnetMask} :
  ip ∈ subnet a m → applySubnetMask a m ≤ ip := by

  simp only [mem_subnet]
  intro h
  rw [←h]
  simp only [applySubnetMask_le]



/-- Subnet subsets with the same base `a` implies the subset mask is lesser than the superset mask-/
theorem subnet_subset_width {a : IP} {m₁ m₂ : SubnetMask} :
  subnet a m₁ ⊆ subnet a m₂ ↔ m₂ ≤ m₁ := by
  apply Iff.intro
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


/-- Subnet α ⊆ Subnet β means the mask of β must be less specific than that of α,
  and both subnets have the same base up to β  -/
theorem subnet_containement {a b : IP} {m₁ m₂ : SubnetMask} :
  (subnet a m₁) ⊆ (subnet b m₂) ↔ (m₂ ≤ m₁ ∧ applySubnetMask a m₂ = applySubnetMask b m₂) := by
  apply Iff.intro

  intro h
  simp only [Set.subset_def, mem_subnet_iff_mask_eq] at h
  apply And.intro
  contrapose h
  rw [Classical.not_forall]
  let δ := (1#32 <<< ((32 - m₂ : ℕ)))
  exists a ^^^ (~~~(a ^^^ b) &&& δ)
  replace h := Nat.not_le.mp h

  rw [Classical.not_imp]
  apply And.intro
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


/-- Subnet subsets work the same as set subsets w.r.t. antisymmetry-/
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


/-- A specialized corollary from `subnet_containment`-- if two subnets are equal,
  their masks are equal and their bases are equal up to the common mask `m`-/
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

lemma lower_bound_in_subnet {a : IP} {m : SubnetMask} :
  subnetLowerBound a m ∈ subnet a m := by

  simp only [subnetLowerBound]
  apply Set.mem_toFinset.mp
  apply Finset.min'_mem


lemma upper_bound_in_subnet {a : IP} {m : SubnetMask} :
  subnetUpperBound a m ∈ subnet a m := by

  simp only [subnetUpperBound]
  apply Set.mem_toFinset.mp
  apply Finset.max'_mem


lemma ip_in_subnet_imp_ge_lower {a ip : IP} {m₁ : SubnetMask} :
  ip ∈ subnet a m₁ → subnetLowerBound a m₁ ≤ ip := by

  intro h
  simp only [subnetLowerBound]
  rw [←Set.mem_toFinset] at h
  apply Finset.min'_le
  exact h


lemma ip_in_subnet_imp_le_upper {a ip : IP} {m₁ : SubnetMask} :
  ip ∈ subnet a m₁ → ip ≤ subnetUpperBound a m₁ := by

  intro h
  simp only [subnetUpperBound]
  rw [←Set.mem_toFinset] at h
  apply Finset.le_max'
  exact h


lemma subnet_eq_imp_lower_bound_eq {a b : IP} {m₁ m₂ : SubnetMask} :
  subnet a m₁ = subnet b m₂ → subnetLowerBound a m₁ = subnetLowerBound b m₂ := by

  intro h
  apply le_antisymm
  · apply Finset.min'_le
    rw [Set.mem_toFinset, h]
    exact lower_bound_in_subnet
  · apply Finset.min'_le
    rw [Set.mem_toFinset, ←h]
    exact lower_bound_in_subnet


lemma subnet_eq_imp_upper_bound_eq {a b : IP} {m₁ m₂ : SubnetMask} :
  subnet a m₁ = subnet b m₂ → subnetUpperBound a m₁ = subnetUpperBound b m₂ := by

  intro h
  apply le_antisymm
  · apply Finset.le_max'
    rw [Set.mem_toFinset, ←h]
    exact upper_bound_in_subnet
  · apply Finset.le_max'
    rw [Set.mem_toFinset, h]
    exact upper_bound_in_subnet

lemma base_ge_lower_bound {a : IP} {m : SubnetMask} :
  subnetLowerBound a m ≤ a := by

  simp only [subnetLowerBound]
  have hin := ip_in_subnet_imp_in_finset (subnet_contains_self a m)
  apply Finset.min'_le
  exact hin

lemma base_le_upper_bound {a : IP} {m : SubnetMask} :
  a ≤ subnetUpperBound a m := by

  simp only [subnetUpperBound]
  have hin := ip_in_subnet_imp_in_finset (subnet_contains_self a m)
  apply Finset.le_max'
  exact hin

lemma lower_bound_is_base {a : IP} {m : SubnetMask} :
  subnetLowerBound a m = applySubnetMask a m := by

  simp only [subnetLowerBound]
  apply le_antisymm
  · apply Finset.min'_le
    apply Set.mem_toFinset.mpr
    simp only [mem_subnet]
    apply mask_idempotence
  · apply Finset.le_min'
    intro y h
    replace h := Set.mem_toFinset.mp h
    exact base_is_lowest h


lemma TODO_NAME_LATER_2 {a : IP} {m : SubnetMask} :
  applySubnetMask a m ||| ~~~maskVec m = a ||| ~~~maskVec m := by

  rw [applySubnetMask]
  rw [BitVec.and_eq]
  rw [BitVecUtil.bitvec_or_and_distrib_right]
  rw [BitVec.or_not_self]
  rw [BitVec.and_allOnes]


lemma TODO_NAME_LATER {a ip : IP} {m : SubnetMask}:
  ip ∈ subnet a m → ip ≤ a ||| ~~~maskVec m := by
  rw [← TODO_NAME_LATER_2]
  intro h
  simp only [mem_subnet] at h
  rw [← h]
  have hle := applySubnetMask_le (ip:=ip) (m:=m)
  rw [applySubnetMask]
  rw [BitVec.and_eq]
  rw [BitVec.and_comm]
  rw [bitvec_or_and_distrib_right]
  nth_rw 2 [BitVec.or_comm]
  rw [BitVec.or_not_self]
  rw [BitVec.and_comm]
  rw [BitVec.and_allOnes]
  rw [BitVec.or_comm]
  simp only [applyMaskInverse_ge]



lemma upper_bound_is_network_prefix {a : IP} {m : SubnetMask} :
  subnetUpperBound a m = a ||| ~~~(maskVec m):= by

  simp only [subnetUpperBound]
  apply le_antisymm
  · apply Finset.max'_le
    intro y h
    replace h := Set.mem_toFinset.mp h
    exact TODO_NAME_LATER h
  · apply Finset.le_max'
    apply Set.mem_toFinset.mpr
    simp only [mem_subnet]
    rw [applySubnetMask]
    rw [BitVec.and_eq]
    rw [bitvec_and_or_distrib_right]
    nth_rw 2 [BitVec.and_comm]
    rw [BitVec.and_not_self]
    rw [BitVec.or_comm]
    show (0#32) ||| a &&& maskVec m = applySubnetMask a m
    rw [BitVec.zero_or]
    rfl


theorem bounds_same_prefix {a : IP} {m : SubnetMask} {i : Nat}
    (hi : i < 32) (hm : i ≥ 32 - m) :
    (subnetLowerBound a m)[i] = (subnetUpperBound a m)[i] := by
    rw [lower_bound_is_base]
    rw [upper_bound_is_network_prefix]
    rw [applyMask_high_bits_preserved]
    rw [network_prefix_high_bits_preserved]
    exact hm
    exact hm


theorem subnet_eq_interval (a : IP) (m : SubnetMask) :
  subnet a m = Set.Icc (subnetLowerBound a m) (subnetUpperBound a m) := by
  unfold Set.Icc
  unfold subnet
  apply Set.ext
  intro x
  simp only [Set.mem_setOf_eq]
  show applySubnetMask x m = applySubnetMask a m ↔ subnetLowerBound a m ≤ x ∧ x ≤ subnetUpperBound a m

  apply Iff.intro
  intro h
  apply And.intro
  · have hmask : m = m := by rfl
    replace h : subnet a m = subnet x m := subnet_eq_iff_mask_network_eq.mpr (And.intro h.symm hmask)
    rw [subnet_eq_imp_lower_bound_eq h]
    exact base_ge_lower_bound
  · have hmask : m = m := by rfl
    replace h : subnet a m = subnet x m := subnet_eq_iff_mask_network_eq.mpr (And.intro h.symm hmask)
    rw [subnet_eq_imp_upper_bound_eq h]
    exact base_le_upper_bound

  intro h
  rcases h with ⟨hlow, hup⟩

  ext i hi

  by_cases hm : i ≥ 32 - m
  · have ha := (bitvec_squeeze hlow hup hi)
    have hsqueeze := bounds_same_prefix hi hm (a:=a)
    have h' := ha hsqueeze
    rw [lower_bound_is_base] at h'
    rw [←applyMask_high_bits_preserved (ip:=x) (m:=m)] at h'
    exact h'.symm
    exact hm
  · replace hm : i < 32 - m := by
      simp only [ge_iff_le, Nat.sub_le_iff_le_add, not_le] at hm
      rw [Nat.lt_sub_iff_add_lt]
      exact hm
    repeat rw [applyMask_low_bits_zeroed]
    exact hm
    exact hm









theorem subnet_mem_iff_bounds (ip a : IP) (m : SubnetMask) :
  ip ∈ subnet a m ↔ subnetLowerBound a m ≤ ip ∧ ip ≤ subnetUpperBound a m := by

  rw [subnet_eq_interval, Set.mem_Icc]
