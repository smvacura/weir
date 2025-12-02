import LeanNetworking.IP
import LeanAzure.NIC.Defs

structure AzureVM where
  (nic : AzureNIC)
  (ip  : IP)           -- the VM's actual ip address
