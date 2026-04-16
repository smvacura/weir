resource "azurerm_resource_group" "rg_0" {
  name     = "rg-0"
  location = "eastus"
}

resource "azurerm_virtual_network" "vnet_0_0" {
  name                = "vnet-0-0"
  location            = azurerm_resource_group.rg_0.location
  resource_group_name = azurerm_resource_group.rg_0.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet_0_0_0" {
  name                 = "subnet-0-0-0"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_0.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "subnet_0_0_1" {
  name                 = "subnet-0-0-1"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_0.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "subnet_0_0_2" {
  name                 = "subnet-0-0-2"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_0.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "subnet_0_0_3" {
  name                 = "subnet-0-0-3"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_0.name
  address_prefixes     = ["10.0.3.0/24"]
}

resource "azurerm_subnet" "subnet_0_0_4" {
  name                 = "subnet-0-0-4"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_0.name
  address_prefixes     = ["10.0.4.0/24"]
}

resource "azurerm_subnet" "subnet_0_0_5" {
  name                 = "subnet-0-0-5"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_0.name
  address_prefixes     = ["10.0.5.0/24"]
}

resource "azurerm_subnet" "subnet_0_0_6" {
  name                 = "subnet-0-0-6"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_0.name
  address_prefixes     = ["10.0.6.0/24"]
}

resource "azurerm_subnet" "subnet_0_0_7" {
  name                 = "subnet-0-0-7"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_0.name
  address_prefixes     = ["10.0.7.0/24"]
}

resource "azurerm_subnet" "subnet_0_0_8" {
  name                 = "subnet-0-0-8"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_0.name
  address_prefixes     = ["10.0.8.0/24"]
}

resource "azurerm_subnet" "subnet_0_0_9" {
  name                 = "subnet-0-0-9"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_0.name
  address_prefixes     = ["10.0.9.0/24"]
}

resource "azurerm_subnet" "subnet_0_0_10" {
  name                 = "subnet-0-0-10"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_0.name
  address_prefixes     = ["10.0.10.0/24"]
}

resource "azurerm_subnet" "subnet_0_0_11" {
  name                 = "subnet-0-0-11"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_0.name
  address_prefixes     = ["10.0.11.0/24"]
}

resource "azurerm_subnet" "subnet_0_0_12" {
  name                 = "subnet-0-0-12"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_0.name
  address_prefixes     = ["10.0.12.0/24"]
}

resource "azurerm_subnet" "subnet_0_0_13" {
  name                 = "subnet-0-0-13"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_0.name
  address_prefixes     = ["10.0.13.0/24"]
}

resource "azurerm_subnet" "subnet_0_0_14" {
  name                 = "subnet-0-0-14"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_0.name
  address_prefixes     = ["10.0.14.0/24"]
}

resource "azurerm_subnet" "subnet_0_0_15" {
  name                 = "subnet-0-0-15"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_0.name
  address_prefixes     = ["10.0.15.0/24"]
}

resource "azurerm_subnet" "subnet_0_0_16" {
  name                 = "subnet-0-0-16"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_0.name
  address_prefixes     = ["10.0.16.0/24"]
}

resource "azurerm_subnet" "subnet_0_0_17" {
  name                 = "subnet-0-0-17"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_0.name
  address_prefixes     = ["10.0.17.0/24"]
}

resource "azurerm_subnet" "subnet_0_0_18" {
  name                 = "subnet-0-0-18"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_0.name
  address_prefixes     = ["10.0.18.0/24"]
}

resource "azurerm_subnet" "subnet_0_0_19" {
  name                 = "subnet-0-0-19"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_0.name
  address_prefixes     = ["10.0.19.0/24"]
}

resource "azurerm_subnet" "subnet_0_0_20" {
  name                 = "subnet-0-0-20"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_0.name
  address_prefixes     = ["10.0.20.0/24"]
}

resource "azurerm_subnet" "subnet_0_0_21" {
  name                 = "subnet-0-0-21"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_0.name
  address_prefixes     = ["10.0.21.0/24"]
}

resource "azurerm_subnet" "subnet_0_0_22" {
  name                 = "subnet-0-0-22"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_0.name
  address_prefixes     = ["10.0.22.0/24"]
}

resource "azurerm_subnet" "subnet_0_0_23" {
  name                 = "subnet-0-0-23"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_0.name
  address_prefixes     = ["10.0.23.0/24"]
}

resource "azurerm_subnet" "subnet_0_0_24" {
  name                 = "subnet-0-0-24"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_0.name
  address_prefixes     = ["10.0.24.0/24"]
}

resource "azurerm_subnet" "subnet_0_0_25" {
  name                 = "subnet-0-0-25"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_0.name
  address_prefixes     = ["10.0.25.0/24"]
}

resource "azurerm_subnet" "subnet_0_0_26" {
  name                 = "subnet-0-0-26"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_0.name
  address_prefixes     = ["10.0.26.0/24"]
}

resource "azurerm_subnet" "subnet_0_0_27" {
  name                 = "subnet-0-0-27"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_0.name
  address_prefixes     = ["10.0.27.0/24"]
}

resource "azurerm_subnet" "subnet_0_0_28" {
  name                 = "subnet-0-0-28"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_0.name
  address_prefixes     = ["10.0.28.0/24"]
}

resource "azurerm_subnet" "subnet_0_0_29" {
  name                 = "subnet-0-0-29"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_0.name
  address_prefixes     = ["10.0.29.0/24"]
}

resource "azurerm_subnet" "subnet_0_0_30" {
  name                 = "subnet-0-0-30"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_0.name
  address_prefixes     = ["10.0.30.0/24"]
}

resource "azurerm_subnet" "subnet_0_0_31" {
  name                 = "subnet-0-0-31"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_0.name
  address_prefixes     = ["10.0.31.0/24"]
}

resource "azurerm_subnet" "subnet_0_0_32" {
  name                 = "subnet-0-0-32"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_0.name
  address_prefixes     = ["10.0.32.0/24"]
}

resource "azurerm_subnet" "subnet_0_0_33" {
  name                 = "subnet-0-0-33"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_0.name
  address_prefixes     = ["10.0.33.0/24"]
}

resource "azurerm_subnet" "subnet_0_0_34" {
  name                 = "subnet-0-0-34"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_0.name
  address_prefixes     = ["10.0.34.0/24"]
}

resource "azurerm_subnet" "subnet_0_0_35" {
  name                 = "subnet-0-0-35"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_0.name
  address_prefixes     = ["10.0.35.0/24"]
}

resource "azurerm_subnet" "subnet_0_0_36" {
  name                 = "subnet-0-0-36"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_0.name
  address_prefixes     = ["10.0.36.0/24"]
}

resource "azurerm_subnet" "subnet_0_0_37" {
  name                 = "subnet-0-0-37"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_0.name
  address_prefixes     = ["10.0.37.0/24"]
}

resource "azurerm_subnet" "subnet_0_0_38" {
  name                 = "subnet-0-0-38"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_0.name
  address_prefixes     = ["10.0.38.0/24"]
}

resource "azurerm_virtual_network" "vnet_0_1" {
  name                = "vnet-0-1"
  location            = azurerm_resource_group.rg_0.location
  resource_group_name = azurerm_resource_group.rg_0.name
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "subnet_0_1_0" {
  name                 = "subnet-0-1-0"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_1.name
  address_prefixes     = ["10.1.0.0/24"]
}

resource "azurerm_subnet" "subnet_0_1_1" {
  name                 = "subnet-0-1-1"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_1.name
  address_prefixes     = ["10.1.1.0/24"]
}

resource "azurerm_subnet" "subnet_0_1_2" {
  name                 = "subnet-0-1-2"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_1.name
  address_prefixes     = ["10.1.2.0/24"]
}

resource "azurerm_subnet" "subnet_0_1_3" {
  name                 = "subnet-0-1-3"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_1.name
  address_prefixes     = ["10.1.3.0/24"]
}

resource "azurerm_subnet" "subnet_0_1_4" {
  name                 = "subnet-0-1-4"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_1.name
  address_prefixes     = ["10.1.4.0/24"]
}

resource "azurerm_subnet" "subnet_0_1_5" {
  name                 = "subnet-0-1-5"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_1.name
  address_prefixes     = ["10.1.5.0/24"]
}

resource "azurerm_subnet" "subnet_0_1_6" {
  name                 = "subnet-0-1-6"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_1.name
  address_prefixes     = ["10.1.6.0/24"]
}

resource "azurerm_subnet" "subnet_0_1_7" {
  name                 = "subnet-0-1-7"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_1.name
  address_prefixes     = ["10.1.7.0/24"]
}

resource "azurerm_subnet" "subnet_0_1_8" {
  name                 = "subnet-0-1-8"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_1.name
  address_prefixes     = ["10.1.8.0/24"]
}

resource "azurerm_subnet" "subnet_0_1_9" {
  name                 = "subnet-0-1-9"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_1.name
  address_prefixes     = ["10.1.9.0/24"]
}

resource "azurerm_subnet" "subnet_0_1_10" {
  name                 = "subnet-0-1-10"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_1.name
  address_prefixes     = ["10.1.10.0/24"]
}

resource "azurerm_subnet" "subnet_0_1_11" {
  name                 = "subnet-0-1-11"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_1.name
  address_prefixes     = ["10.1.11.0/24"]
}

resource "azurerm_subnet" "subnet_0_1_12" {
  name                 = "subnet-0-1-12"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_1.name
  address_prefixes     = ["10.1.12.0/24"]
}

resource "azurerm_subnet" "subnet_0_1_13" {
  name                 = "subnet-0-1-13"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_1.name
  address_prefixes     = ["10.1.13.0/24"]
}

resource "azurerm_subnet" "subnet_0_1_14" {
  name                 = "subnet-0-1-14"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_1.name
  address_prefixes     = ["10.1.14.0/24"]
}

resource "azurerm_subnet" "subnet_0_1_15" {
  name                 = "subnet-0-1-15"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_1.name
  address_prefixes     = ["10.1.15.0/24"]
}

resource "azurerm_subnet" "subnet_0_1_16" {
  name                 = "subnet-0-1-16"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_1.name
  address_prefixes     = ["10.1.16.0/24"]
}

resource "azurerm_subnet" "subnet_0_1_17" {
  name                 = "subnet-0-1-17"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_1.name
  address_prefixes     = ["10.1.17.0/24"]
}

resource "azurerm_subnet" "subnet_0_1_18" {
  name                 = "subnet-0-1-18"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_1.name
  address_prefixes     = ["10.1.18.0/24"]
}

resource "azurerm_subnet" "subnet_0_1_19" {
  name                 = "subnet-0-1-19"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_1.name
  address_prefixes     = ["10.1.19.0/24"]
}

resource "azurerm_subnet" "subnet_0_1_20" {
  name                 = "subnet-0-1-20"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_1.name
  address_prefixes     = ["10.1.20.0/24"]
}

resource "azurerm_subnet" "subnet_0_1_21" {
  name                 = "subnet-0-1-21"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_1.name
  address_prefixes     = ["10.1.21.0/24"]
}

resource "azurerm_subnet" "subnet_0_1_22" {
  name                 = "subnet-0-1-22"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_1.name
  address_prefixes     = ["10.1.22.0/24"]
}

resource "azurerm_subnet" "subnet_0_1_23" {
  name                 = "subnet-0-1-23"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_1.name
  address_prefixes     = ["10.1.23.0/24"]
}

resource "azurerm_subnet" "subnet_0_1_24" {
  name                 = "subnet-0-1-24"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_1.name
  address_prefixes     = ["10.1.24.0/24"]
}

resource "azurerm_subnet" "subnet_0_1_25" {
  name                 = "subnet-0-1-25"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_1.name
  address_prefixes     = ["10.1.25.0/24"]
}

resource "azurerm_subnet" "subnet_0_1_26" {
  name                 = "subnet-0-1-26"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_1.name
  address_prefixes     = ["10.1.26.0/24"]
}

resource "azurerm_subnet" "subnet_0_1_27" {
  name                 = "subnet-0-1-27"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_1.name
  address_prefixes     = ["10.1.27.0/24"]
}

resource "azurerm_subnet" "subnet_0_1_28" {
  name                 = "subnet-0-1-28"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_1.name
  address_prefixes     = ["10.1.28.0/24"]
}

resource "azurerm_subnet" "subnet_0_1_29" {
  name                 = "subnet-0-1-29"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_1.name
  address_prefixes     = ["10.1.29.0/24"]
}

resource "azurerm_subnet" "subnet_0_1_30" {
  name                 = "subnet-0-1-30"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_1.name
  address_prefixes     = ["10.1.30.0/24"]
}

resource "azurerm_subnet" "subnet_0_1_31" {
  name                 = "subnet-0-1-31"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_1.name
  address_prefixes     = ["10.1.31.0/24"]
}

resource "azurerm_subnet" "subnet_0_1_32" {
  name                 = "subnet-0-1-32"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_1.name
  address_prefixes     = ["10.1.32.0/24"]
}

resource "azurerm_subnet" "subnet_0_1_33" {
  name                 = "subnet-0-1-33"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_1.name
  address_prefixes     = ["10.1.33.0/24"]
}

resource "azurerm_subnet" "subnet_0_1_34" {
  name                 = "subnet-0-1-34"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_1.name
  address_prefixes     = ["10.1.34.0/24"]
}

resource "azurerm_subnet" "subnet_0_1_35" {
  name                 = "subnet-0-1-35"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_1.name
  address_prefixes     = ["10.1.35.0/24"]
}

resource "azurerm_subnet" "subnet_0_1_36" {
  name                 = "subnet-0-1-36"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_1.name
  address_prefixes     = ["10.1.36.0/24"]
}

resource "azurerm_subnet" "subnet_0_1_37" {
  name                 = "subnet-0-1-37"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_1.name
  address_prefixes     = ["10.1.37.0/24"]
}

resource "azurerm_subnet" "subnet_0_1_38" {
  name                 = "subnet-0-1-38"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_1.name
  address_prefixes     = ["10.1.38.0/24"]
}

resource "azurerm_virtual_network" "vnet_0_2" {
  name                = "vnet-0-2"
  location            = azurerm_resource_group.rg_0.location
  resource_group_name = azurerm_resource_group.rg_0.name
  address_space       = ["10.2.0.0/16"]
}

resource "azurerm_subnet" "subnet_0_2_0" {
  name                 = "subnet-0-2-0"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_2.name
  address_prefixes     = ["10.2.0.0/24"]
}

resource "azurerm_subnet" "subnet_0_2_1" {
  name                 = "subnet-0-2-1"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_2.name
  address_prefixes     = ["10.2.1.0/24"]
}

resource "azurerm_subnet" "subnet_0_2_2" {
  name                 = "subnet-0-2-2"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_2.name
  address_prefixes     = ["10.2.2.0/24"]
}

resource "azurerm_subnet" "subnet_0_2_3" {
  name                 = "subnet-0-2-3"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_2.name
  address_prefixes     = ["10.2.3.0/24"]
}

resource "azurerm_subnet" "subnet_0_2_4" {
  name                 = "subnet-0-2-4"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_2.name
  address_prefixes     = ["10.2.4.0/24"]
}

resource "azurerm_subnet" "subnet_0_2_5" {
  name                 = "subnet-0-2-5"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_2.name
  address_prefixes     = ["10.2.5.0/24"]
}

resource "azurerm_subnet" "subnet_0_2_6" {
  name                 = "subnet-0-2-6"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_2.name
  address_prefixes     = ["10.2.6.0/24"]
}

resource "azurerm_subnet" "subnet_0_2_7" {
  name                 = "subnet-0-2-7"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_2.name
  address_prefixes     = ["10.2.7.0/24"]
}

resource "azurerm_subnet" "subnet_0_2_8" {
  name                 = "subnet-0-2-8"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_2.name
  address_prefixes     = ["10.2.8.0/24"]
}

resource "azurerm_subnet" "subnet_0_2_9" {
  name                 = "subnet-0-2-9"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_2.name
  address_prefixes     = ["10.2.9.0/24"]
}

resource "azurerm_subnet" "subnet_0_2_10" {
  name                 = "subnet-0-2-10"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_2.name
  address_prefixes     = ["10.2.10.0/24"]
}

resource "azurerm_subnet" "subnet_0_2_11" {
  name                 = "subnet-0-2-11"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_2.name
  address_prefixes     = ["10.2.11.0/24"]
}

resource "azurerm_subnet" "subnet_0_2_12" {
  name                 = "subnet-0-2-12"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_2.name
  address_prefixes     = ["10.2.12.0/24"]
}

resource "azurerm_subnet" "subnet_0_2_13" {
  name                 = "subnet-0-2-13"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_2.name
  address_prefixes     = ["10.2.13.0/24"]
}

resource "azurerm_subnet" "subnet_0_2_14" {
  name                 = "subnet-0-2-14"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_2.name
  address_prefixes     = ["10.2.14.0/24"]
}

resource "azurerm_subnet" "subnet_0_2_15" {
  name                 = "subnet-0-2-15"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_2.name
  address_prefixes     = ["10.2.15.0/24"]
}

resource "azurerm_subnet" "subnet_0_2_16" {
  name                 = "subnet-0-2-16"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_2.name
  address_prefixes     = ["10.2.16.0/24"]
}

resource "azurerm_subnet" "subnet_0_2_17" {
  name                 = "subnet-0-2-17"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_2.name
  address_prefixes     = ["10.2.17.0/24"]
}

resource "azurerm_subnet" "subnet_0_2_18" {
  name                 = "subnet-0-2-18"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_2.name
  address_prefixes     = ["10.2.18.0/24"]
}

resource "azurerm_subnet" "subnet_0_2_19" {
  name                 = "subnet-0-2-19"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_2.name
  address_prefixes     = ["10.2.19.0/24"]
}

resource "azurerm_subnet" "subnet_0_2_20" {
  name                 = "subnet-0-2-20"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_2.name
  address_prefixes     = ["10.2.20.0/24"]
}

resource "azurerm_subnet" "subnet_0_2_21" {
  name                 = "subnet-0-2-21"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_2.name
  address_prefixes     = ["10.2.21.0/24"]
}

resource "azurerm_subnet" "subnet_0_2_22" {
  name                 = "subnet-0-2-22"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_2.name
  address_prefixes     = ["10.2.22.0/24"]
}

resource "azurerm_subnet" "subnet_0_2_23" {
  name                 = "subnet-0-2-23"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_2.name
  address_prefixes     = ["10.2.23.0/24"]
}

resource "azurerm_subnet" "subnet_0_2_24" {
  name                 = "subnet-0-2-24"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_2.name
  address_prefixes     = ["10.2.24.0/24"]
}

resource "azurerm_subnet" "subnet_0_2_25" {
  name                 = "subnet-0-2-25"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_2.name
  address_prefixes     = ["10.2.25.0/24"]
}

resource "azurerm_subnet" "subnet_0_2_26" {
  name                 = "subnet-0-2-26"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_2.name
  address_prefixes     = ["10.2.26.0/24"]
}

resource "azurerm_subnet" "subnet_0_2_27" {
  name                 = "subnet-0-2-27"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_2.name
  address_prefixes     = ["10.2.27.0/24"]
}

resource "azurerm_subnet" "subnet_0_2_28" {
  name                 = "subnet-0-2-28"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_2.name
  address_prefixes     = ["10.2.28.0/24"]
}

resource "azurerm_subnet" "subnet_0_2_29" {
  name                 = "subnet-0-2-29"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_2.name
  address_prefixes     = ["10.2.29.0/24"]
}

resource "azurerm_subnet" "subnet_0_2_30" {
  name                 = "subnet-0-2-30"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_2.name
  address_prefixes     = ["10.2.30.0/24"]
}

resource "azurerm_subnet" "subnet_0_2_31" {
  name                 = "subnet-0-2-31"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_2.name
  address_prefixes     = ["10.2.31.0/24"]
}

resource "azurerm_subnet" "subnet_0_2_32" {
  name                 = "subnet-0-2-32"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_2.name
  address_prefixes     = ["10.2.32.0/24"]
}

resource "azurerm_subnet" "subnet_0_2_33" {
  name                 = "subnet-0-2-33"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_2.name
  address_prefixes     = ["10.2.33.0/24"]
}

resource "azurerm_subnet" "subnet_0_2_34" {
  name                 = "subnet-0-2-34"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_2.name
  address_prefixes     = ["10.2.34.0/24"]
}

resource "azurerm_subnet" "subnet_0_2_35" {
  name                 = "subnet-0-2-35"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_2.name
  address_prefixes     = ["10.2.35.0/24"]
}

resource "azurerm_subnet" "subnet_0_2_36" {
  name                 = "subnet-0-2-36"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_2.name
  address_prefixes     = ["10.2.36.0/24"]
}

resource "azurerm_subnet" "subnet_0_2_37" {
  name                 = "subnet-0-2-37"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_2.name
  address_prefixes     = ["10.2.37.0/24"]
}

resource "azurerm_subnet" "subnet_0_2_38" {
  name                 = "subnet-0-2-38"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_2.name
  address_prefixes     = ["10.2.38.0/24"]
}

resource "azurerm_virtual_network" "vnet_0_3" {
  name                = "vnet-0-3"
  location            = azurerm_resource_group.rg_0.location
  resource_group_name = azurerm_resource_group.rg_0.name
  address_space       = ["10.3.0.0/16"]
}

resource "azurerm_subnet" "subnet_0_3_0" {
  name                 = "subnet-0-3-0"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_3.name
  address_prefixes     = ["10.3.0.0/24"]
}

resource "azurerm_subnet" "subnet_0_3_1" {
  name                 = "subnet-0-3-1"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_3.name
  address_prefixes     = ["10.3.1.0/24"]
}

resource "azurerm_subnet" "subnet_0_3_2" {
  name                 = "subnet-0-3-2"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_3.name
  address_prefixes     = ["10.3.2.0/24"]
}

resource "azurerm_subnet" "subnet_0_3_3" {
  name                 = "subnet-0-3-3"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_3.name
  address_prefixes     = ["10.3.3.0/24"]
}

resource "azurerm_subnet" "subnet_0_3_4" {
  name                 = "subnet-0-3-4"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_3.name
  address_prefixes     = ["10.3.4.0/24"]
}

resource "azurerm_subnet" "subnet_0_3_5" {
  name                 = "subnet-0-3-5"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_3.name
  address_prefixes     = ["10.3.5.0/24"]
}

resource "azurerm_subnet" "subnet_0_3_6" {
  name                 = "subnet-0-3-6"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_3.name
  address_prefixes     = ["10.3.6.0/24"]
}

resource "azurerm_subnet" "subnet_0_3_7" {
  name                 = "subnet-0-3-7"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_3.name
  address_prefixes     = ["10.3.7.0/24"]
}

resource "azurerm_subnet" "subnet_0_3_8" {
  name                 = "subnet-0-3-8"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_3.name
  address_prefixes     = ["10.3.8.0/24"]
}

resource "azurerm_subnet" "subnet_0_3_9" {
  name                 = "subnet-0-3-9"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_3.name
  address_prefixes     = ["10.3.9.0/24"]
}

resource "azurerm_subnet" "subnet_0_3_10" {
  name                 = "subnet-0-3-10"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_3.name
  address_prefixes     = ["10.3.10.0/24"]
}

resource "azurerm_subnet" "subnet_0_3_11" {
  name                 = "subnet-0-3-11"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_3.name
  address_prefixes     = ["10.3.11.0/24"]
}

resource "azurerm_subnet" "subnet_0_3_12" {
  name                 = "subnet-0-3-12"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_3.name
  address_prefixes     = ["10.3.12.0/24"]
}

resource "azurerm_subnet" "subnet_0_3_13" {
  name                 = "subnet-0-3-13"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_3.name
  address_prefixes     = ["10.3.13.0/24"]
}

resource "azurerm_subnet" "subnet_0_3_14" {
  name                 = "subnet-0-3-14"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_3.name
  address_prefixes     = ["10.3.14.0/24"]
}

resource "azurerm_subnet" "subnet_0_3_15" {
  name                 = "subnet-0-3-15"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_3.name
  address_prefixes     = ["10.3.15.0/24"]
}

resource "azurerm_subnet" "subnet_0_3_16" {
  name                 = "subnet-0-3-16"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_3.name
  address_prefixes     = ["10.3.16.0/24"]
}

resource "azurerm_subnet" "subnet_0_3_17" {
  name                 = "subnet-0-3-17"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_3.name
  address_prefixes     = ["10.3.17.0/24"]
}

resource "azurerm_subnet" "subnet_0_3_18" {
  name                 = "subnet-0-3-18"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_3.name
  address_prefixes     = ["10.3.18.0/24"]
}

resource "azurerm_subnet" "subnet_0_3_19" {
  name                 = "subnet-0-3-19"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_3.name
  address_prefixes     = ["10.3.19.0/24"]
}

resource "azurerm_subnet" "subnet_0_3_20" {
  name                 = "subnet-0-3-20"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_3.name
  address_prefixes     = ["10.3.20.0/24"]
}

resource "azurerm_subnet" "subnet_0_3_21" {
  name                 = "subnet-0-3-21"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_3.name
  address_prefixes     = ["10.3.21.0/24"]
}

resource "azurerm_subnet" "subnet_0_3_22" {
  name                 = "subnet-0-3-22"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_3.name
  address_prefixes     = ["10.3.22.0/24"]
}

resource "azurerm_subnet" "subnet_0_3_23" {
  name                 = "subnet-0-3-23"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_3.name
  address_prefixes     = ["10.3.23.0/24"]
}

resource "azurerm_subnet" "subnet_0_3_24" {
  name                 = "subnet-0-3-24"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_3.name
  address_prefixes     = ["10.3.24.0/24"]
}

resource "azurerm_subnet" "subnet_0_3_25" {
  name                 = "subnet-0-3-25"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_3.name
  address_prefixes     = ["10.3.25.0/24"]
}

resource "azurerm_subnet" "subnet_0_3_26" {
  name                 = "subnet-0-3-26"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_3.name
  address_prefixes     = ["10.3.26.0/24"]
}

resource "azurerm_subnet" "subnet_0_3_27" {
  name                 = "subnet-0-3-27"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_3.name
  address_prefixes     = ["10.3.27.0/24"]
}

resource "azurerm_subnet" "subnet_0_3_28" {
  name                 = "subnet-0-3-28"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_3.name
  address_prefixes     = ["10.3.28.0/24"]
}

resource "azurerm_subnet" "subnet_0_3_29" {
  name                 = "subnet-0-3-29"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_3.name
  address_prefixes     = ["10.3.29.0/24"]
}

resource "azurerm_subnet" "subnet_0_3_30" {
  name                 = "subnet-0-3-30"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_3.name
  address_prefixes     = ["10.3.30.0/24"]
}

resource "azurerm_subnet" "subnet_0_3_31" {
  name                 = "subnet-0-3-31"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_3.name
  address_prefixes     = ["10.3.31.0/24"]
}

resource "azurerm_subnet" "subnet_0_3_32" {
  name                 = "subnet-0-3-32"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_3.name
  address_prefixes     = ["10.3.32.0/24"]
}

resource "azurerm_subnet" "subnet_0_3_33" {
  name                 = "subnet-0-3-33"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_3.name
  address_prefixes     = ["10.3.33.0/24"]
}

resource "azurerm_subnet" "subnet_0_3_34" {
  name                 = "subnet-0-3-34"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_3.name
  address_prefixes     = ["10.3.34.0/24"]
}

resource "azurerm_subnet" "subnet_0_3_35" {
  name                 = "subnet-0-3-35"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_3.name
  address_prefixes     = ["10.3.35.0/24"]
}

resource "azurerm_subnet" "subnet_0_3_36" {
  name                 = "subnet-0-3-36"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_3.name
  address_prefixes     = ["10.3.36.0/24"]
}

resource "azurerm_subnet" "subnet_0_3_37" {
  name                 = "subnet-0-3-37"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_3.name
  address_prefixes     = ["10.3.37.0/24"]
}

resource "azurerm_subnet" "subnet_0_3_38" {
  name                 = "subnet-0-3-38"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_3.name
  address_prefixes     = ["10.3.38.0/24"]
}

resource "azurerm_virtual_network" "vnet_0_4" {
  name                = "vnet-0-4"
  location            = azurerm_resource_group.rg_0.location
  resource_group_name = azurerm_resource_group.rg_0.name
  address_space       = ["10.4.0.0/16"]
}

resource "azurerm_subnet" "subnet_0_4_0" {
  name                 = "subnet-0-4-0"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_4.name
  address_prefixes     = ["10.4.0.0/24"]
}

resource "azurerm_subnet" "subnet_0_4_1" {
  name                 = "subnet-0-4-1"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_4.name
  address_prefixes     = ["10.4.1.0/24"]
}

resource "azurerm_subnet" "subnet_0_4_2" {
  name                 = "subnet-0-4-2"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_4.name
  address_prefixes     = ["10.4.2.0/24"]
}

resource "azurerm_subnet" "subnet_0_4_3" {
  name                 = "subnet-0-4-3"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_4.name
  address_prefixes     = ["10.4.3.0/24"]
}

resource "azurerm_subnet" "subnet_0_4_4" {
  name                 = "subnet-0-4-4"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_4.name
  address_prefixes     = ["10.4.4.0/24"]
}

resource "azurerm_subnet" "subnet_0_4_5" {
  name                 = "subnet-0-4-5"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_4.name
  address_prefixes     = ["10.4.5.0/24"]
}

resource "azurerm_subnet" "subnet_0_4_6" {
  name                 = "subnet-0-4-6"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_4.name
  address_prefixes     = ["10.4.6.0/24"]
}

resource "azurerm_subnet" "subnet_0_4_7" {
  name                 = "subnet-0-4-7"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_4.name
  address_prefixes     = ["10.4.7.0/24"]
}

resource "azurerm_subnet" "subnet_0_4_8" {
  name                 = "subnet-0-4-8"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_4.name
  address_prefixes     = ["10.4.8.0/24"]
}

resource "azurerm_subnet" "subnet_0_4_9" {
  name                 = "subnet-0-4-9"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_4.name
  address_prefixes     = ["10.4.9.0/24"]
}

resource "azurerm_subnet" "subnet_0_4_10" {
  name                 = "subnet-0-4-10"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_4.name
  address_prefixes     = ["10.4.10.0/24"]
}

resource "azurerm_subnet" "subnet_0_4_11" {
  name                 = "subnet-0-4-11"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_4.name
  address_prefixes     = ["10.4.11.0/24"]
}

resource "azurerm_subnet" "subnet_0_4_12" {
  name                 = "subnet-0-4-12"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_4.name
  address_prefixes     = ["10.4.12.0/24"]
}

resource "azurerm_subnet" "subnet_0_4_13" {
  name                 = "subnet-0-4-13"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_4.name
  address_prefixes     = ["10.4.13.0/24"]
}

resource "azurerm_subnet" "subnet_0_4_14" {
  name                 = "subnet-0-4-14"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_4.name
  address_prefixes     = ["10.4.14.0/24"]
}

resource "azurerm_subnet" "subnet_0_4_15" {
  name                 = "subnet-0-4-15"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_4.name
  address_prefixes     = ["10.4.15.0/24"]
}

resource "azurerm_subnet" "subnet_0_4_16" {
  name                 = "subnet-0-4-16"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_4.name
  address_prefixes     = ["10.4.16.0/24"]
}

resource "azurerm_subnet" "subnet_0_4_17" {
  name                 = "subnet-0-4-17"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_4.name
  address_prefixes     = ["10.4.17.0/24"]
}

resource "azurerm_subnet" "subnet_0_4_18" {
  name                 = "subnet-0-4-18"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_4.name
  address_prefixes     = ["10.4.18.0/24"]
}

resource "azurerm_subnet" "subnet_0_4_19" {
  name                 = "subnet-0-4-19"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_4.name
  address_prefixes     = ["10.4.19.0/24"]
}

resource "azurerm_subnet" "subnet_0_4_20" {
  name                 = "subnet-0-4-20"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_4.name
  address_prefixes     = ["10.4.20.0/24"]
}

resource "azurerm_subnet" "subnet_0_4_21" {
  name                 = "subnet-0-4-21"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_4.name
  address_prefixes     = ["10.4.21.0/24"]
}

resource "azurerm_subnet" "subnet_0_4_22" {
  name                 = "subnet-0-4-22"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_4.name
  address_prefixes     = ["10.4.22.0/24"]
}

resource "azurerm_subnet" "subnet_0_4_23" {
  name                 = "subnet-0-4-23"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_4.name
  address_prefixes     = ["10.4.23.0/24"]
}

resource "azurerm_subnet" "subnet_0_4_24" {
  name                 = "subnet-0-4-24"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_4.name
  address_prefixes     = ["10.4.24.0/24"]
}

resource "azurerm_subnet" "subnet_0_4_25" {
  name                 = "subnet-0-4-25"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_4.name
  address_prefixes     = ["10.4.25.0/24"]
}

resource "azurerm_subnet" "subnet_0_4_26" {
  name                 = "subnet-0-4-26"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_4.name
  address_prefixes     = ["10.4.26.0/24"]
}

resource "azurerm_subnet" "subnet_0_4_27" {
  name                 = "subnet-0-4-27"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_4.name
  address_prefixes     = ["10.4.27.0/24"]
}

resource "azurerm_subnet" "subnet_0_4_28" {
  name                 = "subnet-0-4-28"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_4.name
  address_prefixes     = ["10.4.28.0/24"]
}

resource "azurerm_subnet" "subnet_0_4_29" {
  name                 = "subnet-0-4-29"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_4.name
  address_prefixes     = ["10.4.29.0/24"]
}

resource "azurerm_subnet" "subnet_0_4_30" {
  name                 = "subnet-0-4-30"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_4.name
  address_prefixes     = ["10.4.30.0/24"]
}

resource "azurerm_subnet" "subnet_0_4_31" {
  name                 = "subnet-0-4-31"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_4.name
  address_prefixes     = ["10.4.31.0/24"]
}

resource "azurerm_subnet" "subnet_0_4_32" {
  name                 = "subnet-0-4-32"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_4.name
  address_prefixes     = ["10.4.32.0/24"]
}

resource "azurerm_subnet" "subnet_0_4_33" {
  name                 = "subnet-0-4-33"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_4.name
  address_prefixes     = ["10.4.33.0/24"]
}

resource "azurerm_subnet" "subnet_0_4_34" {
  name                 = "subnet-0-4-34"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_4.name
  address_prefixes     = ["10.4.34.0/24"]
}

resource "azurerm_subnet" "subnet_0_4_35" {
  name                 = "subnet-0-4-35"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_4.name
  address_prefixes     = ["10.4.35.0/24"]
}

resource "azurerm_subnet" "subnet_0_4_36" {
  name                 = "subnet-0-4-36"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_4.name
  address_prefixes     = ["10.4.36.0/24"]
}

resource "azurerm_subnet" "subnet_0_4_37" {
  name                 = "subnet-0-4-37"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_4.name
  address_prefixes     = ["10.4.37.0/24"]
}

resource "azurerm_subnet" "subnet_0_4_38" {
  name                 = "subnet-0-4-38"
  resource_group_name  = azurerm_resource_group.rg_0.name
  virtual_network_name = azurerm_virtual_network.vnet_0_4.name
  address_prefixes     = ["10.4.38.0/24"]
}

resource "azurerm_resource_group" "rg_1" {
  name     = "rg-1"
  location = "westus"
}

resource "azurerm_virtual_network" "vnet_1_0" {
  name                = "vnet-1-0"
  location            = azurerm_resource_group.rg_1.location
  resource_group_name = azurerm_resource_group.rg_1.name
  address_space       = ["10.5.0.0/16"]
}

resource "azurerm_subnet" "subnet_1_0_0" {
  name                 = "subnet-1-0-0"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_0.name
  address_prefixes     = ["10.5.0.0/24"]
}

resource "azurerm_subnet" "subnet_1_0_1" {
  name                 = "subnet-1-0-1"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_0.name
  address_prefixes     = ["10.5.1.0/24"]
}

resource "azurerm_subnet" "subnet_1_0_2" {
  name                 = "subnet-1-0-2"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_0.name
  address_prefixes     = ["10.5.2.0/24"]
}

resource "azurerm_subnet" "subnet_1_0_3" {
  name                 = "subnet-1-0-3"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_0.name
  address_prefixes     = ["10.5.3.0/24"]
}

resource "azurerm_subnet" "subnet_1_0_4" {
  name                 = "subnet-1-0-4"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_0.name
  address_prefixes     = ["10.5.4.0/24"]
}

resource "azurerm_subnet" "subnet_1_0_5" {
  name                 = "subnet-1-0-5"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_0.name
  address_prefixes     = ["10.5.5.0/24"]
}

resource "azurerm_subnet" "subnet_1_0_6" {
  name                 = "subnet-1-0-6"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_0.name
  address_prefixes     = ["10.5.6.0/24"]
}

resource "azurerm_subnet" "subnet_1_0_7" {
  name                 = "subnet-1-0-7"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_0.name
  address_prefixes     = ["10.5.7.0/24"]
}

resource "azurerm_subnet" "subnet_1_0_8" {
  name                 = "subnet-1-0-8"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_0.name
  address_prefixes     = ["10.5.8.0/24"]
}

resource "azurerm_subnet" "subnet_1_0_9" {
  name                 = "subnet-1-0-9"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_0.name
  address_prefixes     = ["10.5.9.0/24"]
}

resource "azurerm_subnet" "subnet_1_0_10" {
  name                 = "subnet-1-0-10"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_0.name
  address_prefixes     = ["10.5.10.0/24"]
}

resource "azurerm_subnet" "subnet_1_0_11" {
  name                 = "subnet-1-0-11"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_0.name
  address_prefixes     = ["10.5.11.0/24"]
}

resource "azurerm_subnet" "subnet_1_0_12" {
  name                 = "subnet-1-0-12"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_0.name
  address_prefixes     = ["10.5.12.0/24"]
}

resource "azurerm_subnet" "subnet_1_0_13" {
  name                 = "subnet-1-0-13"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_0.name
  address_prefixes     = ["10.5.13.0/24"]
}

resource "azurerm_subnet" "subnet_1_0_14" {
  name                 = "subnet-1-0-14"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_0.name
  address_prefixes     = ["10.5.14.0/24"]
}

resource "azurerm_subnet" "subnet_1_0_15" {
  name                 = "subnet-1-0-15"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_0.name
  address_prefixes     = ["10.5.15.0/24"]
}

resource "azurerm_subnet" "subnet_1_0_16" {
  name                 = "subnet-1-0-16"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_0.name
  address_prefixes     = ["10.5.16.0/24"]
}

resource "azurerm_subnet" "subnet_1_0_17" {
  name                 = "subnet-1-0-17"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_0.name
  address_prefixes     = ["10.5.17.0/24"]
}

resource "azurerm_subnet" "subnet_1_0_18" {
  name                 = "subnet-1-0-18"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_0.name
  address_prefixes     = ["10.5.18.0/24"]
}

resource "azurerm_subnet" "subnet_1_0_19" {
  name                 = "subnet-1-0-19"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_0.name
  address_prefixes     = ["10.5.19.0/24"]
}

resource "azurerm_subnet" "subnet_1_0_20" {
  name                 = "subnet-1-0-20"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_0.name
  address_prefixes     = ["10.5.20.0/24"]
}

resource "azurerm_subnet" "subnet_1_0_21" {
  name                 = "subnet-1-0-21"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_0.name
  address_prefixes     = ["10.5.21.0/24"]
}

resource "azurerm_subnet" "subnet_1_0_22" {
  name                 = "subnet-1-0-22"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_0.name
  address_prefixes     = ["10.5.22.0/24"]
}

resource "azurerm_subnet" "subnet_1_0_23" {
  name                 = "subnet-1-0-23"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_0.name
  address_prefixes     = ["10.5.23.0/24"]
}

resource "azurerm_subnet" "subnet_1_0_24" {
  name                 = "subnet-1-0-24"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_0.name
  address_prefixes     = ["10.5.24.0/24"]
}

resource "azurerm_subnet" "subnet_1_0_25" {
  name                 = "subnet-1-0-25"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_0.name
  address_prefixes     = ["10.5.25.0/24"]
}

resource "azurerm_subnet" "subnet_1_0_26" {
  name                 = "subnet-1-0-26"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_0.name
  address_prefixes     = ["10.5.26.0/24"]
}

resource "azurerm_subnet" "subnet_1_0_27" {
  name                 = "subnet-1-0-27"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_0.name
  address_prefixes     = ["10.5.27.0/24"]
}

resource "azurerm_subnet" "subnet_1_0_28" {
  name                 = "subnet-1-0-28"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_0.name
  address_prefixes     = ["10.5.28.0/24"]
}

resource "azurerm_subnet" "subnet_1_0_29" {
  name                 = "subnet-1-0-29"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_0.name
  address_prefixes     = ["10.5.29.0/24"]
}

resource "azurerm_subnet" "subnet_1_0_30" {
  name                 = "subnet-1-0-30"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_0.name
  address_prefixes     = ["10.5.30.0/24"]
}

resource "azurerm_subnet" "subnet_1_0_31" {
  name                 = "subnet-1-0-31"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_0.name
  address_prefixes     = ["10.5.31.0/24"]
}

resource "azurerm_subnet" "subnet_1_0_32" {
  name                 = "subnet-1-0-32"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_0.name
  address_prefixes     = ["10.5.32.0/24"]
}

resource "azurerm_subnet" "subnet_1_0_33" {
  name                 = "subnet-1-0-33"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_0.name
  address_prefixes     = ["10.5.33.0/24"]
}

resource "azurerm_subnet" "subnet_1_0_34" {
  name                 = "subnet-1-0-34"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_0.name
  address_prefixes     = ["10.5.34.0/24"]
}

resource "azurerm_subnet" "subnet_1_0_35" {
  name                 = "subnet-1-0-35"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_0.name
  address_prefixes     = ["10.5.35.0/24"]
}

resource "azurerm_subnet" "subnet_1_0_36" {
  name                 = "subnet-1-0-36"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_0.name
  address_prefixes     = ["10.5.36.0/24"]
}

resource "azurerm_subnet" "subnet_1_0_37" {
  name                 = "subnet-1-0-37"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_0.name
  address_prefixes     = ["10.5.37.0/24"]
}

resource "azurerm_subnet" "subnet_1_0_38" {
  name                 = "subnet-1-0-38"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_0.name
  address_prefixes     = ["10.5.38.0/24"]
}

resource "azurerm_virtual_network" "vnet_1_1" {
  name                = "vnet-1-1"
  location            = azurerm_resource_group.rg_1.location
  resource_group_name = azurerm_resource_group.rg_1.name
  address_space       = ["10.6.0.0/16"]
}

resource "azurerm_subnet" "subnet_1_1_0" {
  name                 = "subnet-1-1-0"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_1.name
  address_prefixes     = ["10.6.0.0/24"]
}

resource "azurerm_subnet" "subnet_1_1_1" {
  name                 = "subnet-1-1-1"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_1.name
  address_prefixes     = ["10.6.1.0/24"]
}

resource "azurerm_subnet" "subnet_1_1_2" {
  name                 = "subnet-1-1-2"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_1.name
  address_prefixes     = ["10.6.2.0/24"]
}

resource "azurerm_subnet" "subnet_1_1_3" {
  name                 = "subnet-1-1-3"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_1.name
  address_prefixes     = ["10.6.3.0/24"]
}

resource "azurerm_subnet" "subnet_1_1_4" {
  name                 = "subnet-1-1-4"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_1.name
  address_prefixes     = ["10.6.4.0/24"]
}

resource "azurerm_subnet" "subnet_1_1_5" {
  name                 = "subnet-1-1-5"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_1.name
  address_prefixes     = ["10.6.5.0/24"]
}

resource "azurerm_subnet" "subnet_1_1_6" {
  name                 = "subnet-1-1-6"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_1.name
  address_prefixes     = ["10.6.6.0/24"]
}

resource "azurerm_subnet" "subnet_1_1_7" {
  name                 = "subnet-1-1-7"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_1.name
  address_prefixes     = ["10.6.7.0/24"]
}

resource "azurerm_subnet" "subnet_1_1_8" {
  name                 = "subnet-1-1-8"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_1.name
  address_prefixes     = ["10.6.8.0/24"]
}

resource "azurerm_subnet" "subnet_1_1_9" {
  name                 = "subnet-1-1-9"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_1.name
  address_prefixes     = ["10.6.9.0/24"]
}

resource "azurerm_subnet" "subnet_1_1_10" {
  name                 = "subnet-1-1-10"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_1.name
  address_prefixes     = ["10.6.10.0/24"]
}

resource "azurerm_subnet" "subnet_1_1_11" {
  name                 = "subnet-1-1-11"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_1.name
  address_prefixes     = ["10.6.11.0/24"]
}

resource "azurerm_subnet" "subnet_1_1_12" {
  name                 = "subnet-1-1-12"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_1.name
  address_prefixes     = ["10.6.12.0/24"]
}

resource "azurerm_subnet" "subnet_1_1_13" {
  name                 = "subnet-1-1-13"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_1.name
  address_prefixes     = ["10.6.13.0/24"]
}

resource "azurerm_subnet" "subnet_1_1_14" {
  name                 = "subnet-1-1-14"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_1.name
  address_prefixes     = ["10.6.14.0/24"]
}

resource "azurerm_subnet" "subnet_1_1_15" {
  name                 = "subnet-1-1-15"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_1.name
  address_prefixes     = ["10.6.15.0/24"]
}

resource "azurerm_subnet" "subnet_1_1_16" {
  name                 = "subnet-1-1-16"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_1.name
  address_prefixes     = ["10.6.16.0/24"]
}

resource "azurerm_subnet" "subnet_1_1_17" {
  name                 = "subnet-1-1-17"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_1.name
  address_prefixes     = ["10.6.17.0/24"]
}

resource "azurerm_subnet" "subnet_1_1_18" {
  name                 = "subnet-1-1-18"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_1.name
  address_prefixes     = ["10.6.18.0/24"]
}

resource "azurerm_subnet" "subnet_1_1_19" {
  name                 = "subnet-1-1-19"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_1.name
  address_prefixes     = ["10.6.19.0/24"]
}

resource "azurerm_subnet" "subnet_1_1_20" {
  name                 = "subnet-1-1-20"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_1.name
  address_prefixes     = ["10.6.20.0/24"]
}

resource "azurerm_subnet" "subnet_1_1_21" {
  name                 = "subnet-1-1-21"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_1.name
  address_prefixes     = ["10.6.21.0/24"]
}

resource "azurerm_subnet" "subnet_1_1_22" {
  name                 = "subnet-1-1-22"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_1.name
  address_prefixes     = ["10.6.22.0/24"]
}

resource "azurerm_subnet" "subnet_1_1_23" {
  name                 = "subnet-1-1-23"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_1.name
  address_prefixes     = ["10.6.23.0/24"]
}

resource "azurerm_subnet" "subnet_1_1_24" {
  name                 = "subnet-1-1-24"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_1.name
  address_prefixes     = ["10.6.24.0/24"]
}

resource "azurerm_subnet" "subnet_1_1_25" {
  name                 = "subnet-1-1-25"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_1.name
  address_prefixes     = ["10.6.25.0/24"]
}

resource "azurerm_subnet" "subnet_1_1_26" {
  name                 = "subnet-1-1-26"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_1.name
  address_prefixes     = ["10.6.26.0/24"]
}

resource "azurerm_subnet" "subnet_1_1_27" {
  name                 = "subnet-1-1-27"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_1.name
  address_prefixes     = ["10.6.27.0/24"]
}

resource "azurerm_subnet" "subnet_1_1_28" {
  name                 = "subnet-1-1-28"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_1.name
  address_prefixes     = ["10.6.28.0/24"]
}

resource "azurerm_subnet" "subnet_1_1_29" {
  name                 = "subnet-1-1-29"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_1.name
  address_prefixes     = ["10.6.29.0/24"]
}

resource "azurerm_subnet" "subnet_1_1_30" {
  name                 = "subnet-1-1-30"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_1.name
  address_prefixes     = ["10.6.30.0/24"]
}

resource "azurerm_subnet" "subnet_1_1_31" {
  name                 = "subnet-1-1-31"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_1.name
  address_prefixes     = ["10.6.31.0/24"]
}

resource "azurerm_subnet" "subnet_1_1_32" {
  name                 = "subnet-1-1-32"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_1.name
  address_prefixes     = ["10.6.32.0/24"]
}

resource "azurerm_subnet" "subnet_1_1_33" {
  name                 = "subnet-1-1-33"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_1.name
  address_prefixes     = ["10.6.33.0/24"]
}

resource "azurerm_subnet" "subnet_1_1_34" {
  name                 = "subnet-1-1-34"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_1.name
  address_prefixes     = ["10.6.34.0/24"]
}

resource "azurerm_subnet" "subnet_1_1_35" {
  name                 = "subnet-1-1-35"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_1.name
  address_prefixes     = ["10.6.35.0/24"]
}

resource "azurerm_subnet" "subnet_1_1_36" {
  name                 = "subnet-1-1-36"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_1.name
  address_prefixes     = ["10.6.36.0/24"]
}

resource "azurerm_subnet" "subnet_1_1_37" {
  name                 = "subnet-1-1-37"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_1.name
  address_prefixes     = ["10.6.37.0/24"]
}

resource "azurerm_subnet" "subnet_1_1_38" {
  name                 = "subnet-1-1-38"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_1.name
  address_prefixes     = ["10.6.38.0/24"]
}

resource "azurerm_virtual_network" "vnet_1_2" {
  name                = "vnet-1-2"
  location            = azurerm_resource_group.rg_1.location
  resource_group_name = azurerm_resource_group.rg_1.name
  address_space       = ["10.7.0.0/16"]
}

resource "azurerm_subnet" "subnet_1_2_0" {
  name                 = "subnet-1-2-0"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_2.name
  address_prefixes     = ["10.7.0.0/24"]
}

resource "azurerm_subnet" "subnet_1_2_1" {
  name                 = "subnet-1-2-1"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_2.name
  address_prefixes     = ["10.7.1.0/24"]
}

resource "azurerm_subnet" "subnet_1_2_2" {
  name                 = "subnet-1-2-2"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_2.name
  address_prefixes     = ["10.7.2.0/24"]
}

resource "azurerm_subnet" "subnet_1_2_3" {
  name                 = "subnet-1-2-3"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_2.name
  address_prefixes     = ["10.7.3.0/24"]
}

resource "azurerm_subnet" "subnet_1_2_4" {
  name                 = "subnet-1-2-4"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_2.name
  address_prefixes     = ["10.7.4.0/24"]
}

resource "azurerm_subnet" "subnet_1_2_5" {
  name                 = "subnet-1-2-5"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_2.name
  address_prefixes     = ["10.7.5.0/24"]
}

resource "azurerm_subnet" "subnet_1_2_6" {
  name                 = "subnet-1-2-6"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_2.name
  address_prefixes     = ["10.7.6.0/24"]
}

resource "azurerm_subnet" "subnet_1_2_7" {
  name                 = "subnet-1-2-7"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_2.name
  address_prefixes     = ["10.7.7.0/24"]
}

resource "azurerm_subnet" "subnet_1_2_8" {
  name                 = "subnet-1-2-8"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_2.name
  address_prefixes     = ["10.7.8.0/24"]
}

resource "azurerm_subnet" "subnet_1_2_9" {
  name                 = "subnet-1-2-9"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_2.name
  address_prefixes     = ["10.7.9.0/24"]
}

resource "azurerm_subnet" "subnet_1_2_10" {
  name                 = "subnet-1-2-10"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_2.name
  address_prefixes     = ["10.7.10.0/24"]
}

resource "azurerm_subnet" "subnet_1_2_11" {
  name                 = "subnet-1-2-11"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_2.name
  address_prefixes     = ["10.7.11.0/24"]
}

resource "azurerm_subnet" "subnet_1_2_12" {
  name                 = "subnet-1-2-12"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_2.name
  address_prefixes     = ["10.7.12.0/24"]
}

resource "azurerm_subnet" "subnet_1_2_13" {
  name                 = "subnet-1-2-13"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_2.name
  address_prefixes     = ["10.7.13.0/24"]
}

resource "azurerm_subnet" "subnet_1_2_14" {
  name                 = "subnet-1-2-14"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_2.name
  address_prefixes     = ["10.7.14.0/24"]
}

resource "azurerm_subnet" "subnet_1_2_15" {
  name                 = "subnet-1-2-15"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_2.name
  address_prefixes     = ["10.7.15.0/24"]
}

resource "azurerm_subnet" "subnet_1_2_16" {
  name                 = "subnet-1-2-16"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_2.name
  address_prefixes     = ["10.7.16.0/24"]
}

resource "azurerm_subnet" "subnet_1_2_17" {
  name                 = "subnet-1-2-17"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_2.name
  address_prefixes     = ["10.7.17.0/24"]
}

resource "azurerm_subnet" "subnet_1_2_18" {
  name                 = "subnet-1-2-18"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_2.name
  address_prefixes     = ["10.7.18.0/24"]
}

resource "azurerm_subnet" "subnet_1_2_19" {
  name                 = "subnet-1-2-19"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_2.name
  address_prefixes     = ["10.7.19.0/24"]
}

resource "azurerm_subnet" "subnet_1_2_20" {
  name                 = "subnet-1-2-20"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_2.name
  address_prefixes     = ["10.7.20.0/24"]
}

resource "azurerm_subnet" "subnet_1_2_21" {
  name                 = "subnet-1-2-21"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_2.name
  address_prefixes     = ["10.7.21.0/24"]
}

resource "azurerm_subnet" "subnet_1_2_22" {
  name                 = "subnet-1-2-22"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_2.name
  address_prefixes     = ["10.7.22.0/24"]
}

resource "azurerm_subnet" "subnet_1_2_23" {
  name                 = "subnet-1-2-23"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_2.name
  address_prefixes     = ["10.7.23.0/24"]
}

resource "azurerm_subnet" "subnet_1_2_24" {
  name                 = "subnet-1-2-24"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_2.name
  address_prefixes     = ["10.7.24.0/24"]
}

resource "azurerm_subnet" "subnet_1_2_25" {
  name                 = "subnet-1-2-25"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_2.name
  address_prefixes     = ["10.7.25.0/24"]
}

resource "azurerm_subnet" "subnet_1_2_26" {
  name                 = "subnet-1-2-26"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_2.name
  address_prefixes     = ["10.7.26.0/24"]
}

resource "azurerm_subnet" "subnet_1_2_27" {
  name                 = "subnet-1-2-27"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_2.name
  address_prefixes     = ["10.7.27.0/24"]
}

resource "azurerm_subnet" "subnet_1_2_28" {
  name                 = "subnet-1-2-28"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_2.name
  address_prefixes     = ["10.7.28.0/24"]
}

resource "azurerm_subnet" "subnet_1_2_29" {
  name                 = "subnet-1-2-29"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_2.name
  address_prefixes     = ["10.7.29.0/24"]
}

resource "azurerm_subnet" "subnet_1_2_30" {
  name                 = "subnet-1-2-30"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_2.name
  address_prefixes     = ["10.7.30.0/24"]
}

resource "azurerm_subnet" "subnet_1_2_31" {
  name                 = "subnet-1-2-31"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_2.name
  address_prefixes     = ["10.7.31.0/24"]
}

resource "azurerm_subnet" "subnet_1_2_32" {
  name                 = "subnet-1-2-32"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_2.name
  address_prefixes     = ["10.7.32.0/24"]
}

resource "azurerm_subnet" "subnet_1_2_33" {
  name                 = "subnet-1-2-33"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_2.name
  address_prefixes     = ["10.7.33.0/24"]
}

resource "azurerm_subnet" "subnet_1_2_34" {
  name                 = "subnet-1-2-34"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_2.name
  address_prefixes     = ["10.7.34.0/24"]
}

resource "azurerm_subnet" "subnet_1_2_35" {
  name                 = "subnet-1-2-35"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_2.name
  address_prefixes     = ["10.7.35.0/24"]
}

resource "azurerm_subnet" "subnet_1_2_36" {
  name                 = "subnet-1-2-36"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_2.name
  address_prefixes     = ["10.7.36.0/24"]
}

resource "azurerm_subnet" "subnet_1_2_37" {
  name                 = "subnet-1-2-37"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_2.name
  address_prefixes     = ["10.7.37.0/24"]
}

resource "azurerm_subnet" "subnet_1_2_38" {
  name                 = "subnet-1-2-38"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_2.name
  address_prefixes     = ["10.7.38.0/24"]
}

resource "azurerm_virtual_network" "vnet_1_3" {
  name                = "vnet-1-3"
  location            = azurerm_resource_group.rg_1.location
  resource_group_name = azurerm_resource_group.rg_1.name
  address_space       = ["10.8.0.0/16"]
}

resource "azurerm_subnet" "subnet_1_3_0" {
  name                 = "subnet-1-3-0"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_3.name
  address_prefixes     = ["10.8.0.0/24"]
}

resource "azurerm_subnet" "subnet_1_3_1" {
  name                 = "subnet-1-3-1"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_3.name
  address_prefixes     = ["10.8.1.0/24"]
}

resource "azurerm_subnet" "subnet_1_3_2" {
  name                 = "subnet-1-3-2"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_3.name
  address_prefixes     = ["10.8.2.0/24"]
}

resource "azurerm_subnet" "subnet_1_3_3" {
  name                 = "subnet-1-3-3"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_3.name
  address_prefixes     = ["10.8.3.0/24"]
}

resource "azurerm_subnet" "subnet_1_3_4" {
  name                 = "subnet-1-3-4"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_3.name
  address_prefixes     = ["10.8.4.0/24"]
}

resource "azurerm_subnet" "subnet_1_3_5" {
  name                 = "subnet-1-3-5"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_3.name
  address_prefixes     = ["10.8.5.0/24"]
}

resource "azurerm_subnet" "subnet_1_3_6" {
  name                 = "subnet-1-3-6"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_3.name
  address_prefixes     = ["10.8.6.0/24"]
}

resource "azurerm_subnet" "subnet_1_3_7" {
  name                 = "subnet-1-3-7"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_3.name
  address_prefixes     = ["10.8.7.0/24"]
}

resource "azurerm_subnet" "subnet_1_3_8" {
  name                 = "subnet-1-3-8"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_3.name
  address_prefixes     = ["10.8.8.0/24"]
}

resource "azurerm_subnet" "subnet_1_3_9" {
  name                 = "subnet-1-3-9"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_3.name
  address_prefixes     = ["10.8.9.0/24"]
}

resource "azurerm_subnet" "subnet_1_3_10" {
  name                 = "subnet-1-3-10"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_3.name
  address_prefixes     = ["10.8.10.0/24"]
}

resource "azurerm_subnet" "subnet_1_3_11" {
  name                 = "subnet-1-3-11"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_3.name
  address_prefixes     = ["10.8.11.0/24"]
}

resource "azurerm_subnet" "subnet_1_3_12" {
  name                 = "subnet-1-3-12"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_3.name
  address_prefixes     = ["10.8.12.0/24"]
}

resource "azurerm_subnet" "subnet_1_3_13" {
  name                 = "subnet-1-3-13"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_3.name
  address_prefixes     = ["10.8.13.0/24"]
}

resource "azurerm_subnet" "subnet_1_3_14" {
  name                 = "subnet-1-3-14"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_3.name
  address_prefixes     = ["10.8.14.0/24"]
}

resource "azurerm_subnet" "subnet_1_3_15" {
  name                 = "subnet-1-3-15"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_3.name
  address_prefixes     = ["10.8.15.0/24"]
}

resource "azurerm_subnet" "subnet_1_3_16" {
  name                 = "subnet-1-3-16"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_3.name
  address_prefixes     = ["10.8.16.0/24"]
}

resource "azurerm_subnet" "subnet_1_3_17" {
  name                 = "subnet-1-3-17"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_3.name
  address_prefixes     = ["10.8.17.0/24"]
}

resource "azurerm_subnet" "subnet_1_3_18" {
  name                 = "subnet-1-3-18"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_3.name
  address_prefixes     = ["10.8.18.0/24"]
}

resource "azurerm_subnet" "subnet_1_3_19" {
  name                 = "subnet-1-3-19"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_3.name
  address_prefixes     = ["10.8.19.0/24"]
}

resource "azurerm_subnet" "subnet_1_3_20" {
  name                 = "subnet-1-3-20"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_3.name
  address_prefixes     = ["10.8.20.0/24"]
}

resource "azurerm_subnet" "subnet_1_3_21" {
  name                 = "subnet-1-3-21"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_3.name
  address_prefixes     = ["10.8.21.0/24"]
}

resource "azurerm_subnet" "subnet_1_3_22" {
  name                 = "subnet-1-3-22"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_3.name
  address_prefixes     = ["10.8.22.0/24"]
}

resource "azurerm_subnet" "subnet_1_3_23" {
  name                 = "subnet-1-3-23"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_3.name
  address_prefixes     = ["10.8.23.0/24"]
}

resource "azurerm_subnet" "subnet_1_3_24" {
  name                 = "subnet-1-3-24"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_3.name
  address_prefixes     = ["10.8.24.0/24"]
}

resource "azurerm_subnet" "subnet_1_3_25" {
  name                 = "subnet-1-3-25"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_3.name
  address_prefixes     = ["10.8.25.0/24"]
}

resource "azurerm_subnet" "subnet_1_3_26" {
  name                 = "subnet-1-3-26"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_3.name
  address_prefixes     = ["10.8.26.0/24"]
}

resource "azurerm_subnet" "subnet_1_3_27" {
  name                 = "subnet-1-3-27"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_3.name
  address_prefixes     = ["10.8.27.0/24"]
}

resource "azurerm_subnet" "subnet_1_3_28" {
  name                 = "subnet-1-3-28"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_3.name
  address_prefixes     = ["10.8.28.0/24"]
}

resource "azurerm_subnet" "subnet_1_3_29" {
  name                 = "subnet-1-3-29"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_3.name
  address_prefixes     = ["10.8.29.0/24"]
}

resource "azurerm_subnet" "subnet_1_3_30" {
  name                 = "subnet-1-3-30"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_3.name
  address_prefixes     = ["10.8.30.0/24"]
}

resource "azurerm_subnet" "subnet_1_3_31" {
  name                 = "subnet-1-3-31"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_3.name
  address_prefixes     = ["10.8.31.0/24"]
}

resource "azurerm_subnet" "subnet_1_3_32" {
  name                 = "subnet-1-3-32"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_3.name
  address_prefixes     = ["10.8.32.0/24"]
}

resource "azurerm_subnet" "subnet_1_3_33" {
  name                 = "subnet-1-3-33"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_3.name
  address_prefixes     = ["10.8.33.0/24"]
}

resource "azurerm_subnet" "subnet_1_3_34" {
  name                 = "subnet-1-3-34"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_3.name
  address_prefixes     = ["10.8.34.0/24"]
}

resource "azurerm_subnet" "subnet_1_3_35" {
  name                 = "subnet-1-3-35"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_3.name
  address_prefixes     = ["10.8.35.0/24"]
}

resource "azurerm_subnet" "subnet_1_3_36" {
  name                 = "subnet-1-3-36"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_3.name
  address_prefixes     = ["10.8.36.0/24"]
}

resource "azurerm_subnet" "subnet_1_3_37" {
  name                 = "subnet-1-3-37"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_3.name
  address_prefixes     = ["10.8.37.0/24"]
}

resource "azurerm_subnet" "subnet_1_3_38" {
  name                 = "subnet-1-3-38"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_3.name
  address_prefixes     = ["10.8.38.0/24"]
}

resource "azurerm_virtual_network" "vnet_1_4" {
  name                = "vnet-1-4"
  location            = azurerm_resource_group.rg_1.location
  resource_group_name = azurerm_resource_group.rg_1.name
  address_space       = ["10.9.0.0/16"]
}

resource "azurerm_subnet" "subnet_1_4_0" {
  name                 = "subnet-1-4-0"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_4.name
  address_prefixes     = ["10.9.0.0/24"]
}

resource "azurerm_subnet" "subnet_1_4_1" {
  name                 = "subnet-1-4-1"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_4.name
  address_prefixes     = ["10.9.1.0/24"]
}

resource "azurerm_subnet" "subnet_1_4_2" {
  name                 = "subnet-1-4-2"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_4.name
  address_prefixes     = ["10.9.2.0/24"]
}

resource "azurerm_subnet" "subnet_1_4_3" {
  name                 = "subnet-1-4-3"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_4.name
  address_prefixes     = ["10.9.3.0/24"]
}

resource "azurerm_subnet" "subnet_1_4_4" {
  name                 = "subnet-1-4-4"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_4.name
  address_prefixes     = ["10.9.4.0/24"]
}

resource "azurerm_subnet" "subnet_1_4_5" {
  name                 = "subnet-1-4-5"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_4.name
  address_prefixes     = ["10.9.5.0/24"]
}

resource "azurerm_subnet" "subnet_1_4_6" {
  name                 = "subnet-1-4-6"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_4.name
  address_prefixes     = ["10.9.6.0/24"]
}

resource "azurerm_subnet" "subnet_1_4_7" {
  name                 = "subnet-1-4-7"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_4.name
  address_prefixes     = ["10.9.7.0/24"]
}

resource "azurerm_subnet" "subnet_1_4_8" {
  name                 = "subnet-1-4-8"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_4.name
  address_prefixes     = ["10.9.8.0/24"]
}

resource "azurerm_subnet" "subnet_1_4_9" {
  name                 = "subnet-1-4-9"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_4.name
  address_prefixes     = ["10.9.9.0/24"]
}

resource "azurerm_subnet" "subnet_1_4_10" {
  name                 = "subnet-1-4-10"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_4.name
  address_prefixes     = ["10.9.10.0/24"]
}

resource "azurerm_subnet" "subnet_1_4_11" {
  name                 = "subnet-1-4-11"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_4.name
  address_prefixes     = ["10.9.11.0/24"]
}

resource "azurerm_subnet" "subnet_1_4_12" {
  name                 = "subnet-1-4-12"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_4.name
  address_prefixes     = ["10.9.12.0/24"]
}

resource "azurerm_subnet" "subnet_1_4_13" {
  name                 = "subnet-1-4-13"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_4.name
  address_prefixes     = ["10.9.13.0/24"]
}

resource "azurerm_subnet" "subnet_1_4_14" {
  name                 = "subnet-1-4-14"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_4.name
  address_prefixes     = ["10.9.14.0/24"]
}

resource "azurerm_subnet" "subnet_1_4_15" {
  name                 = "subnet-1-4-15"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_4.name
  address_prefixes     = ["10.9.15.0/24"]
}

resource "azurerm_subnet" "subnet_1_4_16" {
  name                 = "subnet-1-4-16"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_4.name
  address_prefixes     = ["10.9.16.0/24"]
}

resource "azurerm_subnet" "subnet_1_4_17" {
  name                 = "subnet-1-4-17"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_4.name
  address_prefixes     = ["10.9.17.0/24"]
}

resource "azurerm_subnet" "subnet_1_4_18" {
  name                 = "subnet-1-4-18"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_4.name
  address_prefixes     = ["10.9.18.0/24"]
}

resource "azurerm_subnet" "subnet_1_4_19" {
  name                 = "subnet-1-4-19"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_4.name
  address_prefixes     = ["10.9.19.0/24"]
}

resource "azurerm_subnet" "subnet_1_4_20" {
  name                 = "subnet-1-4-20"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_4.name
  address_prefixes     = ["10.9.20.0/24"]
}

resource "azurerm_subnet" "subnet_1_4_21" {
  name                 = "subnet-1-4-21"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_4.name
  address_prefixes     = ["10.9.21.0/24"]
}

resource "azurerm_subnet" "subnet_1_4_22" {
  name                 = "subnet-1-4-22"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_4.name
  address_prefixes     = ["10.9.22.0/24"]
}

resource "azurerm_subnet" "subnet_1_4_23" {
  name                 = "subnet-1-4-23"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_4.name
  address_prefixes     = ["10.9.23.0/24"]
}

resource "azurerm_subnet" "subnet_1_4_24" {
  name                 = "subnet-1-4-24"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_4.name
  address_prefixes     = ["10.9.24.0/24"]
}

resource "azurerm_subnet" "subnet_1_4_25" {
  name                 = "subnet-1-4-25"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_4.name
  address_prefixes     = ["10.9.25.0/24"]
}

resource "azurerm_subnet" "subnet_1_4_26" {
  name                 = "subnet-1-4-26"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_4.name
  address_prefixes     = ["10.9.26.0/24"]
}

resource "azurerm_subnet" "subnet_1_4_27" {
  name                 = "subnet-1-4-27"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_4.name
  address_prefixes     = ["10.9.27.0/24"]
}

resource "azurerm_subnet" "subnet_1_4_28" {
  name                 = "subnet-1-4-28"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_4.name
  address_prefixes     = ["10.9.28.0/24"]
}

resource "azurerm_subnet" "subnet_1_4_29" {
  name                 = "subnet-1-4-29"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_4.name
  address_prefixes     = ["10.9.29.0/24"]
}

resource "azurerm_subnet" "subnet_1_4_30" {
  name                 = "subnet-1-4-30"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_4.name
  address_prefixes     = ["10.9.30.0/24"]
}

resource "azurerm_subnet" "subnet_1_4_31" {
  name                 = "subnet-1-4-31"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_4.name
  address_prefixes     = ["10.9.31.0/24"]
}

resource "azurerm_subnet" "subnet_1_4_32" {
  name                 = "subnet-1-4-32"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_4.name
  address_prefixes     = ["10.9.32.0/24"]
}

resource "azurerm_subnet" "subnet_1_4_33" {
  name                 = "subnet-1-4-33"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_4.name
  address_prefixes     = ["10.9.33.0/24"]
}

resource "azurerm_subnet" "subnet_1_4_34" {
  name                 = "subnet-1-4-34"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_4.name
  address_prefixes     = ["10.9.34.0/24"]
}

resource "azurerm_subnet" "subnet_1_4_35" {
  name                 = "subnet-1-4-35"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_4.name
  address_prefixes     = ["10.9.35.0/24"]
}

resource "azurerm_subnet" "subnet_1_4_36" {
  name                 = "subnet-1-4-36"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_4.name
  address_prefixes     = ["10.9.36.0/24"]
}

resource "azurerm_subnet" "subnet_1_4_37" {
  name                 = "subnet-1-4-37"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_4.name
  address_prefixes     = ["10.9.37.0/24"]
}

resource "azurerm_subnet" "subnet_1_4_38" {
  name                 = "subnet-1-4-38"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1_4.name
  address_prefixes     = ["10.9.38.0/24"]
}

resource "azurerm_resource_group" "rg_2" {
  name     = "rg-2"
  location = "eastus2"
}

resource "azurerm_virtual_network" "vnet_2_0" {
  name                = "vnet-2-0"
  location            = azurerm_resource_group.rg_2.location
  resource_group_name = azurerm_resource_group.rg_2.name
  address_space       = ["10.10.0.0/16"]
}

resource "azurerm_subnet" "subnet_2_0_0" {
  name                 = "subnet-2-0-0"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_0.name
  address_prefixes     = ["10.10.0.0/24"]
}

resource "azurerm_subnet" "subnet_2_0_1" {
  name                 = "subnet-2-0-1"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_0.name
  address_prefixes     = ["10.10.1.0/24"]
}

resource "azurerm_subnet" "subnet_2_0_2" {
  name                 = "subnet-2-0-2"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_0.name
  address_prefixes     = ["10.10.2.0/24"]
}

resource "azurerm_subnet" "subnet_2_0_3" {
  name                 = "subnet-2-0-3"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_0.name
  address_prefixes     = ["10.10.3.0/24"]
}

resource "azurerm_subnet" "subnet_2_0_4" {
  name                 = "subnet-2-0-4"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_0.name
  address_prefixes     = ["10.10.4.0/24"]
}

resource "azurerm_subnet" "subnet_2_0_5" {
  name                 = "subnet-2-0-5"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_0.name
  address_prefixes     = ["10.10.5.0/24"]
}

resource "azurerm_subnet" "subnet_2_0_6" {
  name                 = "subnet-2-0-6"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_0.name
  address_prefixes     = ["10.10.6.0/24"]
}

resource "azurerm_subnet" "subnet_2_0_7" {
  name                 = "subnet-2-0-7"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_0.name
  address_prefixes     = ["10.10.7.0/24"]
}

resource "azurerm_subnet" "subnet_2_0_8" {
  name                 = "subnet-2-0-8"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_0.name
  address_prefixes     = ["10.10.8.0/24"]
}

resource "azurerm_subnet" "subnet_2_0_9" {
  name                 = "subnet-2-0-9"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_0.name
  address_prefixes     = ["10.10.9.0/24"]
}

resource "azurerm_subnet" "subnet_2_0_10" {
  name                 = "subnet-2-0-10"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_0.name
  address_prefixes     = ["10.10.10.0/24"]
}

resource "azurerm_subnet" "subnet_2_0_11" {
  name                 = "subnet-2-0-11"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_0.name
  address_prefixes     = ["10.10.11.0/24"]
}

resource "azurerm_subnet" "subnet_2_0_12" {
  name                 = "subnet-2-0-12"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_0.name
  address_prefixes     = ["10.10.12.0/24"]
}

resource "azurerm_subnet" "subnet_2_0_13" {
  name                 = "subnet-2-0-13"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_0.name
  address_prefixes     = ["10.10.13.0/24"]
}

resource "azurerm_subnet" "subnet_2_0_14" {
  name                 = "subnet-2-0-14"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_0.name
  address_prefixes     = ["10.10.14.0/24"]
}

resource "azurerm_subnet" "subnet_2_0_15" {
  name                 = "subnet-2-0-15"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_0.name
  address_prefixes     = ["10.10.15.0/24"]
}

resource "azurerm_subnet" "subnet_2_0_16" {
  name                 = "subnet-2-0-16"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_0.name
  address_prefixes     = ["10.10.16.0/24"]
}

resource "azurerm_subnet" "subnet_2_0_17" {
  name                 = "subnet-2-0-17"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_0.name
  address_prefixes     = ["10.10.17.0/24"]
}

resource "azurerm_subnet" "subnet_2_0_18" {
  name                 = "subnet-2-0-18"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_0.name
  address_prefixes     = ["10.10.18.0/24"]
}

resource "azurerm_subnet" "subnet_2_0_19" {
  name                 = "subnet-2-0-19"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_0.name
  address_prefixes     = ["10.10.19.0/24"]
}

resource "azurerm_subnet" "subnet_2_0_20" {
  name                 = "subnet-2-0-20"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_0.name
  address_prefixes     = ["10.10.20.0/24"]
}

resource "azurerm_subnet" "subnet_2_0_21" {
  name                 = "subnet-2-0-21"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_0.name
  address_prefixes     = ["10.10.21.0/24"]
}

resource "azurerm_subnet" "subnet_2_0_22" {
  name                 = "subnet-2-0-22"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_0.name
  address_prefixes     = ["10.10.22.0/24"]
}

resource "azurerm_subnet" "subnet_2_0_23" {
  name                 = "subnet-2-0-23"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_0.name
  address_prefixes     = ["10.10.23.0/24"]
}

resource "azurerm_subnet" "subnet_2_0_24" {
  name                 = "subnet-2-0-24"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_0.name
  address_prefixes     = ["10.10.24.0/24"]
}

resource "azurerm_subnet" "subnet_2_0_25" {
  name                 = "subnet-2-0-25"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_0.name
  address_prefixes     = ["10.10.25.0/24"]
}

resource "azurerm_subnet" "subnet_2_0_26" {
  name                 = "subnet-2-0-26"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_0.name
  address_prefixes     = ["10.10.26.0/24"]
}

resource "azurerm_subnet" "subnet_2_0_27" {
  name                 = "subnet-2-0-27"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_0.name
  address_prefixes     = ["10.10.27.0/24"]
}

resource "azurerm_subnet" "subnet_2_0_28" {
  name                 = "subnet-2-0-28"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_0.name
  address_prefixes     = ["10.10.28.0/24"]
}

resource "azurerm_subnet" "subnet_2_0_29" {
  name                 = "subnet-2-0-29"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_0.name
  address_prefixes     = ["10.10.29.0/24"]
}

resource "azurerm_subnet" "subnet_2_0_30" {
  name                 = "subnet-2-0-30"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_0.name
  address_prefixes     = ["10.10.30.0/24"]
}

resource "azurerm_subnet" "subnet_2_0_31" {
  name                 = "subnet-2-0-31"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_0.name
  address_prefixes     = ["10.10.31.0/24"]
}

resource "azurerm_subnet" "subnet_2_0_32" {
  name                 = "subnet-2-0-32"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_0.name
  address_prefixes     = ["10.10.32.0/24"]
}

resource "azurerm_subnet" "subnet_2_0_33" {
  name                 = "subnet-2-0-33"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_0.name
  address_prefixes     = ["10.10.33.0/24"]
}

resource "azurerm_subnet" "subnet_2_0_34" {
  name                 = "subnet-2-0-34"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_0.name
  address_prefixes     = ["10.10.34.0/24"]
}

resource "azurerm_subnet" "subnet_2_0_35" {
  name                 = "subnet-2-0-35"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_0.name
  address_prefixes     = ["10.10.35.0/24"]
}

resource "azurerm_subnet" "subnet_2_0_36" {
  name                 = "subnet-2-0-36"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_0.name
  address_prefixes     = ["10.10.36.0/24"]
}

resource "azurerm_subnet" "subnet_2_0_37" {
  name                 = "subnet-2-0-37"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_0.name
  address_prefixes     = ["10.10.37.0/24"]
}

resource "azurerm_subnet" "subnet_2_0_38" {
  name                 = "subnet-2-0-38"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_0.name
  address_prefixes     = ["10.10.38.0/24"]
}

resource "azurerm_virtual_network" "vnet_2_1" {
  name                = "vnet-2-1"
  location            = azurerm_resource_group.rg_2.location
  resource_group_name = azurerm_resource_group.rg_2.name
  address_space       = ["10.11.0.0/16"]
}

resource "azurerm_subnet" "subnet_2_1_0" {
  name                 = "subnet-2-1-0"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_1.name
  address_prefixes     = ["10.11.0.0/24"]
}

resource "azurerm_subnet" "subnet_2_1_1" {
  name                 = "subnet-2-1-1"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_1.name
  address_prefixes     = ["10.11.1.0/24"]
}

resource "azurerm_subnet" "subnet_2_1_2" {
  name                 = "subnet-2-1-2"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_1.name
  address_prefixes     = ["10.11.2.0/24"]
}

resource "azurerm_subnet" "subnet_2_1_3" {
  name                 = "subnet-2-1-3"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_1.name
  address_prefixes     = ["10.11.3.0/24"]
}

resource "azurerm_subnet" "subnet_2_1_4" {
  name                 = "subnet-2-1-4"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_1.name
  address_prefixes     = ["10.11.4.0/24"]
}

resource "azurerm_subnet" "subnet_2_1_5" {
  name                 = "subnet-2-1-5"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_1.name
  address_prefixes     = ["10.11.5.0/24"]
}

resource "azurerm_subnet" "subnet_2_1_6" {
  name                 = "subnet-2-1-6"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_1.name
  address_prefixes     = ["10.11.6.0/24"]
}

resource "azurerm_subnet" "subnet_2_1_7" {
  name                 = "subnet-2-1-7"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_1.name
  address_prefixes     = ["10.11.7.0/24"]
}

resource "azurerm_subnet" "subnet_2_1_8" {
  name                 = "subnet-2-1-8"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_1.name
  address_prefixes     = ["10.11.8.0/24"]
}

resource "azurerm_subnet" "subnet_2_1_9" {
  name                 = "subnet-2-1-9"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_1.name
  address_prefixes     = ["10.11.9.0/24"]
}

resource "azurerm_subnet" "subnet_2_1_10" {
  name                 = "subnet-2-1-10"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_1.name
  address_prefixes     = ["10.11.10.0/24"]
}

resource "azurerm_subnet" "subnet_2_1_11" {
  name                 = "subnet-2-1-11"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_1.name
  address_prefixes     = ["10.11.11.0/24"]
}

resource "azurerm_subnet" "subnet_2_1_12" {
  name                 = "subnet-2-1-12"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_1.name
  address_prefixes     = ["10.11.12.0/24"]
}

resource "azurerm_subnet" "subnet_2_1_13" {
  name                 = "subnet-2-1-13"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_1.name
  address_prefixes     = ["10.11.13.0/24"]
}

resource "azurerm_subnet" "subnet_2_1_14" {
  name                 = "subnet-2-1-14"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_1.name
  address_prefixes     = ["10.11.14.0/24"]
}

resource "azurerm_subnet" "subnet_2_1_15" {
  name                 = "subnet-2-1-15"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_1.name
  address_prefixes     = ["10.11.15.0/24"]
}

resource "azurerm_subnet" "subnet_2_1_16" {
  name                 = "subnet-2-1-16"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_1.name
  address_prefixes     = ["10.11.16.0/24"]
}

resource "azurerm_subnet" "subnet_2_1_17" {
  name                 = "subnet-2-1-17"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_1.name
  address_prefixes     = ["10.11.17.0/24"]
}

resource "azurerm_subnet" "subnet_2_1_18" {
  name                 = "subnet-2-1-18"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_1.name
  address_prefixes     = ["10.11.18.0/24"]
}

resource "azurerm_subnet" "subnet_2_1_19" {
  name                 = "subnet-2-1-19"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_1.name
  address_prefixes     = ["10.11.19.0/24"]
}

resource "azurerm_subnet" "subnet_2_1_20" {
  name                 = "subnet-2-1-20"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_1.name
  address_prefixes     = ["10.11.20.0/24"]
}

resource "azurerm_subnet" "subnet_2_1_21" {
  name                 = "subnet-2-1-21"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_1.name
  address_prefixes     = ["10.11.21.0/24"]
}

resource "azurerm_subnet" "subnet_2_1_22" {
  name                 = "subnet-2-1-22"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_1.name
  address_prefixes     = ["10.11.22.0/24"]
}

resource "azurerm_subnet" "subnet_2_1_23" {
  name                 = "subnet-2-1-23"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_1.name
  address_prefixes     = ["10.11.23.0/24"]
}

resource "azurerm_subnet" "subnet_2_1_24" {
  name                 = "subnet-2-1-24"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_1.name
  address_prefixes     = ["10.11.24.0/24"]
}

resource "azurerm_subnet" "subnet_2_1_25" {
  name                 = "subnet-2-1-25"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_1.name
  address_prefixes     = ["10.11.25.0/24"]
}

resource "azurerm_subnet" "subnet_2_1_26" {
  name                 = "subnet-2-1-26"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_1.name
  address_prefixes     = ["10.11.26.0/24"]
}

resource "azurerm_subnet" "subnet_2_1_27" {
  name                 = "subnet-2-1-27"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_1.name
  address_prefixes     = ["10.11.27.0/24"]
}

resource "azurerm_subnet" "subnet_2_1_28" {
  name                 = "subnet-2-1-28"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_1.name
  address_prefixes     = ["10.11.28.0/24"]
}

resource "azurerm_subnet" "subnet_2_1_29" {
  name                 = "subnet-2-1-29"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_1.name
  address_prefixes     = ["10.11.29.0/24"]
}

resource "azurerm_subnet" "subnet_2_1_30" {
  name                 = "subnet-2-1-30"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_1.name
  address_prefixes     = ["10.11.30.0/24"]
}

resource "azurerm_subnet" "subnet_2_1_31" {
  name                 = "subnet-2-1-31"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_1.name
  address_prefixes     = ["10.11.31.0/24"]
}

resource "azurerm_subnet" "subnet_2_1_32" {
  name                 = "subnet-2-1-32"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_1.name
  address_prefixes     = ["10.11.32.0/24"]
}

resource "azurerm_subnet" "subnet_2_1_33" {
  name                 = "subnet-2-1-33"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_1.name
  address_prefixes     = ["10.11.33.0/24"]
}

resource "azurerm_subnet" "subnet_2_1_34" {
  name                 = "subnet-2-1-34"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_1.name
  address_prefixes     = ["10.11.34.0/24"]
}

resource "azurerm_subnet" "subnet_2_1_35" {
  name                 = "subnet-2-1-35"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_1.name
  address_prefixes     = ["10.11.35.0/24"]
}

resource "azurerm_subnet" "subnet_2_1_36" {
  name                 = "subnet-2-1-36"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_1.name
  address_prefixes     = ["10.11.36.0/24"]
}

resource "azurerm_subnet" "subnet_2_1_37" {
  name                 = "subnet-2-1-37"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_1.name
  address_prefixes     = ["10.11.37.0/24"]
}

resource "azurerm_subnet" "subnet_2_1_38" {
  name                 = "subnet-2-1-38"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_1.name
  address_prefixes     = ["10.11.38.0/24"]
}

resource "azurerm_virtual_network" "vnet_2_2" {
  name                = "vnet-2-2"
  location            = azurerm_resource_group.rg_2.location
  resource_group_name = azurerm_resource_group.rg_2.name
  address_space       = ["10.12.0.0/16"]
}

resource "azurerm_subnet" "subnet_2_2_0" {
  name                 = "subnet-2-2-0"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_2.name
  address_prefixes     = ["10.12.0.0/24"]
}

resource "azurerm_subnet" "subnet_2_2_1" {
  name                 = "subnet-2-2-1"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_2.name
  address_prefixes     = ["10.12.1.0/24"]
}

resource "azurerm_subnet" "subnet_2_2_2" {
  name                 = "subnet-2-2-2"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_2.name
  address_prefixes     = ["10.12.2.0/24"]
}

resource "azurerm_subnet" "subnet_2_2_3" {
  name                 = "subnet-2-2-3"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_2.name
  address_prefixes     = ["10.12.3.0/24"]
}

resource "azurerm_subnet" "subnet_2_2_4" {
  name                 = "subnet-2-2-4"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_2.name
  address_prefixes     = ["10.12.4.0/24"]
}

resource "azurerm_subnet" "subnet_2_2_5" {
  name                 = "subnet-2-2-5"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_2.name
  address_prefixes     = ["10.12.5.0/24"]
}

resource "azurerm_subnet" "subnet_2_2_6" {
  name                 = "subnet-2-2-6"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_2.name
  address_prefixes     = ["10.12.6.0/24"]
}

resource "azurerm_subnet" "subnet_2_2_7" {
  name                 = "subnet-2-2-7"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_2.name
  address_prefixes     = ["10.12.7.0/24"]
}

resource "azurerm_subnet" "subnet_2_2_8" {
  name                 = "subnet-2-2-8"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_2.name
  address_prefixes     = ["10.12.8.0/24"]
}

resource "azurerm_subnet" "subnet_2_2_9" {
  name                 = "subnet-2-2-9"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_2.name
  address_prefixes     = ["10.12.9.0/24"]
}

resource "azurerm_subnet" "subnet_2_2_10" {
  name                 = "subnet-2-2-10"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_2.name
  address_prefixes     = ["10.12.10.0/24"]
}

resource "azurerm_subnet" "subnet_2_2_11" {
  name                 = "subnet-2-2-11"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_2.name
  address_prefixes     = ["10.12.11.0/24"]
}

resource "azurerm_subnet" "subnet_2_2_12" {
  name                 = "subnet-2-2-12"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_2.name
  address_prefixes     = ["10.12.12.0/24"]
}

resource "azurerm_subnet" "subnet_2_2_13" {
  name                 = "subnet-2-2-13"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_2.name
  address_prefixes     = ["10.12.13.0/24"]
}

resource "azurerm_subnet" "subnet_2_2_14" {
  name                 = "subnet-2-2-14"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_2.name
  address_prefixes     = ["10.12.14.0/24"]
}

resource "azurerm_subnet" "subnet_2_2_15" {
  name                 = "subnet-2-2-15"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_2.name
  address_prefixes     = ["10.12.15.0/24"]
}

resource "azurerm_subnet" "subnet_2_2_16" {
  name                 = "subnet-2-2-16"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_2.name
  address_prefixes     = ["10.12.16.0/24"]
}

resource "azurerm_subnet" "subnet_2_2_17" {
  name                 = "subnet-2-2-17"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_2.name
  address_prefixes     = ["10.12.17.0/24"]
}

resource "azurerm_subnet" "subnet_2_2_18" {
  name                 = "subnet-2-2-18"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_2.name
  address_prefixes     = ["10.12.18.0/24"]
}

resource "azurerm_subnet" "subnet_2_2_19" {
  name                 = "subnet-2-2-19"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_2.name
  address_prefixes     = ["10.12.19.0/24"]
}

resource "azurerm_subnet" "subnet_2_2_20" {
  name                 = "subnet-2-2-20"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_2.name
  address_prefixes     = ["10.12.20.0/24"]
}

resource "azurerm_subnet" "subnet_2_2_21" {
  name                 = "subnet-2-2-21"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_2.name
  address_prefixes     = ["10.12.21.0/24"]
}

resource "azurerm_subnet" "subnet_2_2_22" {
  name                 = "subnet-2-2-22"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_2.name
  address_prefixes     = ["10.12.22.0/24"]
}

resource "azurerm_subnet" "subnet_2_2_23" {
  name                 = "subnet-2-2-23"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_2.name
  address_prefixes     = ["10.12.23.0/24"]
}

resource "azurerm_subnet" "subnet_2_2_24" {
  name                 = "subnet-2-2-24"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_2.name
  address_prefixes     = ["10.12.24.0/24"]
}

resource "azurerm_subnet" "subnet_2_2_25" {
  name                 = "subnet-2-2-25"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_2.name
  address_prefixes     = ["10.12.25.0/24"]
}

resource "azurerm_subnet" "subnet_2_2_26" {
  name                 = "subnet-2-2-26"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_2.name
  address_prefixes     = ["10.12.26.0/24"]
}

resource "azurerm_subnet" "subnet_2_2_27" {
  name                 = "subnet-2-2-27"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_2.name
  address_prefixes     = ["10.12.27.0/24"]
}

resource "azurerm_subnet" "subnet_2_2_28" {
  name                 = "subnet-2-2-28"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_2.name
  address_prefixes     = ["10.12.28.0/24"]
}

resource "azurerm_subnet" "subnet_2_2_29" {
  name                 = "subnet-2-2-29"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_2.name
  address_prefixes     = ["10.12.29.0/24"]
}

resource "azurerm_subnet" "subnet_2_2_30" {
  name                 = "subnet-2-2-30"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_2.name
  address_prefixes     = ["10.12.30.0/24"]
}

resource "azurerm_subnet" "subnet_2_2_31" {
  name                 = "subnet-2-2-31"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_2.name
  address_prefixes     = ["10.12.31.0/24"]
}

resource "azurerm_subnet" "subnet_2_2_32" {
  name                 = "subnet-2-2-32"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_2.name
  address_prefixes     = ["10.12.32.0/24"]
}

resource "azurerm_subnet" "subnet_2_2_33" {
  name                 = "subnet-2-2-33"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_2.name
  address_prefixes     = ["10.12.33.0/24"]
}

resource "azurerm_subnet" "subnet_2_2_34" {
  name                 = "subnet-2-2-34"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_2.name
  address_prefixes     = ["10.12.34.0/24"]
}

resource "azurerm_subnet" "subnet_2_2_35" {
  name                 = "subnet-2-2-35"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_2.name
  address_prefixes     = ["10.12.35.0/24"]
}

resource "azurerm_subnet" "subnet_2_2_36" {
  name                 = "subnet-2-2-36"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_2.name
  address_prefixes     = ["10.12.36.0/24"]
}

resource "azurerm_subnet" "subnet_2_2_37" {
  name                 = "subnet-2-2-37"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_2.name
  address_prefixes     = ["10.12.37.0/24"]
}

resource "azurerm_subnet" "subnet_2_2_38" {
  name                 = "subnet-2-2-38"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_2.name
  address_prefixes     = ["10.12.38.0/24"]
}

resource "azurerm_virtual_network" "vnet_2_3" {
  name                = "vnet-2-3"
  location            = azurerm_resource_group.rg_2.location
  resource_group_name = azurerm_resource_group.rg_2.name
  address_space       = ["10.13.0.0/16"]
}

resource "azurerm_subnet" "subnet_2_3_0" {
  name                 = "subnet-2-3-0"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_3.name
  address_prefixes     = ["10.13.0.0/24"]
}

resource "azurerm_subnet" "subnet_2_3_1" {
  name                 = "subnet-2-3-1"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_3.name
  address_prefixes     = ["10.13.1.0/24"]
}

resource "azurerm_subnet" "subnet_2_3_2" {
  name                 = "subnet-2-3-2"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_3.name
  address_prefixes     = ["10.13.2.0/24"]
}

resource "azurerm_subnet" "subnet_2_3_3" {
  name                 = "subnet-2-3-3"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_3.name
  address_prefixes     = ["10.13.3.0/24"]
}

resource "azurerm_subnet" "subnet_2_3_4" {
  name                 = "subnet-2-3-4"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_3.name
  address_prefixes     = ["10.13.4.0/24"]
}

resource "azurerm_subnet" "subnet_2_3_5" {
  name                 = "subnet-2-3-5"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_3.name
  address_prefixes     = ["10.13.5.0/24"]
}

resource "azurerm_subnet" "subnet_2_3_6" {
  name                 = "subnet-2-3-6"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_3.name
  address_prefixes     = ["10.13.6.0/24"]
}

resource "azurerm_subnet" "subnet_2_3_7" {
  name                 = "subnet-2-3-7"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_3.name
  address_prefixes     = ["10.13.7.0/24"]
}

resource "azurerm_subnet" "subnet_2_3_8" {
  name                 = "subnet-2-3-8"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_3.name
  address_prefixes     = ["10.13.8.0/24"]
}

resource "azurerm_subnet" "subnet_2_3_9" {
  name                 = "subnet-2-3-9"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_3.name
  address_prefixes     = ["10.13.9.0/24"]
}

resource "azurerm_subnet" "subnet_2_3_10" {
  name                 = "subnet-2-3-10"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_3.name
  address_prefixes     = ["10.13.10.0/24"]
}

resource "azurerm_subnet" "subnet_2_3_11" {
  name                 = "subnet-2-3-11"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_3.name
  address_prefixes     = ["10.13.11.0/24"]
}

resource "azurerm_subnet" "subnet_2_3_12" {
  name                 = "subnet-2-3-12"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_3.name
  address_prefixes     = ["10.13.12.0/24"]
}

resource "azurerm_subnet" "subnet_2_3_13" {
  name                 = "subnet-2-3-13"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_3.name
  address_prefixes     = ["10.13.13.0/24"]
}

resource "azurerm_subnet" "subnet_2_3_14" {
  name                 = "subnet-2-3-14"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_3.name
  address_prefixes     = ["10.13.14.0/24"]
}

resource "azurerm_subnet" "subnet_2_3_15" {
  name                 = "subnet-2-3-15"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_3.name
  address_prefixes     = ["10.13.15.0/24"]
}

resource "azurerm_subnet" "subnet_2_3_16" {
  name                 = "subnet-2-3-16"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_3.name
  address_prefixes     = ["10.13.16.0/24"]
}

resource "azurerm_subnet" "subnet_2_3_17" {
  name                 = "subnet-2-3-17"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_3.name
  address_prefixes     = ["10.13.17.0/24"]
}

resource "azurerm_subnet" "subnet_2_3_18" {
  name                 = "subnet-2-3-18"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_3.name
  address_prefixes     = ["10.13.18.0/24"]
}

resource "azurerm_subnet" "subnet_2_3_19" {
  name                 = "subnet-2-3-19"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_3.name
  address_prefixes     = ["10.13.19.0/24"]
}

resource "azurerm_subnet" "subnet_2_3_20" {
  name                 = "subnet-2-3-20"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_3.name
  address_prefixes     = ["10.13.20.0/24"]
}

resource "azurerm_subnet" "subnet_2_3_21" {
  name                 = "subnet-2-3-21"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_3.name
  address_prefixes     = ["10.13.21.0/24"]
}

resource "azurerm_subnet" "subnet_2_3_22" {
  name                 = "subnet-2-3-22"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_3.name
  address_prefixes     = ["10.13.22.0/24"]
}

resource "azurerm_subnet" "subnet_2_3_23" {
  name                 = "subnet-2-3-23"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_3.name
  address_prefixes     = ["10.13.23.0/24"]
}

resource "azurerm_subnet" "subnet_2_3_24" {
  name                 = "subnet-2-3-24"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_3.name
  address_prefixes     = ["10.13.24.0/24"]
}

resource "azurerm_subnet" "subnet_2_3_25" {
  name                 = "subnet-2-3-25"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_3.name
  address_prefixes     = ["10.13.25.0/24"]
}

resource "azurerm_subnet" "subnet_2_3_26" {
  name                 = "subnet-2-3-26"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_3.name
  address_prefixes     = ["10.13.26.0/24"]
}

resource "azurerm_subnet" "subnet_2_3_27" {
  name                 = "subnet-2-3-27"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_3.name
  address_prefixes     = ["10.13.27.0/24"]
}

resource "azurerm_subnet" "subnet_2_3_28" {
  name                 = "subnet-2-3-28"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_3.name
  address_prefixes     = ["10.13.28.0/24"]
}

resource "azurerm_subnet" "subnet_2_3_29" {
  name                 = "subnet-2-3-29"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_3.name
  address_prefixes     = ["10.13.29.0/24"]
}

resource "azurerm_subnet" "subnet_2_3_30" {
  name                 = "subnet-2-3-30"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_3.name
  address_prefixes     = ["10.13.30.0/24"]
}

resource "azurerm_subnet" "subnet_2_3_31" {
  name                 = "subnet-2-3-31"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_3.name
  address_prefixes     = ["10.13.31.0/24"]
}

resource "azurerm_subnet" "subnet_2_3_32" {
  name                 = "subnet-2-3-32"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_3.name
  address_prefixes     = ["10.13.32.0/24"]
}

resource "azurerm_subnet" "subnet_2_3_33" {
  name                 = "subnet-2-3-33"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_3.name
  address_prefixes     = ["10.13.33.0/24"]
}

resource "azurerm_subnet" "subnet_2_3_34" {
  name                 = "subnet-2-3-34"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_3.name
  address_prefixes     = ["10.13.34.0/24"]
}

resource "azurerm_subnet" "subnet_2_3_35" {
  name                 = "subnet-2-3-35"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_3.name
  address_prefixes     = ["10.13.35.0/24"]
}

resource "azurerm_subnet" "subnet_2_3_36" {
  name                 = "subnet-2-3-36"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_3.name
  address_prefixes     = ["10.13.36.0/24"]
}

resource "azurerm_subnet" "subnet_2_3_37" {
  name                 = "subnet-2-3-37"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_3.name
  address_prefixes     = ["10.13.37.0/24"]
}

resource "azurerm_subnet" "subnet_2_3_38" {
  name                 = "subnet-2-3-38"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_3.name
  address_prefixes     = ["10.13.38.0/24"]
}

resource "azurerm_virtual_network" "vnet_2_4" {
  name                = "vnet-2-4"
  location            = azurerm_resource_group.rg_2.location
  resource_group_name = azurerm_resource_group.rg_2.name
  address_space       = ["10.14.0.0/16"]
}

resource "azurerm_subnet" "subnet_2_4_0" {
  name                 = "subnet-2-4-0"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_4.name
  address_prefixes     = ["10.14.0.0/24"]
}

resource "azurerm_subnet" "subnet_2_4_1" {
  name                 = "subnet-2-4-1"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_4.name
  address_prefixes     = ["10.14.1.0/24"]
}

resource "azurerm_subnet" "subnet_2_4_2" {
  name                 = "subnet-2-4-2"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_4.name
  address_prefixes     = ["10.14.2.0/24"]
}

resource "azurerm_subnet" "subnet_2_4_3" {
  name                 = "subnet-2-4-3"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_4.name
  address_prefixes     = ["10.14.3.0/24"]
}

resource "azurerm_subnet" "subnet_2_4_4" {
  name                 = "subnet-2-4-4"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_4.name
  address_prefixes     = ["10.14.4.0/24"]
}

resource "azurerm_subnet" "subnet_2_4_5" {
  name                 = "subnet-2-4-5"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_4.name
  address_prefixes     = ["10.14.5.0/24"]
}

resource "azurerm_subnet" "subnet_2_4_6" {
  name                 = "subnet-2-4-6"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_4.name
  address_prefixes     = ["10.14.6.0/24"]
}

resource "azurerm_subnet" "subnet_2_4_7" {
  name                 = "subnet-2-4-7"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_4.name
  address_prefixes     = ["10.14.7.0/24"]
}

resource "azurerm_subnet" "subnet_2_4_8" {
  name                 = "subnet-2-4-8"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_4.name
  address_prefixes     = ["10.14.8.0/24"]
}

resource "azurerm_subnet" "subnet_2_4_9" {
  name                 = "subnet-2-4-9"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_4.name
  address_prefixes     = ["10.14.9.0/24"]
}

resource "azurerm_subnet" "subnet_2_4_10" {
  name                 = "subnet-2-4-10"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_4.name
  address_prefixes     = ["10.14.10.0/24"]
}

resource "azurerm_subnet" "subnet_2_4_11" {
  name                 = "subnet-2-4-11"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_4.name
  address_prefixes     = ["10.14.11.0/24"]
}

resource "azurerm_subnet" "subnet_2_4_12" {
  name                 = "subnet-2-4-12"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_4.name
  address_prefixes     = ["10.14.12.0/24"]
}

resource "azurerm_subnet" "subnet_2_4_13" {
  name                 = "subnet-2-4-13"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_4.name
  address_prefixes     = ["10.14.13.0/24"]
}

resource "azurerm_subnet" "subnet_2_4_14" {
  name                 = "subnet-2-4-14"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_4.name
  address_prefixes     = ["10.14.14.0/24"]
}

resource "azurerm_subnet" "subnet_2_4_15" {
  name                 = "subnet-2-4-15"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_4.name
  address_prefixes     = ["10.14.15.0/24"]
}

resource "azurerm_subnet" "subnet_2_4_16" {
  name                 = "subnet-2-4-16"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_4.name
  address_prefixes     = ["10.14.16.0/24"]
}

resource "azurerm_subnet" "subnet_2_4_17" {
  name                 = "subnet-2-4-17"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_4.name
  address_prefixes     = ["10.14.17.0/24"]
}

resource "azurerm_subnet" "subnet_2_4_18" {
  name                 = "subnet-2-4-18"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_4.name
  address_prefixes     = ["10.14.18.0/24"]
}

resource "azurerm_subnet" "subnet_2_4_19" {
  name                 = "subnet-2-4-19"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_4.name
  address_prefixes     = ["10.14.19.0/24"]
}

resource "azurerm_subnet" "subnet_2_4_20" {
  name                 = "subnet-2-4-20"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_4.name
  address_prefixes     = ["10.14.20.0/24"]
}

resource "azurerm_subnet" "subnet_2_4_21" {
  name                 = "subnet-2-4-21"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_4.name
  address_prefixes     = ["10.14.21.0/24"]
}

resource "azurerm_subnet" "subnet_2_4_22" {
  name                 = "subnet-2-4-22"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_4.name
  address_prefixes     = ["10.14.22.0/24"]
}

resource "azurerm_subnet" "subnet_2_4_23" {
  name                 = "subnet-2-4-23"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_4.name
  address_prefixes     = ["10.14.23.0/24"]
}

resource "azurerm_subnet" "subnet_2_4_24" {
  name                 = "subnet-2-4-24"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_4.name
  address_prefixes     = ["10.14.24.0/24"]
}

resource "azurerm_subnet" "subnet_2_4_25" {
  name                 = "subnet-2-4-25"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_4.name
  address_prefixes     = ["10.14.25.0/24"]
}

resource "azurerm_subnet" "subnet_2_4_26" {
  name                 = "subnet-2-4-26"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_4.name
  address_prefixes     = ["10.14.26.0/24"]
}

resource "azurerm_subnet" "subnet_2_4_27" {
  name                 = "subnet-2-4-27"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_4.name
  address_prefixes     = ["10.14.27.0/24"]
}

resource "azurerm_subnet" "subnet_2_4_28" {
  name                 = "subnet-2-4-28"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_4.name
  address_prefixes     = ["10.14.28.0/24"]
}

resource "azurerm_subnet" "subnet_2_4_29" {
  name                 = "subnet-2-4-29"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_4.name
  address_prefixes     = ["10.14.29.0/24"]
}

resource "azurerm_subnet" "subnet_2_4_30" {
  name                 = "subnet-2-4-30"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_4.name
  address_prefixes     = ["10.14.30.0/24"]
}

resource "azurerm_subnet" "subnet_2_4_31" {
  name                 = "subnet-2-4-31"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_4.name
  address_prefixes     = ["10.14.31.0/24"]
}

resource "azurerm_subnet" "subnet_2_4_32" {
  name                 = "subnet-2-4-32"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_4.name
  address_prefixes     = ["10.14.32.0/24"]
}

resource "azurerm_subnet" "subnet_2_4_33" {
  name                 = "subnet-2-4-33"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_4.name
  address_prefixes     = ["10.14.33.0/24"]
}

resource "azurerm_subnet" "subnet_2_4_34" {
  name                 = "subnet-2-4-34"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_4.name
  address_prefixes     = ["10.14.34.0/24"]
}

resource "azurerm_subnet" "subnet_2_4_35" {
  name                 = "subnet-2-4-35"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_4.name
  address_prefixes     = ["10.14.35.0/24"]
}

resource "azurerm_subnet" "subnet_2_4_36" {
  name                 = "subnet-2-4-36"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_4.name
  address_prefixes     = ["10.14.36.0/24"]
}

resource "azurerm_subnet" "subnet_2_4_37" {
  name                 = "subnet-2-4-37"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_4.name
  address_prefixes     = ["10.14.37.0/24"]
}

resource "azurerm_subnet" "subnet_2_4_38" {
  name                 = "subnet-2-4-38"
  resource_group_name  = azurerm_resource_group.rg_2.name
  virtual_network_name = azurerm_virtual_network.vnet_2_4.name
  address_prefixes     = ["10.14.38.0/24"]
}

resource "azurerm_resource_group" "rg_3" {
  name     = "rg-3"
  location = "westus2"
}

resource "azurerm_virtual_network" "vnet_3_0" {
  name                = "vnet-3-0"
  location            = azurerm_resource_group.rg_3.location
  resource_group_name = azurerm_resource_group.rg_3.name
  address_space       = ["10.15.0.0/16"]
}

resource "azurerm_subnet" "subnet_3_0_0" {
  name                 = "subnet-3-0-0"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_0.name
  address_prefixes     = ["10.15.0.0/24"]
}

resource "azurerm_subnet" "subnet_3_0_1" {
  name                 = "subnet-3-0-1"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_0.name
  address_prefixes     = ["10.15.1.0/24"]
}

resource "azurerm_subnet" "subnet_3_0_2" {
  name                 = "subnet-3-0-2"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_0.name
  address_prefixes     = ["10.15.2.0/24"]
}

resource "azurerm_subnet" "subnet_3_0_3" {
  name                 = "subnet-3-0-3"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_0.name
  address_prefixes     = ["10.15.3.0/24"]
}

resource "azurerm_subnet" "subnet_3_0_4" {
  name                 = "subnet-3-0-4"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_0.name
  address_prefixes     = ["10.15.4.0/24"]
}

resource "azurerm_subnet" "subnet_3_0_5" {
  name                 = "subnet-3-0-5"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_0.name
  address_prefixes     = ["10.15.5.0/24"]
}

resource "azurerm_subnet" "subnet_3_0_6" {
  name                 = "subnet-3-0-6"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_0.name
  address_prefixes     = ["10.15.6.0/24"]
}

resource "azurerm_subnet" "subnet_3_0_7" {
  name                 = "subnet-3-0-7"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_0.name
  address_prefixes     = ["10.15.7.0/24"]
}

resource "azurerm_subnet" "subnet_3_0_8" {
  name                 = "subnet-3-0-8"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_0.name
  address_prefixes     = ["10.15.8.0/24"]
}

resource "azurerm_subnet" "subnet_3_0_9" {
  name                 = "subnet-3-0-9"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_0.name
  address_prefixes     = ["10.15.9.0/24"]
}

resource "azurerm_subnet" "subnet_3_0_10" {
  name                 = "subnet-3-0-10"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_0.name
  address_prefixes     = ["10.15.10.0/24"]
}

resource "azurerm_subnet" "subnet_3_0_11" {
  name                 = "subnet-3-0-11"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_0.name
  address_prefixes     = ["10.15.11.0/24"]
}

resource "azurerm_subnet" "subnet_3_0_12" {
  name                 = "subnet-3-0-12"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_0.name
  address_prefixes     = ["10.15.12.0/24"]
}

resource "azurerm_subnet" "subnet_3_0_13" {
  name                 = "subnet-3-0-13"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_0.name
  address_prefixes     = ["10.15.13.0/24"]
}

resource "azurerm_subnet" "subnet_3_0_14" {
  name                 = "subnet-3-0-14"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_0.name
  address_prefixes     = ["10.15.14.0/24"]
}

resource "azurerm_subnet" "subnet_3_0_15" {
  name                 = "subnet-3-0-15"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_0.name
  address_prefixes     = ["10.15.15.0/24"]
}

resource "azurerm_subnet" "subnet_3_0_16" {
  name                 = "subnet-3-0-16"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_0.name
  address_prefixes     = ["10.15.16.0/24"]
}

resource "azurerm_subnet" "subnet_3_0_17" {
  name                 = "subnet-3-0-17"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_0.name
  address_prefixes     = ["10.15.17.0/24"]
}

resource "azurerm_subnet" "subnet_3_0_18" {
  name                 = "subnet-3-0-18"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_0.name
  address_prefixes     = ["10.15.18.0/24"]
}

resource "azurerm_subnet" "subnet_3_0_19" {
  name                 = "subnet-3-0-19"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_0.name
  address_prefixes     = ["10.15.19.0/24"]
}

resource "azurerm_subnet" "subnet_3_0_20" {
  name                 = "subnet-3-0-20"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_0.name
  address_prefixes     = ["10.15.20.0/24"]
}

resource "azurerm_subnet" "subnet_3_0_21" {
  name                 = "subnet-3-0-21"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_0.name
  address_prefixes     = ["10.15.21.0/24"]
}

resource "azurerm_subnet" "subnet_3_0_22" {
  name                 = "subnet-3-0-22"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_0.name
  address_prefixes     = ["10.15.22.0/24"]
}

resource "azurerm_subnet" "subnet_3_0_23" {
  name                 = "subnet-3-0-23"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_0.name
  address_prefixes     = ["10.15.23.0/24"]
}

resource "azurerm_subnet" "subnet_3_0_24" {
  name                 = "subnet-3-0-24"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_0.name
  address_prefixes     = ["10.15.24.0/24"]
}

resource "azurerm_subnet" "subnet_3_0_25" {
  name                 = "subnet-3-0-25"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_0.name
  address_prefixes     = ["10.15.25.0/24"]
}

resource "azurerm_subnet" "subnet_3_0_26" {
  name                 = "subnet-3-0-26"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_0.name
  address_prefixes     = ["10.15.26.0/24"]
}

resource "azurerm_subnet" "subnet_3_0_27" {
  name                 = "subnet-3-0-27"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_0.name
  address_prefixes     = ["10.15.27.0/24"]
}

resource "azurerm_subnet" "subnet_3_0_28" {
  name                 = "subnet-3-0-28"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_0.name
  address_prefixes     = ["10.15.28.0/24"]
}

resource "azurerm_subnet" "subnet_3_0_29" {
  name                 = "subnet-3-0-29"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_0.name
  address_prefixes     = ["10.15.29.0/24"]
}

resource "azurerm_subnet" "subnet_3_0_30" {
  name                 = "subnet-3-0-30"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_0.name
  address_prefixes     = ["10.15.30.0/24"]
}

resource "azurerm_subnet" "subnet_3_0_31" {
  name                 = "subnet-3-0-31"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_0.name
  address_prefixes     = ["10.15.31.0/24"]
}

resource "azurerm_subnet" "subnet_3_0_32" {
  name                 = "subnet-3-0-32"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_0.name
  address_prefixes     = ["10.15.32.0/24"]
}

resource "azurerm_subnet" "subnet_3_0_33" {
  name                 = "subnet-3-0-33"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_0.name
  address_prefixes     = ["10.15.33.0/24"]
}

resource "azurerm_subnet" "subnet_3_0_34" {
  name                 = "subnet-3-0-34"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_0.name
  address_prefixes     = ["10.15.34.0/24"]
}

resource "azurerm_subnet" "subnet_3_0_35" {
  name                 = "subnet-3-0-35"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_0.name
  address_prefixes     = ["10.15.35.0/24"]
}

resource "azurerm_subnet" "subnet_3_0_36" {
  name                 = "subnet-3-0-36"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_0.name
  address_prefixes     = ["10.15.36.0/24"]
}

resource "azurerm_subnet" "subnet_3_0_37" {
  name                 = "subnet-3-0-37"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_0.name
  address_prefixes     = ["10.15.37.0/24"]
}

resource "azurerm_subnet" "subnet_3_0_38" {
  name                 = "subnet-3-0-38"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_0.name
  address_prefixes     = ["10.15.38.0/24"]
}

resource "azurerm_virtual_network" "vnet_3_1" {
  name                = "vnet-3-1"
  location            = azurerm_resource_group.rg_3.location
  resource_group_name = azurerm_resource_group.rg_3.name
  address_space       = ["10.16.0.0/16"]
}

resource "azurerm_subnet" "subnet_3_1_0" {
  name                 = "subnet-3-1-0"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_1.name
  address_prefixes     = ["10.16.0.0/24"]
}

resource "azurerm_subnet" "subnet_3_1_1" {
  name                 = "subnet-3-1-1"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_1.name
  address_prefixes     = ["10.16.1.0/24"]
}

resource "azurerm_subnet" "subnet_3_1_2" {
  name                 = "subnet-3-1-2"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_1.name
  address_prefixes     = ["10.16.2.0/24"]
}

resource "azurerm_subnet" "subnet_3_1_3" {
  name                 = "subnet-3-1-3"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_1.name
  address_prefixes     = ["10.16.3.0/24"]
}

resource "azurerm_subnet" "subnet_3_1_4" {
  name                 = "subnet-3-1-4"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_1.name
  address_prefixes     = ["10.16.4.0/24"]
}

resource "azurerm_subnet" "subnet_3_1_5" {
  name                 = "subnet-3-1-5"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_1.name
  address_prefixes     = ["10.16.5.0/24"]
}

resource "azurerm_subnet" "subnet_3_1_6" {
  name                 = "subnet-3-1-6"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_1.name
  address_prefixes     = ["10.16.6.0/24"]
}

resource "azurerm_subnet" "subnet_3_1_7" {
  name                 = "subnet-3-1-7"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_1.name
  address_prefixes     = ["10.16.7.0/24"]
}

resource "azurerm_subnet" "subnet_3_1_8" {
  name                 = "subnet-3-1-8"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_1.name
  address_prefixes     = ["10.16.8.0/24"]
}

resource "azurerm_subnet" "subnet_3_1_9" {
  name                 = "subnet-3-1-9"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_1.name
  address_prefixes     = ["10.16.9.0/24"]
}

resource "azurerm_subnet" "subnet_3_1_10" {
  name                 = "subnet-3-1-10"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_1.name
  address_prefixes     = ["10.16.10.0/24"]
}

resource "azurerm_subnet" "subnet_3_1_11" {
  name                 = "subnet-3-1-11"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_1.name
  address_prefixes     = ["10.16.11.0/24"]
}

resource "azurerm_subnet" "subnet_3_1_12" {
  name                 = "subnet-3-1-12"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_1.name
  address_prefixes     = ["10.16.12.0/24"]
}

resource "azurerm_subnet" "subnet_3_1_13" {
  name                 = "subnet-3-1-13"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_1.name
  address_prefixes     = ["10.16.13.0/24"]
}

resource "azurerm_subnet" "subnet_3_1_14" {
  name                 = "subnet-3-1-14"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_1.name
  address_prefixes     = ["10.16.14.0/24"]
}

resource "azurerm_subnet" "subnet_3_1_15" {
  name                 = "subnet-3-1-15"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_1.name
  address_prefixes     = ["10.16.15.0/24"]
}

resource "azurerm_subnet" "subnet_3_1_16" {
  name                 = "subnet-3-1-16"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_1.name
  address_prefixes     = ["10.16.16.0/24"]
}

resource "azurerm_subnet" "subnet_3_1_17" {
  name                 = "subnet-3-1-17"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_1.name
  address_prefixes     = ["10.16.17.0/24"]
}

resource "azurerm_subnet" "subnet_3_1_18" {
  name                 = "subnet-3-1-18"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_1.name
  address_prefixes     = ["10.16.18.0/24"]
}

resource "azurerm_subnet" "subnet_3_1_19" {
  name                 = "subnet-3-1-19"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_1.name
  address_prefixes     = ["10.16.19.0/24"]
}

resource "azurerm_subnet" "subnet_3_1_20" {
  name                 = "subnet-3-1-20"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_1.name
  address_prefixes     = ["10.16.20.0/24"]
}

resource "azurerm_subnet" "subnet_3_1_21" {
  name                 = "subnet-3-1-21"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_1.name
  address_prefixes     = ["10.16.21.0/24"]
}

resource "azurerm_subnet" "subnet_3_1_22" {
  name                 = "subnet-3-1-22"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_1.name
  address_prefixes     = ["10.16.22.0/24"]
}

resource "azurerm_subnet" "subnet_3_1_23" {
  name                 = "subnet-3-1-23"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_1.name
  address_prefixes     = ["10.16.23.0/24"]
}

resource "azurerm_subnet" "subnet_3_1_24" {
  name                 = "subnet-3-1-24"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_1.name
  address_prefixes     = ["10.16.24.0/24"]
}

resource "azurerm_subnet" "subnet_3_1_25" {
  name                 = "subnet-3-1-25"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_1.name
  address_prefixes     = ["10.16.25.0/24"]
}

resource "azurerm_subnet" "subnet_3_1_26" {
  name                 = "subnet-3-1-26"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_1.name
  address_prefixes     = ["10.16.26.0/24"]
}

resource "azurerm_subnet" "subnet_3_1_27" {
  name                 = "subnet-3-1-27"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_1.name
  address_prefixes     = ["10.16.27.0/24"]
}

resource "azurerm_subnet" "subnet_3_1_28" {
  name                 = "subnet-3-1-28"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_1.name
  address_prefixes     = ["10.16.28.0/24"]
}

resource "azurerm_subnet" "subnet_3_1_29" {
  name                 = "subnet-3-1-29"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_1.name
  address_prefixes     = ["10.16.29.0/24"]
}

resource "azurerm_subnet" "subnet_3_1_30" {
  name                 = "subnet-3-1-30"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_1.name
  address_prefixes     = ["10.16.30.0/24"]
}

resource "azurerm_subnet" "subnet_3_1_31" {
  name                 = "subnet-3-1-31"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_1.name
  address_prefixes     = ["10.16.31.0/24"]
}

resource "azurerm_subnet" "subnet_3_1_32" {
  name                 = "subnet-3-1-32"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_1.name
  address_prefixes     = ["10.16.32.0/24"]
}

resource "azurerm_subnet" "subnet_3_1_33" {
  name                 = "subnet-3-1-33"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_1.name
  address_prefixes     = ["10.16.33.0/24"]
}

resource "azurerm_subnet" "subnet_3_1_34" {
  name                 = "subnet-3-1-34"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_1.name
  address_prefixes     = ["10.16.34.0/24"]
}

resource "azurerm_subnet" "subnet_3_1_35" {
  name                 = "subnet-3-1-35"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_1.name
  address_prefixes     = ["10.16.35.0/24"]
}

resource "azurerm_subnet" "subnet_3_1_36" {
  name                 = "subnet-3-1-36"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_1.name
  address_prefixes     = ["10.16.36.0/24"]
}

resource "azurerm_subnet" "subnet_3_1_37" {
  name                 = "subnet-3-1-37"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_1.name
  address_prefixes     = ["10.16.37.0/24"]
}

resource "azurerm_subnet" "subnet_3_1_38" {
  name                 = "subnet-3-1-38"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_1.name
  address_prefixes     = ["10.16.38.0/24"]
}

resource "azurerm_virtual_network" "vnet_3_2" {
  name                = "vnet-3-2"
  location            = azurerm_resource_group.rg_3.location
  resource_group_name = azurerm_resource_group.rg_3.name
  address_space       = ["10.17.0.0/16"]
}

resource "azurerm_subnet" "subnet_3_2_0" {
  name                 = "subnet-3-2-0"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_2.name
  address_prefixes     = ["10.17.0.0/24"]
}

resource "azurerm_subnet" "subnet_3_2_1" {
  name                 = "subnet-3-2-1"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_2.name
  address_prefixes     = ["10.17.1.0/24"]
}

resource "azurerm_subnet" "subnet_3_2_2" {
  name                 = "subnet-3-2-2"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_2.name
  address_prefixes     = ["10.17.2.0/24"]
}

resource "azurerm_subnet" "subnet_3_2_3" {
  name                 = "subnet-3-2-3"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_2.name
  address_prefixes     = ["10.17.3.0/24"]
}

resource "azurerm_subnet" "subnet_3_2_4" {
  name                 = "subnet-3-2-4"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_2.name
  address_prefixes     = ["10.17.4.0/24"]
}

resource "azurerm_subnet" "subnet_3_2_5" {
  name                 = "subnet-3-2-5"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_2.name
  address_prefixes     = ["10.17.5.0/24"]
}

resource "azurerm_subnet" "subnet_3_2_6" {
  name                 = "subnet-3-2-6"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_2.name
  address_prefixes     = ["10.17.6.0/24"]
}

resource "azurerm_subnet" "subnet_3_2_7" {
  name                 = "subnet-3-2-7"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_2.name
  address_prefixes     = ["10.17.7.0/24"]
}

resource "azurerm_subnet" "subnet_3_2_8" {
  name                 = "subnet-3-2-8"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_2.name
  address_prefixes     = ["10.17.8.0/24"]
}

resource "azurerm_subnet" "subnet_3_2_9" {
  name                 = "subnet-3-2-9"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_2.name
  address_prefixes     = ["10.17.9.0/24"]
}

resource "azurerm_subnet" "subnet_3_2_10" {
  name                 = "subnet-3-2-10"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_2.name
  address_prefixes     = ["10.17.10.0/24"]
}

resource "azurerm_subnet" "subnet_3_2_11" {
  name                 = "subnet-3-2-11"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_2.name
  address_prefixes     = ["10.17.11.0/24"]
}

resource "azurerm_subnet" "subnet_3_2_12" {
  name                 = "subnet-3-2-12"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_2.name
  address_prefixes     = ["10.17.12.0/24"]
}

resource "azurerm_subnet" "subnet_3_2_13" {
  name                 = "subnet-3-2-13"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_2.name
  address_prefixes     = ["10.17.13.0/24"]
}

resource "azurerm_subnet" "subnet_3_2_14" {
  name                 = "subnet-3-2-14"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_2.name
  address_prefixes     = ["10.17.14.0/24"]
}

resource "azurerm_subnet" "subnet_3_2_15" {
  name                 = "subnet-3-2-15"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_2.name
  address_prefixes     = ["10.17.15.0/24"]
}

resource "azurerm_subnet" "subnet_3_2_16" {
  name                 = "subnet-3-2-16"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_2.name
  address_prefixes     = ["10.17.16.0/24"]
}

resource "azurerm_subnet" "subnet_3_2_17" {
  name                 = "subnet-3-2-17"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_2.name
  address_prefixes     = ["10.17.17.0/24"]
}

resource "azurerm_subnet" "subnet_3_2_18" {
  name                 = "subnet-3-2-18"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_2.name
  address_prefixes     = ["10.17.18.0/24"]
}

resource "azurerm_subnet" "subnet_3_2_19" {
  name                 = "subnet-3-2-19"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_2.name
  address_prefixes     = ["10.17.19.0/24"]
}

resource "azurerm_subnet" "subnet_3_2_20" {
  name                 = "subnet-3-2-20"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_2.name
  address_prefixes     = ["10.17.20.0/24"]
}

resource "azurerm_subnet" "subnet_3_2_21" {
  name                 = "subnet-3-2-21"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_2.name
  address_prefixes     = ["10.17.21.0/24"]
}

resource "azurerm_subnet" "subnet_3_2_22" {
  name                 = "subnet-3-2-22"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_2.name
  address_prefixes     = ["10.17.22.0/24"]
}

resource "azurerm_subnet" "subnet_3_2_23" {
  name                 = "subnet-3-2-23"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_2.name
  address_prefixes     = ["10.17.23.0/24"]
}

resource "azurerm_subnet" "subnet_3_2_24" {
  name                 = "subnet-3-2-24"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_2.name
  address_prefixes     = ["10.17.24.0/24"]
}

resource "azurerm_subnet" "subnet_3_2_25" {
  name                 = "subnet-3-2-25"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_2.name
  address_prefixes     = ["10.17.25.0/24"]
}

resource "azurerm_subnet" "subnet_3_2_26" {
  name                 = "subnet-3-2-26"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_2.name
  address_prefixes     = ["10.17.26.0/24"]
}

resource "azurerm_subnet" "subnet_3_2_27" {
  name                 = "subnet-3-2-27"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_2.name
  address_prefixes     = ["10.17.27.0/24"]
}

resource "azurerm_subnet" "subnet_3_2_28" {
  name                 = "subnet-3-2-28"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_2.name
  address_prefixes     = ["10.17.28.0/24"]
}

resource "azurerm_subnet" "subnet_3_2_29" {
  name                 = "subnet-3-2-29"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_2.name
  address_prefixes     = ["10.17.29.0/24"]
}

resource "azurerm_subnet" "subnet_3_2_30" {
  name                 = "subnet-3-2-30"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_2.name
  address_prefixes     = ["10.17.30.0/24"]
}

resource "azurerm_subnet" "subnet_3_2_31" {
  name                 = "subnet-3-2-31"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_2.name
  address_prefixes     = ["10.17.31.0/24"]
}

resource "azurerm_subnet" "subnet_3_2_32" {
  name                 = "subnet-3-2-32"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_2.name
  address_prefixes     = ["10.17.32.0/24"]
}

resource "azurerm_subnet" "subnet_3_2_33" {
  name                 = "subnet-3-2-33"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_2.name
  address_prefixes     = ["10.17.33.0/24"]
}

resource "azurerm_subnet" "subnet_3_2_34" {
  name                 = "subnet-3-2-34"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_2.name
  address_prefixes     = ["10.17.34.0/24"]
}

resource "azurerm_subnet" "subnet_3_2_35" {
  name                 = "subnet-3-2-35"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_2.name
  address_prefixes     = ["10.17.35.0/24"]
}

resource "azurerm_subnet" "subnet_3_2_36" {
  name                 = "subnet-3-2-36"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_2.name
  address_prefixes     = ["10.17.36.0/24"]
}

resource "azurerm_subnet" "subnet_3_2_37" {
  name                 = "subnet-3-2-37"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_2.name
  address_prefixes     = ["10.17.37.0/24"]
}

resource "azurerm_subnet" "subnet_3_2_38" {
  name                 = "subnet-3-2-38"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_2.name
  address_prefixes     = ["10.17.38.0/24"]
}

resource "azurerm_virtual_network" "vnet_3_3" {
  name                = "vnet-3-3"
  location            = azurerm_resource_group.rg_3.location
  resource_group_name = azurerm_resource_group.rg_3.name
  address_space       = ["10.18.0.0/16"]
}

resource "azurerm_subnet" "subnet_3_3_0" {
  name                 = "subnet-3-3-0"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_3.name
  address_prefixes     = ["10.18.0.0/24"]
}

resource "azurerm_subnet" "subnet_3_3_1" {
  name                 = "subnet-3-3-1"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_3.name
  address_prefixes     = ["10.18.1.0/24"]
}

resource "azurerm_subnet" "subnet_3_3_2" {
  name                 = "subnet-3-3-2"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_3.name
  address_prefixes     = ["10.18.2.0/24"]
}

resource "azurerm_subnet" "subnet_3_3_3" {
  name                 = "subnet-3-3-3"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_3.name
  address_prefixes     = ["10.18.3.0/24"]
}

resource "azurerm_subnet" "subnet_3_3_4" {
  name                 = "subnet-3-3-4"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_3.name
  address_prefixes     = ["10.18.4.0/24"]
}

resource "azurerm_subnet" "subnet_3_3_5" {
  name                 = "subnet-3-3-5"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_3.name
  address_prefixes     = ["10.18.5.0/24"]
}

resource "azurerm_subnet" "subnet_3_3_6" {
  name                 = "subnet-3-3-6"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_3.name
  address_prefixes     = ["10.18.6.0/24"]
}

resource "azurerm_subnet" "subnet_3_3_7" {
  name                 = "subnet-3-3-7"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_3.name
  address_prefixes     = ["10.18.7.0/24"]
}

resource "azurerm_subnet" "subnet_3_3_8" {
  name                 = "subnet-3-3-8"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_3.name
  address_prefixes     = ["10.18.8.0/24"]
}

resource "azurerm_subnet" "subnet_3_3_9" {
  name                 = "subnet-3-3-9"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_3.name
  address_prefixes     = ["10.18.9.0/24"]
}

resource "azurerm_subnet" "subnet_3_3_10" {
  name                 = "subnet-3-3-10"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_3.name
  address_prefixes     = ["10.18.10.0/24"]
}

resource "azurerm_subnet" "subnet_3_3_11" {
  name                 = "subnet-3-3-11"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_3.name
  address_prefixes     = ["10.18.11.0/24"]
}

resource "azurerm_subnet" "subnet_3_3_12" {
  name                 = "subnet-3-3-12"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_3.name
  address_prefixes     = ["10.18.12.0/24"]
}

resource "azurerm_subnet" "subnet_3_3_13" {
  name                 = "subnet-3-3-13"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_3.name
  address_prefixes     = ["10.18.13.0/24"]
}

resource "azurerm_subnet" "subnet_3_3_14" {
  name                 = "subnet-3-3-14"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_3.name
  address_prefixes     = ["10.18.14.0/24"]
}

resource "azurerm_subnet" "subnet_3_3_15" {
  name                 = "subnet-3-3-15"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_3.name
  address_prefixes     = ["10.18.15.0/24"]
}

resource "azurerm_subnet" "subnet_3_3_16" {
  name                 = "subnet-3-3-16"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_3.name
  address_prefixes     = ["10.18.16.0/24"]
}

resource "azurerm_subnet" "subnet_3_3_17" {
  name                 = "subnet-3-3-17"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_3.name
  address_prefixes     = ["10.18.17.0/24"]
}

resource "azurerm_subnet" "subnet_3_3_18" {
  name                 = "subnet-3-3-18"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_3.name
  address_prefixes     = ["10.18.18.0/24"]
}

resource "azurerm_subnet" "subnet_3_3_19" {
  name                 = "subnet-3-3-19"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_3.name
  address_prefixes     = ["10.18.19.0/24"]
}

resource "azurerm_subnet" "subnet_3_3_20" {
  name                 = "subnet-3-3-20"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_3.name
  address_prefixes     = ["10.18.20.0/24"]
}

resource "azurerm_subnet" "subnet_3_3_21" {
  name                 = "subnet-3-3-21"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_3.name
  address_prefixes     = ["10.18.21.0/24"]
}

resource "azurerm_subnet" "subnet_3_3_22" {
  name                 = "subnet-3-3-22"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_3.name
  address_prefixes     = ["10.18.22.0/24"]
}

resource "azurerm_subnet" "subnet_3_3_23" {
  name                 = "subnet-3-3-23"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_3.name
  address_prefixes     = ["10.18.23.0/24"]
}

resource "azurerm_subnet" "subnet_3_3_24" {
  name                 = "subnet-3-3-24"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_3.name
  address_prefixes     = ["10.18.24.0/24"]
}

resource "azurerm_subnet" "subnet_3_3_25" {
  name                 = "subnet-3-3-25"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_3.name
  address_prefixes     = ["10.18.25.0/24"]
}

resource "azurerm_subnet" "subnet_3_3_26" {
  name                 = "subnet-3-3-26"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_3.name
  address_prefixes     = ["10.18.26.0/24"]
}

resource "azurerm_subnet" "subnet_3_3_27" {
  name                 = "subnet-3-3-27"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_3.name
  address_prefixes     = ["10.18.27.0/24"]
}

resource "azurerm_subnet" "subnet_3_3_28" {
  name                 = "subnet-3-3-28"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_3.name
  address_prefixes     = ["10.18.28.0/24"]
}

resource "azurerm_subnet" "subnet_3_3_29" {
  name                 = "subnet-3-3-29"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_3.name
  address_prefixes     = ["10.18.29.0/24"]
}

resource "azurerm_subnet" "subnet_3_3_30" {
  name                 = "subnet-3-3-30"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_3.name
  address_prefixes     = ["10.18.30.0/24"]
}

resource "azurerm_subnet" "subnet_3_3_31" {
  name                 = "subnet-3-3-31"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_3.name
  address_prefixes     = ["10.18.31.0/24"]
}

resource "azurerm_subnet" "subnet_3_3_32" {
  name                 = "subnet-3-3-32"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_3.name
  address_prefixes     = ["10.18.32.0/24"]
}

resource "azurerm_subnet" "subnet_3_3_33" {
  name                 = "subnet-3-3-33"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_3.name
  address_prefixes     = ["10.18.33.0/24"]
}

resource "azurerm_subnet" "subnet_3_3_34" {
  name                 = "subnet-3-3-34"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_3.name
  address_prefixes     = ["10.18.34.0/24"]
}

resource "azurerm_subnet" "subnet_3_3_35" {
  name                 = "subnet-3-3-35"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_3.name
  address_prefixes     = ["10.18.35.0/24"]
}

resource "azurerm_subnet" "subnet_3_3_36" {
  name                 = "subnet-3-3-36"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_3.name
  address_prefixes     = ["10.18.36.0/24"]
}

resource "azurerm_subnet" "subnet_3_3_37" {
  name                 = "subnet-3-3-37"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_3.name
  address_prefixes     = ["10.18.37.0/24"]
}

resource "azurerm_subnet" "subnet_3_3_38" {
  name                 = "subnet-3-3-38"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_3.name
  address_prefixes     = ["10.18.38.0/24"]
}

resource "azurerm_virtual_network" "vnet_3_4" {
  name                = "vnet-3-4"
  location            = azurerm_resource_group.rg_3.location
  resource_group_name = azurerm_resource_group.rg_3.name
  address_space       = ["10.19.0.0/16"]
}

resource "azurerm_subnet" "subnet_3_4_0" {
  name                 = "subnet-3-4-0"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_4.name
  address_prefixes     = ["10.19.0.0/24"]
}

resource "azurerm_subnet" "subnet_3_4_1" {
  name                 = "subnet-3-4-1"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_4.name
  address_prefixes     = ["10.19.1.0/24"]
}

resource "azurerm_subnet" "subnet_3_4_2" {
  name                 = "subnet-3-4-2"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_4.name
  address_prefixes     = ["10.19.2.0/24"]
}

resource "azurerm_subnet" "subnet_3_4_3" {
  name                 = "subnet-3-4-3"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_4.name
  address_prefixes     = ["10.19.3.0/24"]
}

resource "azurerm_subnet" "subnet_3_4_4" {
  name                 = "subnet-3-4-4"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_4.name
  address_prefixes     = ["10.19.4.0/24"]
}

resource "azurerm_subnet" "subnet_3_4_5" {
  name                 = "subnet-3-4-5"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_4.name
  address_prefixes     = ["10.19.5.0/24"]
}

resource "azurerm_subnet" "subnet_3_4_6" {
  name                 = "subnet-3-4-6"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_4.name
  address_prefixes     = ["10.19.6.0/24"]
}

resource "azurerm_subnet" "subnet_3_4_7" {
  name                 = "subnet-3-4-7"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_4.name
  address_prefixes     = ["10.19.7.0/24"]
}

resource "azurerm_subnet" "subnet_3_4_8" {
  name                 = "subnet-3-4-8"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_4.name
  address_prefixes     = ["10.19.8.0/24"]
}

resource "azurerm_subnet" "subnet_3_4_9" {
  name                 = "subnet-3-4-9"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_4.name
  address_prefixes     = ["10.19.9.0/24"]
}

resource "azurerm_subnet" "subnet_3_4_10" {
  name                 = "subnet-3-4-10"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_4.name
  address_prefixes     = ["10.19.10.0/24"]
}

resource "azurerm_subnet" "subnet_3_4_11" {
  name                 = "subnet-3-4-11"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_4.name
  address_prefixes     = ["10.19.11.0/24"]
}

resource "azurerm_subnet" "subnet_3_4_12" {
  name                 = "subnet-3-4-12"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_4.name
  address_prefixes     = ["10.19.12.0/24"]
}

resource "azurerm_subnet" "subnet_3_4_13" {
  name                 = "subnet-3-4-13"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_4.name
  address_prefixes     = ["10.19.13.0/24"]
}

resource "azurerm_subnet" "subnet_3_4_14" {
  name                 = "subnet-3-4-14"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_4.name
  address_prefixes     = ["10.19.14.0/24"]
}

resource "azurerm_subnet" "subnet_3_4_15" {
  name                 = "subnet-3-4-15"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_4.name
  address_prefixes     = ["10.19.15.0/24"]
}

resource "azurerm_subnet" "subnet_3_4_16" {
  name                 = "subnet-3-4-16"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_4.name
  address_prefixes     = ["10.19.16.0/24"]
}

resource "azurerm_subnet" "subnet_3_4_17" {
  name                 = "subnet-3-4-17"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_4.name
  address_prefixes     = ["10.19.17.0/24"]
}

resource "azurerm_subnet" "subnet_3_4_18" {
  name                 = "subnet-3-4-18"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_4.name
  address_prefixes     = ["10.19.18.0/24"]
}

resource "azurerm_subnet" "subnet_3_4_19" {
  name                 = "subnet-3-4-19"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_4.name
  address_prefixes     = ["10.19.19.0/24"]
}

resource "azurerm_subnet" "subnet_3_4_20" {
  name                 = "subnet-3-4-20"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_4.name
  address_prefixes     = ["10.19.20.0/24"]
}

resource "azurerm_subnet" "subnet_3_4_21" {
  name                 = "subnet-3-4-21"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_4.name
  address_prefixes     = ["10.19.21.0/24"]
}

resource "azurerm_subnet" "subnet_3_4_22" {
  name                 = "subnet-3-4-22"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_4.name
  address_prefixes     = ["10.19.22.0/24"]
}

resource "azurerm_subnet" "subnet_3_4_23" {
  name                 = "subnet-3-4-23"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_4.name
  address_prefixes     = ["10.19.23.0/24"]
}

resource "azurerm_subnet" "subnet_3_4_24" {
  name                 = "subnet-3-4-24"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_4.name
  address_prefixes     = ["10.19.24.0/24"]
}

resource "azurerm_subnet" "subnet_3_4_25" {
  name                 = "subnet-3-4-25"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_4.name
  address_prefixes     = ["10.19.25.0/24"]
}

resource "azurerm_subnet" "subnet_3_4_26" {
  name                 = "subnet-3-4-26"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_4.name
  address_prefixes     = ["10.19.26.0/24"]
}

resource "azurerm_subnet" "subnet_3_4_27" {
  name                 = "subnet-3-4-27"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_4.name
  address_prefixes     = ["10.19.27.0/24"]
}

resource "azurerm_subnet" "subnet_3_4_28" {
  name                 = "subnet-3-4-28"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_4.name
  address_prefixes     = ["10.19.28.0/24"]
}

resource "azurerm_subnet" "subnet_3_4_29" {
  name                 = "subnet-3-4-29"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_4.name
  address_prefixes     = ["10.19.29.0/24"]
}

resource "azurerm_subnet" "subnet_3_4_30" {
  name                 = "subnet-3-4-30"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_4.name
  address_prefixes     = ["10.19.30.0/24"]
}

resource "azurerm_subnet" "subnet_3_4_31" {
  name                 = "subnet-3-4-31"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_4.name
  address_prefixes     = ["10.19.31.0/24"]
}

resource "azurerm_subnet" "subnet_3_4_32" {
  name                 = "subnet-3-4-32"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_4.name
  address_prefixes     = ["10.19.32.0/24"]
}

resource "azurerm_subnet" "subnet_3_4_33" {
  name                 = "subnet-3-4-33"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_4.name
  address_prefixes     = ["10.19.33.0/24"]
}

resource "azurerm_subnet" "subnet_3_4_34" {
  name                 = "subnet-3-4-34"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_4.name
  address_prefixes     = ["10.19.34.0/24"]
}

resource "azurerm_subnet" "subnet_3_4_35" {
  name                 = "subnet-3-4-35"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_4.name
  address_prefixes     = ["10.19.35.0/24"]
}

resource "azurerm_subnet" "subnet_3_4_36" {
  name                 = "subnet-3-4-36"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_4.name
  address_prefixes     = ["10.19.36.0/24"]
}

resource "azurerm_subnet" "subnet_3_4_37" {
  name                 = "subnet-3-4-37"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_4.name
  address_prefixes     = ["10.19.37.0/24"]
}

resource "azurerm_subnet" "subnet_3_4_38" {
  name                 = "subnet-3-4-38"
  resource_group_name  = azurerm_resource_group.rg_3.name
  virtual_network_name = azurerm_virtual_network.vnet_3_4.name
  address_prefixes     = ["10.19.38.0/24"]
}

resource "azurerm_resource_group" "rg_4" {
  name     = "rg-4"
  location = "centralus"
}

resource "azurerm_virtual_network" "vnet_4_0" {
  name                = "vnet-4-0"
  location            = azurerm_resource_group.rg_4.location
  resource_group_name = azurerm_resource_group.rg_4.name
  address_space       = ["10.20.0.0/16"]
}

resource "azurerm_subnet" "subnet_4_0_0" {
  name                 = "subnet-4-0-0"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_0.name
  address_prefixes     = ["10.20.0.0/24"]
}

resource "azurerm_subnet" "subnet_4_0_1" {
  name                 = "subnet-4-0-1"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_0.name
  address_prefixes     = ["10.20.1.0/24"]
}

resource "azurerm_subnet" "subnet_4_0_2" {
  name                 = "subnet-4-0-2"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_0.name
  address_prefixes     = ["10.20.2.0/24"]
}

resource "azurerm_subnet" "subnet_4_0_3" {
  name                 = "subnet-4-0-3"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_0.name
  address_prefixes     = ["10.20.3.0/24"]
}

resource "azurerm_subnet" "subnet_4_0_4" {
  name                 = "subnet-4-0-4"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_0.name
  address_prefixes     = ["10.20.4.0/24"]
}

resource "azurerm_subnet" "subnet_4_0_5" {
  name                 = "subnet-4-0-5"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_0.name
  address_prefixes     = ["10.20.5.0/24"]
}

resource "azurerm_subnet" "subnet_4_0_6" {
  name                 = "subnet-4-0-6"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_0.name
  address_prefixes     = ["10.20.6.0/24"]
}

resource "azurerm_subnet" "subnet_4_0_7" {
  name                 = "subnet-4-0-7"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_0.name
  address_prefixes     = ["10.20.7.0/24"]
}

resource "azurerm_subnet" "subnet_4_0_8" {
  name                 = "subnet-4-0-8"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_0.name
  address_prefixes     = ["10.20.8.0/24"]
}

resource "azurerm_subnet" "subnet_4_0_9" {
  name                 = "subnet-4-0-9"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_0.name
  address_prefixes     = ["10.20.9.0/24"]
}

resource "azurerm_subnet" "subnet_4_0_10" {
  name                 = "subnet-4-0-10"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_0.name
  address_prefixes     = ["10.20.10.0/24"]
}

resource "azurerm_subnet" "subnet_4_0_11" {
  name                 = "subnet-4-0-11"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_0.name
  address_prefixes     = ["10.20.11.0/24"]
}

resource "azurerm_subnet" "subnet_4_0_12" {
  name                 = "subnet-4-0-12"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_0.name
  address_prefixes     = ["10.20.12.0/24"]
}

resource "azurerm_subnet" "subnet_4_0_13" {
  name                 = "subnet-4-0-13"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_0.name
  address_prefixes     = ["10.20.13.0/24"]
}

resource "azurerm_subnet" "subnet_4_0_14" {
  name                 = "subnet-4-0-14"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_0.name
  address_prefixes     = ["10.20.14.0/24"]
}

resource "azurerm_subnet" "subnet_4_0_15" {
  name                 = "subnet-4-0-15"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_0.name
  address_prefixes     = ["10.20.15.0/24"]
}

resource "azurerm_subnet" "subnet_4_0_16" {
  name                 = "subnet-4-0-16"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_0.name
  address_prefixes     = ["10.20.16.0/24"]
}

resource "azurerm_subnet" "subnet_4_0_17" {
  name                 = "subnet-4-0-17"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_0.name
  address_prefixes     = ["10.20.17.0/24"]
}

resource "azurerm_subnet" "subnet_4_0_18" {
  name                 = "subnet-4-0-18"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_0.name
  address_prefixes     = ["10.20.18.0/24"]
}

resource "azurerm_subnet" "subnet_4_0_19" {
  name                 = "subnet-4-0-19"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_0.name
  address_prefixes     = ["10.20.19.0/24"]
}

resource "azurerm_subnet" "subnet_4_0_20" {
  name                 = "subnet-4-0-20"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_0.name
  address_prefixes     = ["10.20.20.0/24"]
}

resource "azurerm_subnet" "subnet_4_0_21" {
  name                 = "subnet-4-0-21"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_0.name
  address_prefixes     = ["10.20.21.0/24"]
}

resource "azurerm_subnet" "subnet_4_0_22" {
  name                 = "subnet-4-0-22"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_0.name
  address_prefixes     = ["10.20.22.0/24"]
}

resource "azurerm_subnet" "subnet_4_0_23" {
  name                 = "subnet-4-0-23"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_0.name
  address_prefixes     = ["10.20.23.0/24"]
}

resource "azurerm_subnet" "subnet_4_0_24" {
  name                 = "subnet-4-0-24"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_0.name
  address_prefixes     = ["10.20.24.0/24"]
}

resource "azurerm_subnet" "subnet_4_0_25" {
  name                 = "subnet-4-0-25"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_0.name
  address_prefixes     = ["10.20.25.0/24"]
}

resource "azurerm_subnet" "subnet_4_0_26" {
  name                 = "subnet-4-0-26"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_0.name
  address_prefixes     = ["10.20.26.0/24"]
}

resource "azurerm_subnet" "subnet_4_0_27" {
  name                 = "subnet-4-0-27"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_0.name
  address_prefixes     = ["10.20.27.0/24"]
}

resource "azurerm_subnet" "subnet_4_0_28" {
  name                 = "subnet-4-0-28"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_0.name
  address_prefixes     = ["10.20.28.0/24"]
}

resource "azurerm_subnet" "subnet_4_0_29" {
  name                 = "subnet-4-0-29"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_0.name
  address_prefixes     = ["10.20.29.0/24"]
}

resource "azurerm_subnet" "subnet_4_0_30" {
  name                 = "subnet-4-0-30"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_0.name
  address_prefixes     = ["10.20.30.0/24"]
}

resource "azurerm_subnet" "subnet_4_0_31" {
  name                 = "subnet-4-0-31"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_0.name
  address_prefixes     = ["10.20.31.0/24"]
}

resource "azurerm_subnet" "subnet_4_0_32" {
  name                 = "subnet-4-0-32"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_0.name
  address_prefixes     = ["10.20.32.0/24"]
}

resource "azurerm_subnet" "subnet_4_0_33" {
  name                 = "subnet-4-0-33"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_0.name
  address_prefixes     = ["10.20.33.0/24"]
}

resource "azurerm_subnet" "subnet_4_0_34" {
  name                 = "subnet-4-0-34"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_0.name
  address_prefixes     = ["10.20.34.0/24"]
}

resource "azurerm_subnet" "subnet_4_0_35" {
  name                 = "subnet-4-0-35"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_0.name
  address_prefixes     = ["10.20.35.0/24"]
}

resource "azurerm_subnet" "subnet_4_0_36" {
  name                 = "subnet-4-0-36"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_0.name
  address_prefixes     = ["10.20.36.0/24"]
}

resource "azurerm_subnet" "subnet_4_0_37" {
  name                 = "subnet-4-0-37"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_0.name
  address_prefixes     = ["10.20.37.0/24"]
}

resource "azurerm_subnet" "subnet_4_0_38" {
  name                 = "subnet-4-0-38"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_0.name
  address_prefixes     = ["10.20.38.0/24"]
}

resource "azurerm_virtual_network" "vnet_4_1" {
  name                = "vnet-4-1"
  location            = azurerm_resource_group.rg_4.location
  resource_group_name = azurerm_resource_group.rg_4.name
  address_space       = ["10.21.0.0/16"]
}

resource "azurerm_subnet" "subnet_4_1_0" {
  name                 = "subnet-4-1-0"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_1.name
  address_prefixes     = ["10.21.0.0/24"]
}

resource "azurerm_subnet" "subnet_4_1_1" {
  name                 = "subnet-4-1-1"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_1.name
  address_prefixes     = ["10.21.1.0/24"]
}

resource "azurerm_subnet" "subnet_4_1_2" {
  name                 = "subnet-4-1-2"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_1.name
  address_prefixes     = ["10.21.2.0/24"]
}

resource "azurerm_subnet" "subnet_4_1_3" {
  name                 = "subnet-4-1-3"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_1.name
  address_prefixes     = ["10.21.3.0/24"]
}

resource "azurerm_subnet" "subnet_4_1_4" {
  name                 = "subnet-4-1-4"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_1.name
  address_prefixes     = ["10.21.4.0/24"]
}

resource "azurerm_subnet" "subnet_4_1_5" {
  name                 = "subnet-4-1-5"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_1.name
  address_prefixes     = ["10.21.5.0/24"]
}

resource "azurerm_subnet" "subnet_4_1_6" {
  name                 = "subnet-4-1-6"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_1.name
  address_prefixes     = ["10.21.6.0/24"]
}

resource "azurerm_subnet" "subnet_4_1_7" {
  name                 = "subnet-4-1-7"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_1.name
  address_prefixes     = ["10.21.7.0/24"]
}

resource "azurerm_subnet" "subnet_4_1_8" {
  name                 = "subnet-4-1-8"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_1.name
  address_prefixes     = ["10.21.8.0/24"]
}

resource "azurerm_subnet" "subnet_4_1_9" {
  name                 = "subnet-4-1-9"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_1.name
  address_prefixes     = ["10.21.9.0/24"]
}

resource "azurerm_subnet" "subnet_4_1_10" {
  name                 = "subnet-4-1-10"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_1.name
  address_prefixes     = ["10.21.10.0/24"]
}

resource "azurerm_subnet" "subnet_4_1_11" {
  name                 = "subnet-4-1-11"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_1.name
  address_prefixes     = ["10.21.11.0/24"]
}

resource "azurerm_subnet" "subnet_4_1_12" {
  name                 = "subnet-4-1-12"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_1.name
  address_prefixes     = ["10.21.12.0/24"]
}

resource "azurerm_subnet" "subnet_4_1_13" {
  name                 = "subnet-4-1-13"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_1.name
  address_prefixes     = ["10.21.13.0/24"]
}

resource "azurerm_subnet" "subnet_4_1_14" {
  name                 = "subnet-4-1-14"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_1.name
  address_prefixes     = ["10.21.14.0/24"]
}

resource "azurerm_subnet" "subnet_4_1_15" {
  name                 = "subnet-4-1-15"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_1.name
  address_prefixes     = ["10.21.15.0/24"]
}

resource "azurerm_subnet" "subnet_4_1_16" {
  name                 = "subnet-4-1-16"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_1.name
  address_prefixes     = ["10.21.16.0/24"]
}

resource "azurerm_subnet" "subnet_4_1_17" {
  name                 = "subnet-4-1-17"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_1.name
  address_prefixes     = ["10.21.17.0/24"]
}

resource "azurerm_subnet" "subnet_4_1_18" {
  name                 = "subnet-4-1-18"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_1.name
  address_prefixes     = ["10.21.18.0/24"]
}

resource "azurerm_subnet" "subnet_4_1_19" {
  name                 = "subnet-4-1-19"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_1.name
  address_prefixes     = ["10.21.19.0/24"]
}

resource "azurerm_subnet" "subnet_4_1_20" {
  name                 = "subnet-4-1-20"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_1.name
  address_prefixes     = ["10.21.20.0/24"]
}

resource "azurerm_subnet" "subnet_4_1_21" {
  name                 = "subnet-4-1-21"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_1.name
  address_prefixes     = ["10.21.21.0/24"]
}

resource "azurerm_subnet" "subnet_4_1_22" {
  name                 = "subnet-4-1-22"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_1.name
  address_prefixes     = ["10.21.22.0/24"]
}

resource "azurerm_subnet" "subnet_4_1_23" {
  name                 = "subnet-4-1-23"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_1.name
  address_prefixes     = ["10.21.23.0/24"]
}

resource "azurerm_subnet" "subnet_4_1_24" {
  name                 = "subnet-4-1-24"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_1.name
  address_prefixes     = ["10.21.24.0/24"]
}

resource "azurerm_subnet" "subnet_4_1_25" {
  name                 = "subnet-4-1-25"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_1.name
  address_prefixes     = ["10.21.25.0/24"]
}

resource "azurerm_subnet" "subnet_4_1_26" {
  name                 = "subnet-4-1-26"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_1.name
  address_prefixes     = ["10.21.26.0/24"]
}

resource "azurerm_subnet" "subnet_4_1_27" {
  name                 = "subnet-4-1-27"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_1.name
  address_prefixes     = ["10.21.27.0/24"]
}

resource "azurerm_subnet" "subnet_4_1_28" {
  name                 = "subnet-4-1-28"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_1.name
  address_prefixes     = ["10.21.28.0/24"]
}

resource "azurerm_subnet" "subnet_4_1_29" {
  name                 = "subnet-4-1-29"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_1.name
  address_prefixes     = ["10.21.29.0/24"]
}

resource "azurerm_subnet" "subnet_4_1_30" {
  name                 = "subnet-4-1-30"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_1.name
  address_prefixes     = ["10.21.30.0/24"]
}

resource "azurerm_subnet" "subnet_4_1_31" {
  name                 = "subnet-4-1-31"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_1.name
  address_prefixes     = ["10.21.31.0/24"]
}

resource "azurerm_subnet" "subnet_4_1_32" {
  name                 = "subnet-4-1-32"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_1.name
  address_prefixes     = ["10.21.32.0/24"]
}

resource "azurerm_subnet" "subnet_4_1_33" {
  name                 = "subnet-4-1-33"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_1.name
  address_prefixes     = ["10.21.33.0/24"]
}

resource "azurerm_subnet" "subnet_4_1_34" {
  name                 = "subnet-4-1-34"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_1.name
  address_prefixes     = ["10.21.34.0/24"]
}

resource "azurerm_subnet" "subnet_4_1_35" {
  name                 = "subnet-4-1-35"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_1.name
  address_prefixes     = ["10.21.35.0/24"]
}

resource "azurerm_subnet" "subnet_4_1_36" {
  name                 = "subnet-4-1-36"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_1.name
  address_prefixes     = ["10.21.36.0/24"]
}

resource "azurerm_subnet" "subnet_4_1_37" {
  name                 = "subnet-4-1-37"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_1.name
  address_prefixes     = ["10.21.37.0/24"]
}

resource "azurerm_subnet" "subnet_4_1_38" {
  name                 = "subnet-4-1-38"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_1.name
  address_prefixes     = ["10.21.38.0/24"]
}

resource "azurerm_virtual_network" "vnet_4_2" {
  name                = "vnet-4-2"
  location            = azurerm_resource_group.rg_4.location
  resource_group_name = azurerm_resource_group.rg_4.name
  address_space       = ["10.22.0.0/16"]
}

resource "azurerm_subnet" "subnet_4_2_0" {
  name                 = "subnet-4-2-0"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_2.name
  address_prefixes     = ["10.22.0.0/24"]
}

resource "azurerm_subnet" "subnet_4_2_1" {
  name                 = "subnet-4-2-1"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_2.name
  address_prefixes     = ["10.22.1.0/24"]
}

resource "azurerm_subnet" "subnet_4_2_2" {
  name                 = "subnet-4-2-2"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_2.name
  address_prefixes     = ["10.22.2.0/24"]
}

resource "azurerm_subnet" "subnet_4_2_3" {
  name                 = "subnet-4-2-3"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_2.name
  address_prefixes     = ["10.22.3.0/24"]
}

resource "azurerm_subnet" "subnet_4_2_4" {
  name                 = "subnet-4-2-4"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_2.name
  address_prefixes     = ["10.22.4.0/24"]
}

resource "azurerm_subnet" "subnet_4_2_5" {
  name                 = "subnet-4-2-5"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_2.name
  address_prefixes     = ["10.22.5.0/24"]
}

resource "azurerm_subnet" "subnet_4_2_6" {
  name                 = "subnet-4-2-6"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_2.name
  address_prefixes     = ["10.22.6.0/24"]
}

resource "azurerm_subnet" "subnet_4_2_7" {
  name                 = "subnet-4-2-7"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_2.name
  address_prefixes     = ["10.22.7.0/24"]
}

resource "azurerm_subnet" "subnet_4_2_8" {
  name                 = "subnet-4-2-8"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_2.name
  address_prefixes     = ["10.22.8.0/24"]
}

resource "azurerm_subnet" "subnet_4_2_9" {
  name                 = "subnet-4-2-9"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_2.name
  address_prefixes     = ["10.22.9.0/24"]
}

resource "azurerm_subnet" "subnet_4_2_10" {
  name                 = "subnet-4-2-10"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_2.name
  address_prefixes     = ["10.22.10.0/24"]
}

resource "azurerm_subnet" "subnet_4_2_11" {
  name                 = "subnet-4-2-11"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_2.name
  address_prefixes     = ["10.22.11.0/24"]
}

resource "azurerm_subnet" "subnet_4_2_12" {
  name                 = "subnet-4-2-12"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_2.name
  address_prefixes     = ["10.22.12.0/24"]
}

resource "azurerm_subnet" "subnet_4_2_13" {
  name                 = "subnet-4-2-13"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_2.name
  address_prefixes     = ["10.22.13.0/24"]
}

resource "azurerm_subnet" "subnet_4_2_14" {
  name                 = "subnet-4-2-14"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_2.name
  address_prefixes     = ["10.22.14.0/24"]
}

resource "azurerm_subnet" "subnet_4_2_15" {
  name                 = "subnet-4-2-15"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_2.name
  address_prefixes     = ["10.22.15.0/24"]
}

resource "azurerm_subnet" "subnet_4_2_16" {
  name                 = "subnet-4-2-16"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_2.name
  address_prefixes     = ["10.22.16.0/24"]
}

resource "azurerm_subnet" "subnet_4_2_17" {
  name                 = "subnet-4-2-17"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_2.name
  address_prefixes     = ["10.22.17.0/24"]
}

resource "azurerm_subnet" "subnet_4_2_18" {
  name                 = "subnet-4-2-18"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_2.name
  address_prefixes     = ["10.22.18.0/24"]
}

resource "azurerm_subnet" "subnet_4_2_19" {
  name                 = "subnet-4-2-19"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_2.name
  address_prefixes     = ["10.22.19.0/24"]
}

resource "azurerm_subnet" "subnet_4_2_20" {
  name                 = "subnet-4-2-20"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_2.name
  address_prefixes     = ["10.22.20.0/24"]
}

resource "azurerm_subnet" "subnet_4_2_21" {
  name                 = "subnet-4-2-21"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_2.name
  address_prefixes     = ["10.22.21.0/24"]
}

resource "azurerm_subnet" "subnet_4_2_22" {
  name                 = "subnet-4-2-22"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_2.name
  address_prefixes     = ["10.22.22.0/24"]
}

resource "azurerm_subnet" "subnet_4_2_23" {
  name                 = "subnet-4-2-23"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_2.name
  address_prefixes     = ["10.22.23.0/24"]
}

resource "azurerm_subnet" "subnet_4_2_24" {
  name                 = "subnet-4-2-24"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_2.name
  address_prefixes     = ["10.22.24.0/24"]
}

resource "azurerm_subnet" "subnet_4_2_25" {
  name                 = "subnet-4-2-25"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_2.name
  address_prefixes     = ["10.22.25.0/24"]
}

resource "azurerm_subnet" "subnet_4_2_26" {
  name                 = "subnet-4-2-26"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_2.name
  address_prefixes     = ["10.22.26.0/24"]
}

resource "azurerm_subnet" "subnet_4_2_27" {
  name                 = "subnet-4-2-27"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_2.name
  address_prefixes     = ["10.22.27.0/24"]
}

resource "azurerm_subnet" "subnet_4_2_28" {
  name                 = "subnet-4-2-28"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_2.name
  address_prefixes     = ["10.22.28.0/24"]
}

resource "azurerm_subnet" "subnet_4_2_29" {
  name                 = "subnet-4-2-29"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_2.name
  address_prefixes     = ["10.22.29.0/24"]
}

resource "azurerm_subnet" "subnet_4_2_30" {
  name                 = "subnet-4-2-30"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_2.name
  address_prefixes     = ["10.22.30.0/24"]
}

resource "azurerm_subnet" "subnet_4_2_31" {
  name                 = "subnet-4-2-31"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_2.name
  address_prefixes     = ["10.22.31.0/24"]
}

resource "azurerm_subnet" "subnet_4_2_32" {
  name                 = "subnet-4-2-32"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_2.name
  address_prefixes     = ["10.22.32.0/24"]
}

resource "azurerm_subnet" "subnet_4_2_33" {
  name                 = "subnet-4-2-33"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_2.name
  address_prefixes     = ["10.22.33.0/24"]
}

resource "azurerm_subnet" "subnet_4_2_34" {
  name                 = "subnet-4-2-34"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_2.name
  address_prefixes     = ["10.22.34.0/24"]
}

resource "azurerm_subnet" "subnet_4_2_35" {
  name                 = "subnet-4-2-35"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_2.name
  address_prefixes     = ["10.22.35.0/24"]
}

resource "azurerm_subnet" "subnet_4_2_36" {
  name                 = "subnet-4-2-36"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_2.name
  address_prefixes     = ["10.22.36.0/24"]
}

resource "azurerm_subnet" "subnet_4_2_37" {
  name                 = "subnet-4-2-37"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_2.name
  address_prefixes     = ["10.22.37.0/24"]
}

resource "azurerm_subnet" "subnet_4_2_38" {
  name                 = "subnet-4-2-38"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_2.name
  address_prefixes     = ["10.22.38.0/24"]
}

resource "azurerm_virtual_network" "vnet_4_3" {
  name                = "vnet-4-3"
  location            = azurerm_resource_group.rg_4.location
  resource_group_name = azurerm_resource_group.rg_4.name
  address_space       = ["10.23.0.0/16"]
}

resource "azurerm_subnet" "subnet_4_3_0" {
  name                 = "subnet-4-3-0"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_3.name
  address_prefixes     = ["10.23.0.0/24"]
}

resource "azurerm_subnet" "subnet_4_3_1" {
  name                 = "subnet-4-3-1"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_3.name
  address_prefixes     = ["10.23.1.0/24"]
}

resource "azurerm_subnet" "subnet_4_3_2" {
  name                 = "subnet-4-3-2"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_3.name
  address_prefixes     = ["10.23.2.0/24"]
}

resource "azurerm_subnet" "subnet_4_3_3" {
  name                 = "subnet-4-3-3"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_3.name
  address_prefixes     = ["10.23.3.0/24"]
}

resource "azurerm_subnet" "subnet_4_3_4" {
  name                 = "subnet-4-3-4"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_3.name
  address_prefixes     = ["10.23.4.0/24"]
}

resource "azurerm_subnet" "subnet_4_3_5" {
  name                 = "subnet-4-3-5"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_3.name
  address_prefixes     = ["10.23.5.0/24"]
}

resource "azurerm_subnet" "subnet_4_3_6" {
  name                 = "subnet-4-3-6"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_3.name
  address_prefixes     = ["10.23.6.0/24"]
}

resource "azurerm_subnet" "subnet_4_3_7" {
  name                 = "subnet-4-3-7"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_3.name
  address_prefixes     = ["10.23.7.0/24"]
}

resource "azurerm_subnet" "subnet_4_3_8" {
  name                 = "subnet-4-3-8"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_3.name
  address_prefixes     = ["10.23.8.0/24"]
}

resource "azurerm_subnet" "subnet_4_3_9" {
  name                 = "subnet-4-3-9"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_3.name
  address_prefixes     = ["10.23.9.0/24"]
}

resource "azurerm_subnet" "subnet_4_3_10" {
  name                 = "subnet-4-3-10"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_3.name
  address_prefixes     = ["10.23.10.0/24"]
}

resource "azurerm_subnet" "subnet_4_3_11" {
  name                 = "subnet-4-3-11"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_3.name
  address_prefixes     = ["10.23.11.0/24"]
}

resource "azurerm_subnet" "subnet_4_3_12" {
  name                 = "subnet-4-3-12"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_3.name
  address_prefixes     = ["10.23.12.0/24"]
}

resource "azurerm_subnet" "subnet_4_3_13" {
  name                 = "subnet-4-3-13"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_3.name
  address_prefixes     = ["10.23.13.0/24"]
}

resource "azurerm_subnet" "subnet_4_3_14" {
  name                 = "subnet-4-3-14"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_3.name
  address_prefixes     = ["10.23.14.0/24"]
}

resource "azurerm_subnet" "subnet_4_3_15" {
  name                 = "subnet-4-3-15"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_3.name
  address_prefixes     = ["10.23.15.0/24"]
}

resource "azurerm_subnet" "subnet_4_3_16" {
  name                 = "subnet-4-3-16"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_3.name
  address_prefixes     = ["10.23.16.0/24"]
}

resource "azurerm_subnet" "subnet_4_3_17" {
  name                 = "subnet-4-3-17"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_3.name
  address_prefixes     = ["10.23.17.0/24"]
}

resource "azurerm_subnet" "subnet_4_3_18" {
  name                 = "subnet-4-3-18"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_3.name
  address_prefixes     = ["10.23.18.0/24"]
}

resource "azurerm_subnet" "subnet_4_3_19" {
  name                 = "subnet-4-3-19"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_3.name
  address_prefixes     = ["10.23.19.0/24"]
}

resource "azurerm_subnet" "subnet_4_3_20" {
  name                 = "subnet-4-3-20"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_3.name
  address_prefixes     = ["10.23.20.0/24"]
}

resource "azurerm_subnet" "subnet_4_3_21" {
  name                 = "subnet-4-3-21"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_3.name
  address_prefixes     = ["10.23.21.0/24"]
}

resource "azurerm_subnet" "subnet_4_3_22" {
  name                 = "subnet-4-3-22"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_3.name
  address_prefixes     = ["10.23.22.0/24"]
}

resource "azurerm_subnet" "subnet_4_3_23" {
  name                 = "subnet-4-3-23"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_3.name
  address_prefixes     = ["10.23.23.0/24"]
}

resource "azurerm_subnet" "subnet_4_3_24" {
  name                 = "subnet-4-3-24"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_3.name
  address_prefixes     = ["10.23.24.0/24"]
}

resource "azurerm_subnet" "subnet_4_3_25" {
  name                 = "subnet-4-3-25"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_3.name
  address_prefixes     = ["10.23.25.0/24"]
}

resource "azurerm_subnet" "subnet_4_3_26" {
  name                 = "subnet-4-3-26"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_3.name
  address_prefixes     = ["10.23.26.0/24"]
}

resource "azurerm_subnet" "subnet_4_3_27" {
  name                 = "subnet-4-3-27"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_3.name
  address_prefixes     = ["10.23.27.0/24"]
}

resource "azurerm_subnet" "subnet_4_3_28" {
  name                 = "subnet-4-3-28"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_3.name
  address_prefixes     = ["10.23.28.0/24"]
}

resource "azurerm_subnet" "subnet_4_3_29" {
  name                 = "subnet-4-3-29"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_3.name
  address_prefixes     = ["10.23.29.0/24"]
}

resource "azurerm_subnet" "subnet_4_3_30" {
  name                 = "subnet-4-3-30"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_3.name
  address_prefixes     = ["10.23.30.0/24"]
}

resource "azurerm_subnet" "subnet_4_3_31" {
  name                 = "subnet-4-3-31"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_3.name
  address_prefixes     = ["10.23.31.0/24"]
}

resource "azurerm_subnet" "subnet_4_3_32" {
  name                 = "subnet-4-3-32"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_3.name
  address_prefixes     = ["10.23.32.0/24"]
}

resource "azurerm_subnet" "subnet_4_3_33" {
  name                 = "subnet-4-3-33"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_3.name
  address_prefixes     = ["10.23.33.0/24"]
}

resource "azurerm_subnet" "subnet_4_3_34" {
  name                 = "subnet-4-3-34"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_3.name
  address_prefixes     = ["10.23.34.0/24"]
}

resource "azurerm_subnet" "subnet_4_3_35" {
  name                 = "subnet-4-3-35"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_3.name
  address_prefixes     = ["10.23.35.0/24"]
}

resource "azurerm_subnet" "subnet_4_3_36" {
  name                 = "subnet-4-3-36"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_3.name
  address_prefixes     = ["10.23.36.0/24"]
}

resource "azurerm_subnet" "subnet_4_3_37" {
  name                 = "subnet-4-3-37"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_3.name
  address_prefixes     = ["10.23.37.0/24"]
}

resource "azurerm_subnet" "subnet_4_3_38" {
  name                 = "subnet-4-3-38"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_3.name
  address_prefixes     = ["10.23.38.0/24"]
}

resource "azurerm_virtual_network" "vnet_4_4" {
  name                = "vnet-4-4"
  location            = azurerm_resource_group.rg_4.location
  resource_group_name = azurerm_resource_group.rg_4.name
  address_space       = ["10.24.0.0/16"]
}

resource "azurerm_subnet" "subnet_4_4_0" {
  name                 = "subnet-4-4-0"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_4.name
  address_prefixes     = ["10.24.0.0/24"]
}

resource "azurerm_subnet" "subnet_4_4_1" {
  name                 = "subnet-4-4-1"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_4.name
  address_prefixes     = ["10.24.1.0/24"]
}

resource "azurerm_subnet" "subnet_4_4_2" {
  name                 = "subnet-4-4-2"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_4.name
  address_prefixes     = ["10.24.2.0/24"]
}

resource "azurerm_subnet" "subnet_4_4_3" {
  name                 = "subnet-4-4-3"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_4.name
  address_prefixes     = ["10.24.3.0/24"]
}

resource "azurerm_subnet" "subnet_4_4_4" {
  name                 = "subnet-4-4-4"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_4.name
  address_prefixes     = ["10.24.4.0/24"]
}

resource "azurerm_subnet" "subnet_4_4_5" {
  name                 = "subnet-4-4-5"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_4.name
  address_prefixes     = ["10.24.5.0/24"]
}

resource "azurerm_subnet" "subnet_4_4_6" {
  name                 = "subnet-4-4-6"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_4.name
  address_prefixes     = ["10.24.6.0/24"]
}

resource "azurerm_subnet" "subnet_4_4_7" {
  name                 = "subnet-4-4-7"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_4.name
  address_prefixes     = ["10.24.7.0/24"]
}

resource "azurerm_subnet" "subnet_4_4_8" {
  name                 = "subnet-4-4-8"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_4.name
  address_prefixes     = ["10.24.8.0/24"]
}

resource "azurerm_subnet" "subnet_4_4_9" {
  name                 = "subnet-4-4-9"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_4.name
  address_prefixes     = ["10.24.9.0/24"]
}

resource "azurerm_subnet" "subnet_4_4_10" {
  name                 = "subnet-4-4-10"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_4.name
  address_prefixes     = ["10.24.10.0/24"]
}

resource "azurerm_subnet" "subnet_4_4_11" {
  name                 = "subnet-4-4-11"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_4.name
  address_prefixes     = ["10.24.11.0/24"]
}

resource "azurerm_subnet" "subnet_4_4_12" {
  name                 = "subnet-4-4-12"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_4.name
  address_prefixes     = ["10.24.12.0/24"]
}

resource "azurerm_subnet" "subnet_4_4_13" {
  name                 = "subnet-4-4-13"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_4.name
  address_prefixes     = ["10.24.13.0/24"]
}

resource "azurerm_subnet" "subnet_4_4_14" {
  name                 = "subnet-4-4-14"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_4.name
  address_prefixes     = ["10.24.14.0/24"]
}

resource "azurerm_subnet" "subnet_4_4_15" {
  name                 = "subnet-4-4-15"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_4.name
  address_prefixes     = ["10.24.15.0/24"]
}

resource "azurerm_subnet" "subnet_4_4_16" {
  name                 = "subnet-4-4-16"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_4.name
  address_prefixes     = ["10.24.16.0/24"]
}

resource "azurerm_subnet" "subnet_4_4_17" {
  name                 = "subnet-4-4-17"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_4.name
  address_prefixes     = ["10.24.17.0/24"]
}

resource "azurerm_subnet" "subnet_4_4_18" {
  name                 = "subnet-4-4-18"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_4.name
  address_prefixes     = ["10.24.18.0/24"]
}

resource "azurerm_subnet" "subnet_4_4_19" {
  name                 = "subnet-4-4-19"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_4.name
  address_prefixes     = ["10.24.19.0/24"]
}

resource "azurerm_subnet" "subnet_4_4_20" {
  name                 = "subnet-4-4-20"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_4.name
  address_prefixes     = ["10.24.20.0/24"]
}

resource "azurerm_subnet" "subnet_4_4_21" {
  name                 = "subnet-4-4-21"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_4.name
  address_prefixes     = ["10.24.21.0/24"]
}

resource "azurerm_subnet" "subnet_4_4_22" {
  name                 = "subnet-4-4-22"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_4.name
  address_prefixes     = ["10.24.22.0/24"]
}

resource "azurerm_subnet" "subnet_4_4_23" {
  name                 = "subnet-4-4-23"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_4.name
  address_prefixes     = ["10.24.23.0/24"]
}

resource "azurerm_subnet" "subnet_4_4_24" {
  name                 = "subnet-4-4-24"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_4.name
  address_prefixes     = ["10.24.24.0/24"]
}

resource "azurerm_subnet" "subnet_4_4_25" {
  name                 = "subnet-4-4-25"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_4.name
  address_prefixes     = ["10.24.25.0/24"]
}

resource "azurerm_subnet" "subnet_4_4_26" {
  name                 = "subnet-4-4-26"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_4.name
  address_prefixes     = ["10.24.26.0/24"]
}

resource "azurerm_subnet" "subnet_4_4_27" {
  name                 = "subnet-4-4-27"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_4.name
  address_prefixes     = ["10.24.27.0/24"]
}

resource "azurerm_subnet" "subnet_4_4_28" {
  name                 = "subnet-4-4-28"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_4.name
  address_prefixes     = ["10.24.28.0/24"]
}

resource "azurerm_subnet" "subnet_4_4_29" {
  name                 = "subnet-4-4-29"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_4.name
  address_prefixes     = ["10.24.29.0/24"]
}

resource "azurerm_subnet" "subnet_4_4_30" {
  name                 = "subnet-4-4-30"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_4.name
  address_prefixes     = ["10.24.30.0/24"]
}

resource "azurerm_subnet" "subnet_4_4_31" {
  name                 = "subnet-4-4-31"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_4.name
  address_prefixes     = ["10.24.31.0/24"]
}

resource "azurerm_subnet" "subnet_4_4_32" {
  name                 = "subnet-4-4-32"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_4.name
  address_prefixes     = ["10.24.32.0/24"]
}

resource "azurerm_subnet" "subnet_4_4_33" {
  name                 = "subnet-4-4-33"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_4.name
  address_prefixes     = ["10.24.33.0/24"]
}

resource "azurerm_subnet" "subnet_4_4_34" {
  name                 = "subnet-4-4-34"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_4.name
  address_prefixes     = ["10.24.34.0/24"]
}

resource "azurerm_subnet" "subnet_4_4_35" {
  name                 = "subnet-4-4-35"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_4.name
  address_prefixes     = ["10.24.35.0/24"]
}

resource "azurerm_subnet" "subnet_4_4_36" {
  name                 = "subnet-4-4-36"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_4.name
  address_prefixes     = ["10.24.36.0/24"]
}

resource "azurerm_subnet" "subnet_4_4_37" {
  name                 = "subnet-4-4-37"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_4.name
  address_prefixes     = ["10.24.37.0/24"]
}

resource "azurerm_subnet" "subnet_4_4_38" {
  name                 = "subnet-4-4-38"
  resource_group_name  = azurerm_resource_group.rg_4.name
  virtual_network_name = azurerm_virtual_network.vnet_4_4.name
  address_prefixes     = ["10.24.38.0/24"]
}
