resource "azurerm_resource_group" "main" {
  name     = "network-rg"
  location = "eastus"
}

resource "azurerm_virtual_network" "local" {
  name                = "local-vnet"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_virtual_network" "remote" {
  name                = "remote-vnet"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_virtual_network_peering" "local_to_remote" {
  name                      = "local-to-remote"
  resource_group_name       = azurerm_resource_group.main.name
  virtual_network_name      = azurerm_virtual_network.local.name
  remote_virtual_network_id = azurerm_virtual_network.remote.id
}
