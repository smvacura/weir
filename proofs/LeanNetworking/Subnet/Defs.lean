import Mathlib.Data.Finset.Max

import LeanNetworking.Mask.Defs
import LeanNetworking.Mask.BitVec
import LeanNetworking.Mask.Theorems


/-- Definition of a subnet. A subnet is a set with `ϕ(x) = the subnet mask
  formed with x and m is equal to the subnet mask formed with a and m`, with
  `a, m` being parameters-/
def subnet (a : IP) (m : SubnetMask) : Set IP :=
  {ip | applySubnetMask ip m = applySubnetMask a m}


instance {a : IP} {m : SubnetMask} : DecidablePred (·  ∈ subnet a m) :=
  fun ip => BitVec.decEq (applySubnetMask ip m) (applySubnetMask a m)

instance {a : IP} {m : SubnetMask} : Fintype (subnet a m) := inferInstance

theorem all_subnets_nonempty {a : IP} {m : SubnetMask} :
  Set.Nonempty (subnet a m) := by
  unfold Set.Nonempty
  apply Exists.intro a
  rfl

theorem all_fin_subnets_nonempty {a : IP} {m : SubnetMask} :
  (Set.toFinset (subnet a m)).Nonempty := by
  simp_all only [Set.toFinset_nonempty]
  exact all_subnets_nonempty

lemma ip_in_subnet_imp_in_finset {a ip : IP} {m : SubnetMask} :
  ip ∈ subnet a m -> ip ∈ Set.toFinset (subnet a m) := by

  intro h
  exact Set.mem_toFinset.mpr h

/-- The size of a subnet is `2^n`, where `n` is the length of the host portion-/
def subnetSize (mask : SubnetMask) := 2^(32-mask.val)


def sameSubnet {a b : IP} {m₁ m₂ : SubnetMask} : Prop :=
  ∀ ip : IP,
  applySubnetMask ip m₁ = applySubnetMask a m₁ ↔
  applySubnetMask ip m₂ = applySubnetMask b m₂


def subnetUpperBound (a : IP) (m : SubnetMask) : IP :=
  let fin_subnet := (subnet a m).toFinset
  Finset.max' fin_subnet (all_fin_subnets_nonempty)

def subnetLowerBound (a : IP) (m : SubnetMask) : IP :=
  let fin_subnet := (subnet a m).toFinset
  Finset.min' fin_subnet (all_fin_subnets_nonempty)

def overlappingSubnets (a b : IP) (m₁ m₂ : SubnetMask) : Prop :=
  ∃ ip : IP,
  ip ∈ subnet a m₁ ∧
  ip ∈ subnet b m₂


def covers (range : Set IP) (subnets : List (Set IP)) :=
  ∀ip ∈ range, ∃ s ∈ subnets, ip ∈ s
