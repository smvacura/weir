resource "azurerm_resource_group" "main" {
  name     = "main"
  location = "eastus"
}

resource "azurerm_virtual_network" "main_vnet" {
  name                = "main-vnet"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "source_subnet" {
  name                 = "subnet-src"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main_vnet.name
  address_prefixes     = ["10.1.1.0/24"]
}

resource "azurerm_subnet" "nic_subnet" {
  name                 = "subnet-dest"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main_vnet.name
  address_prefixes     = ["10.1.2.0/24"]
}

resource "azurerm_network_security_group" "dest_nsg" {
  name                = "dest-nsg"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  security_rule {
    name                       = "allow-ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "22"
    destination_port_range     = "22"
    source_address_prefix      = "10.1.1.24"
    destination_address_prefix = "10.1.2.24"
  }

  security_rule {
    name                       = "allow-http"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "80"
    destination_port_range     = "80"
    source_address_prefix      = "10.1.1.24"
    destination_address_prefix = "10.1.2.24"
  }
}

resource "azurerm_subnet_network_security_group_association" "dest_nsg_assoc" {
  subnet_id                 = azurerm_subnet.nic_subnet.id
  network_security_group_id = azurerm_network_security_group.dest_nsg.id
}
