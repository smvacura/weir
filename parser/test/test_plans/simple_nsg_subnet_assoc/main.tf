resource "azurerm_resource_group" "main" {
  name     = "nsg-subnet-rg"
  location = "eastus"
}

resource "azurerm_virtual_network" "main" {
  name                = "main-vnet"
  location            = "eastus"
  resource_group_name = "nsg-subnet-rg"
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "main" {
  name                 = "main-subnet"
  resource_group_name  = "nsg-subnet-rg"
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "main" {
  name                = "main-nsg"
  location            = "eastus"
  resource_group_name = "nsg-subnet-rg"

  security_rule {
    name                       = "allow-https"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "assoc" {
  subnet_id                 = azurerm_subnet.main.id
  network_security_group_id = azurerm_network_security_group.main.id
}
