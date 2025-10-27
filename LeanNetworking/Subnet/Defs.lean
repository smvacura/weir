import LeanNetworking.Mask.Defs
import LeanNetworking.Mask.BitVec
import LeanNetworking.Mask.Theorems

def subnet (a : IP) (m : SubnetMask) : Set IP :=
  fun ip => applySubnetMask ip m = applySubnetMask a m


def subnetSize (mask : SubnetMask) := 2^(32-mask.val)
