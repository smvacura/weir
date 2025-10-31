import LeanNetworking.Subnet.Defs
import LeanNetworking.Subnet.Theorems

structure CIDR where
  (base : IP)
  (mask : SubnetMask)
  (aligned : applySubnetMask base mask = base)
