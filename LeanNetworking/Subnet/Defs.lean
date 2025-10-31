import LeanNetworking.Mask.Defs
import LeanNetworking.Mask.BitVec
import LeanNetworking.Mask.Theorems


/-- Definition of a subnet. A subnet is a set with `ϕ(x) = the subnet mask
  formed with x and m is equal to the subnet mask formed with a and m`, with
  `a, m` being parameters-/
def subnet (a : IP) (m : SubnetMask) : Set IP :=
  fun ip => applySubnetMask ip m = applySubnetMask a m


/-- The size of a subnet is `2^n`, where `n` is the length of the network portion-/
def subnetSize (mask : SubnetMask) := 2^(32-mask.val)
