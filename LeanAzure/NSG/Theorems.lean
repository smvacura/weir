import LeanAzure.NSG.Defs
import LeanAzure.Defs


theorem no_lower_available_imp_no_change {ips ipd : IP} {ports portd : ℕ}
  {n : AzureNSG} {r : AzureSecurityRule}
  (hin : r ∈ n.rules) (hlt : r.rule_priority < lowestAvailablePriority n)
  (hmin : isMinimalMatchingRule ips ipd ports portd r n)
  (r' : AzureSecurityRule) :
  addressInboundAllowed ips ipd ports portd n =
  addressInboundAllowed ips ipd ports portd (n ◁ r') := by

  sorry
