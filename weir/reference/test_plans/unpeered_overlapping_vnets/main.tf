# A crosscheck fixture for cross-VNet delivery without peering.
#
# Two VNets share the same address space and nothing connects them.  In Azure a
# packet from subnet-a to 10.0.2.4 matches VNet A's own VnetLocal route, finds no
# interface in VNet A owning that address, and is dropped: subnet-b is
# unreachable from subnet-a, and the reference agrees (deliver_to_owner searches
# only the local VNet plus access-allowed peers).
#
# The engine delivers it.  The VirtualNetwork branch of add_subnet_edges scans
# every subnet in every VNet, so VNet A's 10.0.0.0/16 system route intersects
# subnet-b's 10.0.2.0/24 and an edge a -> b is built.  The NSG on subnet-b does
# not catch it either: the overlapping space puts subnet-a's source address
# inside subnet-b's own AllowVNetInBound prefix.  Expect the pair
# subnet_a -> subnet_b to disagree in both directions.
#
# The two subnet prefixes stay distinct even though the VNet spaces overlap, so
# the sampler's subnet_owner lookup still resolves each sampled address to one
# subnet.

resource "azurerm_resource_group" "main" {
  name     = "main"
  location = "eastus"
}

resource "azurerm_virtual_network" "vnet_a" {
  name                = "vnet-a"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_virtual_network" "vnet_b" {
  name                = "vnet-b"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet_a" {
  name                 = "subnet-a"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.vnet_a.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "subnet_b" {
  name                 = "subnet-b"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.vnet_b.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Empty NSG on subnet-b: no user rules, so the only inbound allow is
# AllowVNetInBound over VNet B's own 10.0.0.0/16 — which, because the spaces
# overlap, also covers every source address in VNet A.
resource "azurerm_network_security_group" "nsg_b" {
  name                = "nsg-b"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
}

resource "azurerm_subnet_network_security_group_association" "nsg_b_assoc" {
  subnet_id                 = azurerm_subnet.subnet_b.id
  network_security_group_id = azurerm_network_security_group.nsg_b.id
}
