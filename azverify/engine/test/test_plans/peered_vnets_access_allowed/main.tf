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
  address_space       = ["10.1.0.0/16"]
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
  address_prefixes     = ["10.1.1.0/24"]
}

resource "azurerm_virtual_network_peering" "peer_a_to_b" {
  name                         = "peer-a-to-b"
  resource_group_name          = azurerm_resource_group.main.name
  virtual_network_name         = azurerm_virtual_network.vnet_a.name
  remote_virtual_network_id    = azurerm_virtual_network.vnet_b.id
  allow_virtual_network_access = true
}

resource "azurerm_virtual_network_peering" "peer_b_to_a" {
  name                         = "peer-b-to-a"
  resource_group_name          = azurerm_resource_group.main.name
  virtual_network_name         = azurerm_virtual_network.vnet_b.name
  remote_virtual_network_id    = azurerm_virtual_network.vnet_a.id
  allow_virtual_network_access = true
}

# Empty NSG on subnet-b: no user rules, so AllowVNetInBound (auto-enriched with
# the peered CIDR 10.0.0.0/16) is the rule that permits traffic from VNet A.
resource "azurerm_network_security_group" "nsg_b" {
  name                = "nsg-b"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
}

resource "azurerm_subnet_network_security_group_association" "nsg_b_assoc" {
  subnet_id                 = azurerm_subnet.subnet_b.id
  network_security_group_id = azurerm_network_security_group.nsg_b.id
}
