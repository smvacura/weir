resource "azurerm_resource_group" "rg" {
  name     = "stress-rg"
  location = "eastus"
}

resource "azurerm_virtual_network" "vnet_0" {
  name                = "vnet-0"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet_0_0" {
  name                 = "subnet-0-0"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_0.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "subnet_0_1" {
  name                 = "subnet-0-1"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_0.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "subnet_0_2" {
  name                 = "subnet-0-2"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_0.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "subnet_0_3" {
  name                 = "subnet-0-3"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_0.name
  address_prefixes     = ["10.0.3.0/24"]
}

resource "azurerm_subnet" "subnet_0_4" {
  name                 = "subnet-0-4"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_0.name
  address_prefixes     = ["10.0.4.0/24"]
}

resource "azurerm_subnet" "subnet_0_5" {
  name                 = "subnet-0-5"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_0.name
  address_prefixes     = ["10.0.5.0/24"]
}

resource "azurerm_subnet" "subnet_0_6" {
  name                 = "subnet-0-6"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_0.name
  address_prefixes     = ["10.0.6.0/24"]
}

resource "azurerm_subnet" "subnet_0_7" {
  name                 = "subnet-0-7"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_0.name
  address_prefixes     = ["10.0.7.0/24"]
}

resource "azurerm_subnet" "subnet_0_8" {
  name                 = "subnet-0-8"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_0.name
  address_prefixes     = ["10.0.8.0/24"]
}

resource "azurerm_subnet" "subnet_0_9" {
  name                 = "subnet-0-9"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_0.name
  address_prefixes     = ["10.0.9.0/24"]
}

resource "azurerm_subnet" "subnet_0_10" {
  name                 = "subnet-0-10"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_0.name
  address_prefixes     = ["10.0.10.0/24"]
}

resource "azurerm_subnet" "subnet_0_11" {
  name                 = "subnet-0-11"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_0.name
  address_prefixes     = ["10.0.11.0/24"]
}

resource "azurerm_subnet" "subnet_0_12" {
  name                 = "subnet-0-12"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_0.name
  address_prefixes     = ["10.0.12.0/24"]
}

resource "azurerm_subnet" "subnet_0_13" {
  name                 = "subnet-0-13"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_0.name
  address_prefixes     = ["10.0.13.0/24"]
}

resource "azurerm_subnet" "subnet_0_14" {
  name                 = "subnet-0-14"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_0.name
  address_prefixes     = ["10.0.14.0/24"]
}

resource "azurerm_subnet" "subnet_0_15" {
  name                 = "subnet-0-15"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_0.name
  address_prefixes     = ["10.0.15.0/24"]
}

resource "azurerm_subnet" "subnet_0_16" {
  name                 = "subnet-0-16"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_0.name
  address_prefixes     = ["10.0.16.0/24"]
}

resource "azurerm_subnet" "subnet_0_17" {
  name                 = "subnet-0-17"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_0.name
  address_prefixes     = ["10.0.17.0/24"]
}

resource "azurerm_subnet" "subnet_0_18" {
  name                 = "subnet-0-18"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_0.name
  address_prefixes     = ["10.0.18.0/24"]
}

resource "azurerm_subnet" "subnet_0_19" {
  name                 = "subnet-0-19"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_0.name
  address_prefixes     = ["10.0.19.0/24"]
}

resource "azurerm_virtual_network" "vnet_1" {
  name                = "vnet-1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "subnet_1_0" {
  name                 = "subnet-1-0"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_1.name
  address_prefixes     = ["10.1.0.0/24"]
}

resource "azurerm_subnet" "subnet_1_1" {
  name                 = "subnet-1-1"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_1.name
  address_prefixes     = ["10.1.1.0/24"]
}

resource "azurerm_subnet" "subnet_1_2" {
  name                 = "subnet-1-2"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_1.name
  address_prefixes     = ["10.1.2.0/24"]
}

resource "azurerm_subnet" "subnet_1_3" {
  name                 = "subnet-1-3"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_1.name
  address_prefixes     = ["10.1.3.0/24"]
}

resource "azurerm_subnet" "subnet_1_4" {
  name                 = "subnet-1-4"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_1.name
  address_prefixes     = ["10.1.4.0/24"]
}

resource "azurerm_subnet" "subnet_1_5" {
  name                 = "subnet-1-5"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_1.name
  address_prefixes     = ["10.1.5.0/24"]
}

resource "azurerm_subnet" "subnet_1_6" {
  name                 = "subnet-1-6"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_1.name
  address_prefixes     = ["10.1.6.0/24"]
}

resource "azurerm_subnet" "subnet_1_7" {
  name                 = "subnet-1-7"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_1.name
  address_prefixes     = ["10.1.7.0/24"]
}

resource "azurerm_subnet" "subnet_1_8" {
  name                 = "subnet-1-8"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_1.name
  address_prefixes     = ["10.1.8.0/24"]
}

resource "azurerm_subnet" "subnet_1_9" {
  name                 = "subnet-1-9"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_1.name
  address_prefixes     = ["10.1.9.0/24"]
}

resource "azurerm_subnet" "subnet_1_10" {
  name                 = "subnet-1-10"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_1.name
  address_prefixes     = ["10.1.10.0/24"]
}

resource "azurerm_subnet" "subnet_1_11" {
  name                 = "subnet-1-11"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_1.name
  address_prefixes     = ["10.1.11.0/24"]
}

resource "azurerm_subnet" "subnet_1_12" {
  name                 = "subnet-1-12"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_1.name
  address_prefixes     = ["10.1.12.0/24"]
}

resource "azurerm_subnet" "subnet_1_13" {
  name                 = "subnet-1-13"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_1.name
  address_prefixes     = ["10.1.13.0/24"]
}

resource "azurerm_subnet" "subnet_1_14" {
  name                 = "subnet-1-14"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_1.name
  address_prefixes     = ["10.1.14.0/24"]
}

resource "azurerm_subnet" "subnet_1_15" {
  name                 = "subnet-1-15"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_1.name
  address_prefixes     = ["10.1.15.0/24"]
}

resource "azurerm_subnet" "subnet_1_16" {
  name                 = "subnet-1-16"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_1.name
  address_prefixes     = ["10.1.16.0/24"]
}

resource "azurerm_subnet" "subnet_1_17" {
  name                 = "subnet-1-17"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_1.name
  address_prefixes     = ["10.1.17.0/24"]
}

resource "azurerm_subnet" "subnet_1_18" {
  name                 = "subnet-1-18"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_1.name
  address_prefixes     = ["10.1.18.0/24"]
}

resource "azurerm_subnet" "subnet_1_19" {
  name                 = "subnet-1-19"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_1.name
  address_prefixes     = ["10.1.19.0/24"]
}

resource "azurerm_virtual_network" "vnet_2" {
  name                = "vnet-2"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.2.0.0/16"]
}

resource "azurerm_subnet" "subnet_2_0" {
  name                 = "subnet-2-0"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_2.name
  address_prefixes     = ["10.2.0.0/24"]
}

resource "azurerm_subnet" "subnet_2_1" {
  name                 = "subnet-2-1"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_2.name
  address_prefixes     = ["10.2.1.0/24"]
}

resource "azurerm_subnet" "subnet_2_2" {
  name                 = "subnet-2-2"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_2.name
  address_prefixes     = ["10.2.2.0/24"]
}

resource "azurerm_subnet" "subnet_2_3" {
  name                 = "subnet-2-3"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_2.name
  address_prefixes     = ["10.2.3.0/24"]
}

resource "azurerm_subnet" "subnet_2_4" {
  name                 = "subnet-2-4"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_2.name
  address_prefixes     = ["10.2.4.0/24"]
}

resource "azurerm_subnet" "subnet_2_5" {
  name                 = "subnet-2-5"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_2.name
  address_prefixes     = ["10.2.5.0/24"]
}

resource "azurerm_subnet" "subnet_2_6" {
  name                 = "subnet-2-6"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_2.name
  address_prefixes     = ["10.2.6.0/24"]
}

resource "azurerm_subnet" "subnet_2_7" {
  name                 = "subnet-2-7"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_2.name
  address_prefixes     = ["10.2.7.0/24"]
}

resource "azurerm_subnet" "subnet_2_8" {
  name                 = "subnet-2-8"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_2.name
  address_prefixes     = ["10.2.8.0/24"]
}

resource "azurerm_subnet" "subnet_2_9" {
  name                 = "subnet-2-9"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_2.name
  address_prefixes     = ["10.2.9.0/24"]
}

resource "azurerm_subnet" "subnet_2_10" {
  name                 = "subnet-2-10"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_2.name
  address_prefixes     = ["10.2.10.0/24"]
}

resource "azurerm_subnet" "subnet_2_11" {
  name                 = "subnet-2-11"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_2.name
  address_prefixes     = ["10.2.11.0/24"]
}

resource "azurerm_subnet" "subnet_2_12" {
  name                 = "subnet-2-12"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_2.name
  address_prefixes     = ["10.2.12.0/24"]
}

resource "azurerm_subnet" "subnet_2_13" {
  name                 = "subnet-2-13"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_2.name
  address_prefixes     = ["10.2.13.0/24"]
}

resource "azurerm_subnet" "subnet_2_14" {
  name                 = "subnet-2-14"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_2.name
  address_prefixes     = ["10.2.14.0/24"]
}

resource "azurerm_subnet" "subnet_2_15" {
  name                 = "subnet-2-15"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_2.name
  address_prefixes     = ["10.2.15.0/24"]
}

resource "azurerm_subnet" "subnet_2_16" {
  name                 = "subnet-2-16"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_2.name
  address_prefixes     = ["10.2.16.0/24"]
}

resource "azurerm_subnet" "subnet_2_17" {
  name                 = "subnet-2-17"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_2.name
  address_prefixes     = ["10.2.17.0/24"]
}

resource "azurerm_subnet" "subnet_2_18" {
  name                 = "subnet-2-18"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_2.name
  address_prefixes     = ["10.2.18.0/24"]
}

resource "azurerm_subnet" "subnet_2_19" {
  name                 = "subnet-2-19"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_2.name
  address_prefixes     = ["10.2.19.0/24"]
}

resource "azurerm_virtual_network" "vnet_3" {
  name                = "vnet-3"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.3.0.0/16"]
}

resource "azurerm_subnet" "subnet_3_0" {
  name                 = "subnet-3-0"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_3.name
  address_prefixes     = ["10.3.0.0/24"]
}

resource "azurerm_subnet" "subnet_3_1" {
  name                 = "subnet-3-1"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_3.name
  address_prefixes     = ["10.3.1.0/24"]
}

resource "azurerm_subnet" "subnet_3_2" {
  name                 = "subnet-3-2"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_3.name
  address_prefixes     = ["10.3.2.0/24"]
}

resource "azurerm_subnet" "subnet_3_3" {
  name                 = "subnet-3-3"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_3.name
  address_prefixes     = ["10.3.3.0/24"]
}

resource "azurerm_subnet" "subnet_3_4" {
  name                 = "subnet-3-4"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_3.name
  address_prefixes     = ["10.3.4.0/24"]
}

resource "azurerm_subnet" "subnet_3_5" {
  name                 = "subnet-3-5"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_3.name
  address_prefixes     = ["10.3.5.0/24"]
}

resource "azurerm_subnet" "subnet_3_6" {
  name                 = "subnet-3-6"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_3.name
  address_prefixes     = ["10.3.6.0/24"]
}

resource "azurerm_subnet" "subnet_3_7" {
  name                 = "subnet-3-7"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_3.name
  address_prefixes     = ["10.3.7.0/24"]
}

resource "azurerm_subnet" "subnet_3_8" {
  name                 = "subnet-3-8"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_3.name
  address_prefixes     = ["10.3.8.0/24"]
}

resource "azurerm_subnet" "subnet_3_9" {
  name                 = "subnet-3-9"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_3.name
  address_prefixes     = ["10.3.9.0/24"]
}

resource "azurerm_subnet" "subnet_3_10" {
  name                 = "subnet-3-10"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_3.name
  address_prefixes     = ["10.3.10.0/24"]
}

resource "azurerm_subnet" "subnet_3_11" {
  name                 = "subnet-3-11"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_3.name
  address_prefixes     = ["10.3.11.0/24"]
}

resource "azurerm_subnet" "subnet_3_12" {
  name                 = "subnet-3-12"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_3.name
  address_prefixes     = ["10.3.12.0/24"]
}

resource "azurerm_subnet" "subnet_3_13" {
  name                 = "subnet-3-13"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_3.name
  address_prefixes     = ["10.3.13.0/24"]
}

resource "azurerm_subnet" "subnet_3_14" {
  name                 = "subnet-3-14"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_3.name
  address_prefixes     = ["10.3.14.0/24"]
}

resource "azurerm_subnet" "subnet_3_15" {
  name                 = "subnet-3-15"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_3.name
  address_prefixes     = ["10.3.15.0/24"]
}

resource "azurerm_subnet" "subnet_3_16" {
  name                 = "subnet-3-16"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_3.name
  address_prefixes     = ["10.3.16.0/24"]
}

resource "azurerm_subnet" "subnet_3_17" {
  name                 = "subnet-3-17"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_3.name
  address_prefixes     = ["10.3.17.0/24"]
}

resource "azurerm_subnet" "subnet_3_18" {
  name                 = "subnet-3-18"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_3.name
  address_prefixes     = ["10.3.18.0/24"]
}

resource "azurerm_subnet" "subnet_3_19" {
  name                 = "subnet-3-19"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_3.name
  address_prefixes     = ["10.3.19.0/24"]
}

resource "azurerm_virtual_network" "vnet_4" {
  name                = "vnet-4"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.4.0.0/16"]
}

resource "azurerm_subnet" "subnet_4_0" {
  name                 = "subnet-4-0"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_4.name
  address_prefixes     = ["10.4.0.0/24"]
}

resource "azurerm_subnet" "subnet_4_1" {
  name                 = "subnet-4-1"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_4.name
  address_prefixes     = ["10.4.1.0/24"]
}

resource "azurerm_subnet" "subnet_4_2" {
  name                 = "subnet-4-2"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_4.name
  address_prefixes     = ["10.4.2.0/24"]
}

resource "azurerm_subnet" "subnet_4_3" {
  name                 = "subnet-4-3"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_4.name
  address_prefixes     = ["10.4.3.0/24"]
}

resource "azurerm_subnet" "subnet_4_4" {
  name                 = "subnet-4-4"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_4.name
  address_prefixes     = ["10.4.4.0/24"]
}

resource "azurerm_subnet" "subnet_4_5" {
  name                 = "subnet-4-5"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_4.name
  address_prefixes     = ["10.4.5.0/24"]
}

resource "azurerm_subnet" "subnet_4_6" {
  name                 = "subnet-4-6"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_4.name
  address_prefixes     = ["10.4.6.0/24"]
}

resource "azurerm_subnet" "subnet_4_7" {
  name                 = "subnet-4-7"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_4.name
  address_prefixes     = ["10.4.7.0/24"]
}

resource "azurerm_subnet" "subnet_4_8" {
  name                 = "subnet-4-8"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_4.name
  address_prefixes     = ["10.4.8.0/24"]
}

resource "azurerm_subnet" "subnet_4_9" {
  name                 = "subnet-4-9"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_4.name
  address_prefixes     = ["10.4.9.0/24"]
}

resource "azurerm_subnet" "subnet_4_10" {
  name                 = "subnet-4-10"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_4.name
  address_prefixes     = ["10.4.10.0/24"]
}

resource "azurerm_subnet" "subnet_4_11" {
  name                 = "subnet-4-11"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_4.name
  address_prefixes     = ["10.4.11.0/24"]
}

resource "azurerm_subnet" "subnet_4_12" {
  name                 = "subnet-4-12"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_4.name
  address_prefixes     = ["10.4.12.0/24"]
}

resource "azurerm_subnet" "subnet_4_13" {
  name                 = "subnet-4-13"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_4.name
  address_prefixes     = ["10.4.13.0/24"]
}

resource "azurerm_subnet" "subnet_4_14" {
  name                 = "subnet-4-14"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_4.name
  address_prefixes     = ["10.4.14.0/24"]
}

resource "azurerm_subnet" "subnet_4_15" {
  name                 = "subnet-4-15"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_4.name
  address_prefixes     = ["10.4.15.0/24"]
}

resource "azurerm_subnet" "subnet_4_16" {
  name                 = "subnet-4-16"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_4.name
  address_prefixes     = ["10.4.16.0/24"]
}

resource "azurerm_subnet" "subnet_4_17" {
  name                 = "subnet-4-17"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_4.name
  address_prefixes     = ["10.4.17.0/24"]
}

resource "azurerm_subnet" "subnet_4_18" {
  name                 = "subnet-4-18"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_4.name
  address_prefixes     = ["10.4.18.0/24"]
}

resource "azurerm_subnet" "subnet_4_19" {
  name                 = "subnet-4-19"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_4.name
  address_prefixes     = ["10.4.19.0/24"]
}

resource "azurerm_virtual_network" "vnet_5" {
  name                = "vnet-5"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.5.0.0/16"]
}

resource "azurerm_subnet" "subnet_5_0" {
  name                 = "subnet-5-0"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_5.name
  address_prefixes     = ["10.5.0.0/24"]
}

resource "azurerm_subnet" "subnet_5_1" {
  name                 = "subnet-5-1"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_5.name
  address_prefixes     = ["10.5.1.0/24"]
}

resource "azurerm_subnet" "subnet_5_2" {
  name                 = "subnet-5-2"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_5.name
  address_prefixes     = ["10.5.2.0/24"]
}

resource "azurerm_subnet" "subnet_5_3" {
  name                 = "subnet-5-3"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_5.name
  address_prefixes     = ["10.5.3.0/24"]
}

resource "azurerm_subnet" "subnet_5_4" {
  name                 = "subnet-5-4"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_5.name
  address_prefixes     = ["10.5.4.0/24"]
}

resource "azurerm_subnet" "subnet_5_5" {
  name                 = "subnet-5-5"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_5.name
  address_prefixes     = ["10.5.5.0/24"]
}

resource "azurerm_subnet" "subnet_5_6" {
  name                 = "subnet-5-6"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_5.name
  address_prefixes     = ["10.5.6.0/24"]
}

resource "azurerm_subnet" "subnet_5_7" {
  name                 = "subnet-5-7"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_5.name
  address_prefixes     = ["10.5.7.0/24"]
}

resource "azurerm_subnet" "subnet_5_8" {
  name                 = "subnet-5-8"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_5.name
  address_prefixes     = ["10.5.8.0/24"]
}

resource "azurerm_subnet" "subnet_5_9" {
  name                 = "subnet-5-9"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_5.name
  address_prefixes     = ["10.5.9.0/24"]
}

resource "azurerm_subnet" "subnet_5_10" {
  name                 = "subnet-5-10"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_5.name
  address_prefixes     = ["10.5.10.0/24"]
}

resource "azurerm_subnet" "subnet_5_11" {
  name                 = "subnet-5-11"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_5.name
  address_prefixes     = ["10.5.11.0/24"]
}

resource "azurerm_subnet" "subnet_5_12" {
  name                 = "subnet-5-12"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_5.name
  address_prefixes     = ["10.5.12.0/24"]
}

resource "azurerm_subnet" "subnet_5_13" {
  name                 = "subnet-5-13"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_5.name
  address_prefixes     = ["10.5.13.0/24"]
}

resource "azurerm_subnet" "subnet_5_14" {
  name                 = "subnet-5-14"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_5.name
  address_prefixes     = ["10.5.14.0/24"]
}

resource "azurerm_subnet" "subnet_5_15" {
  name                 = "subnet-5-15"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_5.name
  address_prefixes     = ["10.5.15.0/24"]
}

resource "azurerm_subnet" "subnet_5_16" {
  name                 = "subnet-5-16"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_5.name
  address_prefixes     = ["10.5.16.0/24"]
}

resource "azurerm_subnet" "subnet_5_17" {
  name                 = "subnet-5-17"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_5.name
  address_prefixes     = ["10.5.17.0/24"]
}

resource "azurerm_subnet" "subnet_5_18" {
  name                 = "subnet-5-18"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_5.name
  address_prefixes     = ["10.5.18.0/24"]
}

resource "azurerm_subnet" "subnet_5_19" {
  name                 = "subnet-5-19"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_5.name
  address_prefixes     = ["10.5.19.0/24"]
}

resource "azurerm_virtual_network" "vnet_6" {
  name                = "vnet-6"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.6.0.0/16"]
}

resource "azurerm_subnet" "subnet_6_0" {
  name                 = "subnet-6-0"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_6.name
  address_prefixes     = ["10.6.0.0/24"]
}

resource "azurerm_subnet" "subnet_6_1" {
  name                 = "subnet-6-1"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_6.name
  address_prefixes     = ["10.6.1.0/24"]
}

resource "azurerm_subnet" "subnet_6_2" {
  name                 = "subnet-6-2"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_6.name
  address_prefixes     = ["10.6.2.0/24"]
}

resource "azurerm_subnet" "subnet_6_3" {
  name                 = "subnet-6-3"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_6.name
  address_prefixes     = ["10.6.3.0/24"]
}

resource "azurerm_subnet" "subnet_6_4" {
  name                 = "subnet-6-4"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_6.name
  address_prefixes     = ["10.6.4.0/24"]
}

resource "azurerm_subnet" "subnet_6_5" {
  name                 = "subnet-6-5"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_6.name
  address_prefixes     = ["10.6.5.0/24"]
}

resource "azurerm_subnet" "subnet_6_6" {
  name                 = "subnet-6-6"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_6.name
  address_prefixes     = ["10.6.6.0/24"]
}

resource "azurerm_subnet" "subnet_6_7" {
  name                 = "subnet-6-7"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_6.name
  address_prefixes     = ["10.6.7.0/24"]
}

resource "azurerm_subnet" "subnet_6_8" {
  name                 = "subnet-6-8"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_6.name
  address_prefixes     = ["10.6.8.0/24"]
}

resource "azurerm_subnet" "subnet_6_9" {
  name                 = "subnet-6-9"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_6.name
  address_prefixes     = ["10.6.9.0/24"]
}

resource "azurerm_subnet" "subnet_6_10" {
  name                 = "subnet-6-10"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_6.name
  address_prefixes     = ["10.6.10.0/24"]
}

resource "azurerm_subnet" "subnet_6_11" {
  name                 = "subnet-6-11"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_6.name
  address_prefixes     = ["10.6.11.0/24"]
}

resource "azurerm_subnet" "subnet_6_12" {
  name                 = "subnet-6-12"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_6.name
  address_prefixes     = ["10.6.12.0/24"]
}

resource "azurerm_subnet" "subnet_6_13" {
  name                 = "subnet-6-13"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_6.name
  address_prefixes     = ["10.6.13.0/24"]
}

resource "azurerm_subnet" "subnet_6_14" {
  name                 = "subnet-6-14"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_6.name
  address_prefixes     = ["10.6.14.0/24"]
}

resource "azurerm_subnet" "subnet_6_15" {
  name                 = "subnet-6-15"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_6.name
  address_prefixes     = ["10.6.15.0/24"]
}

resource "azurerm_subnet" "subnet_6_16" {
  name                 = "subnet-6-16"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_6.name
  address_prefixes     = ["10.6.16.0/24"]
}

resource "azurerm_subnet" "subnet_6_17" {
  name                 = "subnet-6-17"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_6.name
  address_prefixes     = ["10.6.17.0/24"]
}

resource "azurerm_subnet" "subnet_6_18" {
  name                 = "subnet-6-18"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_6.name
  address_prefixes     = ["10.6.18.0/24"]
}

resource "azurerm_subnet" "subnet_6_19" {
  name                 = "subnet-6-19"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_6.name
  address_prefixes     = ["10.6.19.0/24"]
}

resource "azurerm_virtual_network" "vnet_7" {
  name                = "vnet-7"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.7.0.0/16"]
}

resource "azurerm_subnet" "subnet_7_0" {
  name                 = "subnet-7-0"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_7.name
  address_prefixes     = ["10.7.0.0/24"]
}

resource "azurerm_subnet" "subnet_7_1" {
  name                 = "subnet-7-1"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_7.name
  address_prefixes     = ["10.7.1.0/24"]
}

resource "azurerm_subnet" "subnet_7_2" {
  name                 = "subnet-7-2"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_7.name
  address_prefixes     = ["10.7.2.0/24"]
}

resource "azurerm_subnet" "subnet_7_3" {
  name                 = "subnet-7-3"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_7.name
  address_prefixes     = ["10.7.3.0/24"]
}

resource "azurerm_subnet" "subnet_7_4" {
  name                 = "subnet-7-4"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_7.name
  address_prefixes     = ["10.7.4.0/24"]
}

resource "azurerm_subnet" "subnet_7_5" {
  name                 = "subnet-7-5"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_7.name
  address_prefixes     = ["10.7.5.0/24"]
}

resource "azurerm_subnet" "subnet_7_6" {
  name                 = "subnet-7-6"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_7.name
  address_prefixes     = ["10.7.6.0/24"]
}

resource "azurerm_subnet" "subnet_7_7" {
  name                 = "subnet-7-7"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_7.name
  address_prefixes     = ["10.7.7.0/24"]
}

resource "azurerm_subnet" "subnet_7_8" {
  name                 = "subnet-7-8"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_7.name
  address_prefixes     = ["10.7.8.0/24"]
}

resource "azurerm_subnet" "subnet_7_9" {
  name                 = "subnet-7-9"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_7.name
  address_prefixes     = ["10.7.9.0/24"]
}

resource "azurerm_subnet" "subnet_7_10" {
  name                 = "subnet-7-10"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_7.name
  address_prefixes     = ["10.7.10.0/24"]
}

resource "azurerm_subnet" "subnet_7_11" {
  name                 = "subnet-7-11"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_7.name
  address_prefixes     = ["10.7.11.0/24"]
}

resource "azurerm_subnet" "subnet_7_12" {
  name                 = "subnet-7-12"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_7.name
  address_prefixes     = ["10.7.12.0/24"]
}

resource "azurerm_subnet" "subnet_7_13" {
  name                 = "subnet-7-13"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_7.name
  address_prefixes     = ["10.7.13.0/24"]
}

resource "azurerm_subnet" "subnet_7_14" {
  name                 = "subnet-7-14"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_7.name
  address_prefixes     = ["10.7.14.0/24"]
}

resource "azurerm_subnet" "subnet_7_15" {
  name                 = "subnet-7-15"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_7.name
  address_prefixes     = ["10.7.15.0/24"]
}

resource "azurerm_subnet" "subnet_7_16" {
  name                 = "subnet-7-16"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_7.name
  address_prefixes     = ["10.7.16.0/24"]
}

resource "azurerm_subnet" "subnet_7_17" {
  name                 = "subnet-7-17"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_7.name
  address_prefixes     = ["10.7.17.0/24"]
}

resource "azurerm_subnet" "subnet_7_18" {
  name                 = "subnet-7-18"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_7.name
  address_prefixes     = ["10.7.18.0/24"]
}

resource "azurerm_subnet" "subnet_7_19" {
  name                 = "subnet-7-19"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_7.name
  address_prefixes     = ["10.7.19.0/24"]
}

resource "azurerm_virtual_network" "vnet_8" {
  name                = "vnet-8"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.8.0.0/16"]
}

resource "azurerm_subnet" "subnet_8_0" {
  name                 = "subnet-8-0"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_8.name
  address_prefixes     = ["10.8.0.0/24"]
}

resource "azurerm_subnet" "subnet_8_1" {
  name                 = "subnet-8-1"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_8.name
  address_prefixes     = ["10.8.1.0/24"]
}

resource "azurerm_subnet" "subnet_8_2" {
  name                 = "subnet-8-2"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_8.name
  address_prefixes     = ["10.8.2.0/24"]
}

resource "azurerm_subnet" "subnet_8_3" {
  name                 = "subnet-8-3"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_8.name
  address_prefixes     = ["10.8.3.0/24"]
}

resource "azurerm_subnet" "subnet_8_4" {
  name                 = "subnet-8-4"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_8.name
  address_prefixes     = ["10.8.4.0/24"]
}

resource "azurerm_subnet" "subnet_8_5" {
  name                 = "subnet-8-5"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_8.name
  address_prefixes     = ["10.8.5.0/24"]
}

resource "azurerm_subnet" "subnet_8_6" {
  name                 = "subnet-8-6"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_8.name
  address_prefixes     = ["10.8.6.0/24"]
}

resource "azurerm_subnet" "subnet_8_7" {
  name                 = "subnet-8-7"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_8.name
  address_prefixes     = ["10.8.7.0/24"]
}

resource "azurerm_subnet" "subnet_8_8" {
  name                 = "subnet-8-8"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_8.name
  address_prefixes     = ["10.8.8.0/24"]
}

resource "azurerm_subnet" "subnet_8_9" {
  name                 = "subnet-8-9"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_8.name
  address_prefixes     = ["10.8.9.0/24"]
}

resource "azurerm_subnet" "subnet_8_10" {
  name                 = "subnet-8-10"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_8.name
  address_prefixes     = ["10.8.10.0/24"]
}

resource "azurerm_subnet" "subnet_8_11" {
  name                 = "subnet-8-11"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_8.name
  address_prefixes     = ["10.8.11.0/24"]
}

resource "azurerm_subnet" "subnet_8_12" {
  name                 = "subnet-8-12"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_8.name
  address_prefixes     = ["10.8.12.0/24"]
}

resource "azurerm_subnet" "subnet_8_13" {
  name                 = "subnet-8-13"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_8.name
  address_prefixes     = ["10.8.13.0/24"]
}

resource "azurerm_subnet" "subnet_8_14" {
  name                 = "subnet-8-14"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_8.name
  address_prefixes     = ["10.8.14.0/24"]
}

resource "azurerm_subnet" "subnet_8_15" {
  name                 = "subnet-8-15"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_8.name
  address_prefixes     = ["10.8.15.0/24"]
}

resource "azurerm_subnet" "subnet_8_16" {
  name                 = "subnet-8-16"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_8.name
  address_prefixes     = ["10.8.16.0/24"]
}

resource "azurerm_subnet" "subnet_8_17" {
  name                 = "subnet-8-17"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_8.name
  address_prefixes     = ["10.8.17.0/24"]
}

resource "azurerm_subnet" "subnet_8_18" {
  name                 = "subnet-8-18"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_8.name
  address_prefixes     = ["10.8.18.0/24"]
}

resource "azurerm_subnet" "subnet_8_19" {
  name                 = "subnet-8-19"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_8.name
  address_prefixes     = ["10.8.19.0/24"]
}

resource "azurerm_virtual_network" "vnet_9" {
  name                = "vnet-9"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.9.0.0/16"]
}

resource "azurerm_subnet" "subnet_9_0" {
  name                 = "subnet-9-0"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_9.name
  address_prefixes     = ["10.9.0.0/24"]
}

resource "azurerm_subnet" "subnet_9_1" {
  name                 = "subnet-9-1"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_9.name
  address_prefixes     = ["10.9.1.0/24"]
}

resource "azurerm_subnet" "subnet_9_2" {
  name                 = "subnet-9-2"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_9.name
  address_prefixes     = ["10.9.2.0/24"]
}

resource "azurerm_subnet" "subnet_9_3" {
  name                 = "subnet-9-3"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_9.name
  address_prefixes     = ["10.9.3.0/24"]
}

resource "azurerm_subnet" "subnet_9_4" {
  name                 = "subnet-9-4"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_9.name
  address_prefixes     = ["10.9.4.0/24"]
}

resource "azurerm_subnet" "subnet_9_5" {
  name                 = "subnet-9-5"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_9.name
  address_prefixes     = ["10.9.5.0/24"]
}

resource "azurerm_subnet" "subnet_9_6" {
  name                 = "subnet-9-6"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_9.name
  address_prefixes     = ["10.9.6.0/24"]
}

resource "azurerm_subnet" "subnet_9_7" {
  name                 = "subnet-9-7"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_9.name
  address_prefixes     = ["10.9.7.0/24"]
}

resource "azurerm_subnet" "subnet_9_8" {
  name                 = "subnet-9-8"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_9.name
  address_prefixes     = ["10.9.8.0/24"]
}

resource "azurerm_subnet" "subnet_9_9" {
  name                 = "subnet-9-9"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_9.name
  address_prefixes     = ["10.9.9.0/24"]
}

resource "azurerm_subnet" "subnet_9_10" {
  name                 = "subnet-9-10"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_9.name
  address_prefixes     = ["10.9.10.0/24"]
}

resource "azurerm_subnet" "subnet_9_11" {
  name                 = "subnet-9-11"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_9.name
  address_prefixes     = ["10.9.11.0/24"]
}

resource "azurerm_subnet" "subnet_9_12" {
  name                 = "subnet-9-12"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_9.name
  address_prefixes     = ["10.9.12.0/24"]
}

resource "azurerm_subnet" "subnet_9_13" {
  name                 = "subnet-9-13"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_9.name
  address_prefixes     = ["10.9.13.0/24"]
}

resource "azurerm_subnet" "subnet_9_14" {
  name                 = "subnet-9-14"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_9.name
  address_prefixes     = ["10.9.14.0/24"]
}

resource "azurerm_subnet" "subnet_9_15" {
  name                 = "subnet-9-15"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_9.name
  address_prefixes     = ["10.9.15.0/24"]
}

resource "azurerm_subnet" "subnet_9_16" {
  name                 = "subnet-9-16"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_9.name
  address_prefixes     = ["10.9.16.0/24"]
}

resource "azurerm_subnet" "subnet_9_17" {
  name                 = "subnet-9-17"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_9.name
  address_prefixes     = ["10.9.17.0/24"]
}

resource "azurerm_subnet" "subnet_9_18" {
  name                 = "subnet-9-18"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_9.name
  address_prefixes     = ["10.9.18.0/24"]
}

resource "azurerm_subnet" "subnet_9_19" {
  name                 = "subnet-9-19"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_9.name
  address_prefixes     = ["10.9.19.0/24"]
}
