resource "azurerm_resource_group" "rg" {
  name     = "hsa-stress-rg"
  location = "eastus"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "hsa-stress-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

# ── Subnets ──────────────────────────────────────────────────────────────────

resource "azurerm_subnet" "subnet_0" {
  name                 = "subnet-0"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "subnet_1" {
  name                 = "subnet-1"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "subnet_2" {
  name                 = "subnet-2"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "subnet_3" {
  name                 = "subnet-3"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.3.0/24"]
}

resource "azurerm_subnet" "subnet_4" {
  name                 = "subnet-4"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.4.0/24"]
}

resource "azurerm_subnet" "subnet_5" {
  name                 = "subnet-5"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.5.0/24"]
}

resource "azurerm_subnet" "subnet_6" {
  name                 = "subnet-6"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.6.0/24"]
}

resource "azurerm_subnet" "subnet_7" {
  name                 = "subnet-7"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.7.0/24"]
}

# ── Subnet NSGs (6 rules each) ───────────────────────────────────────────────

resource "azurerm_network_security_group" "nsg_0" {
  name                = "nsg-subnet-0"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "allow-ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "10.0.7.0/24"
    destination_address_prefix = "10.0.0.0/24"
  }

  security_rule {
    name                       = "allow-http"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-https"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-rdp"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "10.0.7.0/24"
    destination_address_prefix = "10.0.0.0/24"
  }

  security_rule {
    name                       = "allow-app"
    priority                   = 140
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080-8090"
    source_address_prefix      = "10.0.1.0/24"
    destination_address_prefix = "10.0.0.0/24"
  }

  security_rule {
    name                       = "deny-all"
    priority                   = 4000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "nsg_1" {
  name                = "nsg-subnet-1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "allow-ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "10.0.7.0/24"
    destination_address_prefix = "10.0.1.0/24"
  }

  security_rule {
    name                       = "allow-http"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-https"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-rdp"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "10.0.7.0/24"
    destination_address_prefix = "10.0.1.0/24"
  }

  security_rule {
    name                       = "allow-app"
    priority                   = 140
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080-8090"
    source_address_prefix      = "10.0.0.0/24"
    destination_address_prefix = "10.0.1.0/24"
  }

  security_rule {
    name                       = "deny-all"
    priority                   = 4000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "nsg_2" {
  name                = "nsg-subnet-2"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "allow-ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "10.0.7.0/24"
    destination_address_prefix = "10.0.2.0/24"
  }

  security_rule {
    name                       = "allow-http"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-https"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-db"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5432"
    source_address_prefix      = "10.0.1.0/24"
    destination_address_prefix = "10.0.2.0/24"
  }

  security_rule {
    name                       = "allow-udp-dns"
    priority                   = 140
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "53"
    source_address_prefix      = "10.0.0.0/16"
    destination_address_prefix = "10.0.2.0/24"
  }

  security_rule {
    name                       = "deny-all"
    priority                   = 4000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "nsg_3" {
  name                = "nsg-subnet-3"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "allow-ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "10.0.7.0/24"
    destination_address_prefix = "10.0.3.0/24"
  }

  security_rule {
    name                       = "allow-https"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-grpc"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "50051"
    source_address_prefix      = "10.0.0.0/16"
    destination_address_prefix = "10.0.3.0/24"
  }

  security_rule {
    name                       = "allow-metrics"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9090"
    source_address_prefix      = "10.0.4.0/24"
    destination_address_prefix = "10.0.3.0/24"
  }

  security_rule {
    name                       = "allow-cache"
    priority                   = 140
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "6379"
    source_address_prefix      = "10.0.1.0/24"
    destination_address_prefix = "10.0.3.0/24"
  }

  security_rule {
    name                       = "deny-all"
    priority                   = 4000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "nsg_4" {
  name                = "nsg-subnet-4"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "allow-ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "10.0.7.0/24"
    destination_address_prefix = "10.0.4.0/24"
  }

  security_rule {
    name                       = "allow-http"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-https"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-queue"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5672"
    source_address_prefix      = "10.0.0.0/16"
    destination_address_prefix = "10.0.4.0/24"
  }

  security_rule {
    name                       = "allow-app"
    priority                   = 140
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080-8090"
    source_address_prefix      = "10.0.0.0/24"
    destination_address_prefix = "10.0.4.0/24"
  }

  security_rule {
    name                       = "deny-all"
    priority                   = 4000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "nsg_5" {
  name                = "nsg-subnet-5"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "allow-ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "10.0.7.0/24"
    destination_address_prefix = "10.0.5.0/24"
  }

  security_rule {
    name                       = "allow-https"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-storage"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "445"
    source_address_prefix      = "10.0.0.0/16"
    destination_address_prefix = "10.0.5.0/24"
  }

  security_rule {
    name                       = "allow-nfs"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "2049"
    source_address_prefix      = "10.0.0.0/16"
    destination_address_prefix = "10.0.5.0/24"
  }

  security_rule {
    name                       = "allow-backup"
    priority                   = 140
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9000-9010"
    source_address_prefix      = "10.0.6.0/24"
    destination_address_prefix = "10.0.5.0/24"
  }

  security_rule {
    name                       = "deny-all"
    priority                   = 4000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "nsg_6" {
  name                = "nsg-subnet-6"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "allow-ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "10.0.7.0/24"
    destination_address_prefix = "10.0.6.0/24"
  }

  security_rule {
    name                       = "allow-https"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-monitor"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9090"
    source_address_prefix      = "10.0.0.0/16"
    destination_address_prefix = "10.0.6.0/24"
  }

  security_rule {
    name                       = "allow-log"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5044"
    source_address_prefix      = "10.0.0.0/16"
    destination_address_prefix = "10.0.6.0/24"
  }

  security_rule {
    name                       = "allow-trace"
    priority                   = 140
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "14268"
    source_address_prefix      = "10.0.0.0/16"
    destination_address_prefix = "10.0.6.0/24"
  }

  security_rule {
    name                       = "deny-all"
    priority                   = 4000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "nsg_7" {
  name                = "nsg-subnet-7"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "allow-ssh-out"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "10.0.7.0/24"
    destination_address_prefix = "10.0.0.0/16"
  }

  security_rule {
    name                       = "allow-rdp-out"
    priority                   = 110
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "10.0.7.0/24"
    destination_address_prefix = "10.0.0.0/16"
  }

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

  security_rule {
    name                       = "allow-vpn"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "1194"
    source_address_prefix      = "*"
    destination_address_prefix = "10.0.7.0/24"
  }

  security_rule {
    name                       = "allow-icmp"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Icmp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "10.0.0.0/16"
    destination_address_prefix = "10.0.7.0/24"
  }

  security_rule {
    name                       = "deny-all"
    priority                   = 4000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# ── Subnet NSG associations ───────────────────────────────────────────────────

resource "azurerm_subnet_network_security_group_association" "nsg_assoc_0" {
  subnet_id                 = azurerm_subnet.subnet_0.id
  network_security_group_id = azurerm_network_security_group.nsg_0.id
}

resource "azurerm_subnet_network_security_group_association" "nsg_assoc_1" {
  subnet_id                 = azurerm_subnet.subnet_1.id
  network_security_group_id = azurerm_network_security_group.nsg_1.id
}

resource "azurerm_subnet_network_security_group_association" "nsg_assoc_2" {
  subnet_id                 = azurerm_subnet.subnet_2.id
  network_security_group_id = azurerm_network_security_group.nsg_2.id
}

resource "azurerm_subnet_network_security_group_association" "nsg_assoc_3" {
  subnet_id                 = azurerm_subnet.subnet_3.id
  network_security_group_id = azurerm_network_security_group.nsg_3.id
}

resource "azurerm_subnet_network_security_group_association" "nsg_assoc_4" {
  subnet_id                 = azurerm_subnet.subnet_4.id
  network_security_group_id = azurerm_network_security_group.nsg_4.id
}

resource "azurerm_subnet_network_security_group_association" "nsg_assoc_5" {
  subnet_id                 = azurerm_subnet.subnet_5.id
  network_security_group_id = azurerm_network_security_group.nsg_5.id
}

resource "azurerm_subnet_network_security_group_association" "nsg_assoc_6" {
  subnet_id                 = azurerm_subnet.subnet_6.id
  network_security_group_id = azurerm_network_security_group.nsg_6.id
}

resource "azurerm_subnet_network_security_group_association" "nsg_assoc_7" {
  subnet_id                 = azurerm_subnet.subnet_7.id
  network_security_group_id = azurerm_network_security_group.nsg_7.id
}

# ── NICs (2 per subnet, static IPs) ──────────────────────────────────────────

resource "azurerm_network_interface" "nic_0_0" {
  name                = "nic-0-0"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet_0.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.0.10"
  }
}

resource "azurerm_network_interface" "nic_0_1" {
  name                = "nic-0-1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet_0.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.0.11"
  }
}

resource "azurerm_network_interface" "nic_1_0" {
  name                = "nic-1-0"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet_1.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.10"
  }
}

resource "azurerm_network_interface" "nic_1_1" {
  name                = "nic-1-1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet_1.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.11"
  }
}

resource "azurerm_network_interface" "nic_2_0" {
  name                = "nic-2-0"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet_2.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.2.10"
  }
}

resource "azurerm_network_interface" "nic_2_1" {
  name                = "nic-2-1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet_2.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.2.11"
  }
}

resource "azurerm_network_interface" "nic_3_0" {
  name                = "nic-3-0"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet_3.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.3.10"
  }
}

resource "azurerm_network_interface" "nic_3_1" {
  name                = "nic-3-1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet_3.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.3.11"
  }
}

resource "azurerm_network_interface" "nic_4_0" {
  name                = "nic-4-0"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet_4.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.4.10"
  }
}

resource "azurerm_network_interface" "nic_4_1" {
  name                = "nic-4-1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet_4.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.4.11"
  }
}

resource "azurerm_network_interface" "nic_5_0" {
  name                = "nic-5-0"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet_5.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.5.10"
  }
}

resource "azurerm_network_interface" "nic_5_1" {
  name                = "nic-5-1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet_5.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.5.11"
  }
}

resource "azurerm_network_interface" "nic_6_0" {
  name                = "nic-6-0"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet_6.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.6.10"
  }
}

resource "azurerm_network_interface" "nic_6_1" {
  name                = "nic-6-1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet_6.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.6.11"
  }
}

resource "azurerm_network_interface" "nic_7_0" {
  name                = "nic-7-0"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet_7.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.7.10"
  }
}

resource "azurerm_network_interface" "nic_7_1" {
  name                = "nic-7-1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet_7.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.7.11"
  }
}

# ── NIC NSGs (4 rules each) ───────────────────────────────────────────────────

resource "azurerm_network_security_group" "nic_nsg_0" {
  name                = "nsg-nic-0"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "allow-ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "10.0.7.0/24"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-https"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-app"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "10.0.0.0/16"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "deny-all"
    priority                   = 4000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "nic_nsg_1" {
  name                = "nsg-nic-1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "allow-ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "10.0.7.0/24"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-https"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-db"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5432"
    source_address_prefix      = "10.0.1.0/24"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "deny-all"
    priority                   = 4000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "nic_nsg_2" {
  name                = "nsg-nic-2"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "allow-ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "10.0.7.0/24"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-https"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-grpc"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "50051"
    source_address_prefix      = "10.0.0.0/16"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "deny-all"
    priority                   = 4000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "nic_nsg_3" {
  name                = "nsg-nic-3"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "allow-ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "10.0.7.0/24"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-https"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-metrics"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9090"
    source_address_prefix      = "10.0.6.0/24"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "deny-all"
    priority                   = 4000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# ── NIC NSG associations (pair each NIC to a NIC NSG) ────────────────────────

resource "azurerm_network_interface_security_group_association" "nic_nsg_assoc_0_0" {
  network_interface_id      = azurerm_network_interface.nic_0_0.id
  network_security_group_id = azurerm_network_security_group.nic_nsg_0.id
}

resource "azurerm_network_interface_security_group_association" "nic_nsg_assoc_0_1" {
  network_interface_id      = azurerm_network_interface.nic_0_1.id
  network_security_group_id = azurerm_network_security_group.nic_nsg_1.id
}

resource "azurerm_network_interface_security_group_association" "nic_nsg_assoc_1_0" {
  network_interface_id      = azurerm_network_interface.nic_1_0.id
  network_security_group_id = azurerm_network_security_group.nic_nsg_2.id
}

resource "azurerm_network_interface_security_group_association" "nic_nsg_assoc_1_1" {
  network_interface_id      = azurerm_network_interface.nic_1_1.id
  network_security_group_id = azurerm_network_security_group.nic_nsg_3.id
}

resource "azurerm_network_interface_security_group_association" "nic_nsg_assoc_2_0" {
  network_interface_id      = azurerm_network_interface.nic_2_0.id
  network_security_group_id = azurerm_network_security_group.nic_nsg_0.id
}

resource "azurerm_network_interface_security_group_association" "nic_nsg_assoc_2_1" {
  network_interface_id      = azurerm_network_interface.nic_2_1.id
  network_security_group_id = azurerm_network_security_group.nic_nsg_1.id
}

resource "azurerm_network_interface_security_group_association" "nic_nsg_assoc_3_0" {
  network_interface_id      = azurerm_network_interface.nic_3_0.id
  network_security_group_id = azurerm_network_security_group.nic_nsg_2.id
}

resource "azurerm_network_interface_security_group_association" "nic_nsg_assoc_3_1" {
  network_interface_id      = azurerm_network_interface.nic_3_1.id
  network_security_group_id = azurerm_network_security_group.nic_nsg_3.id
}

resource "azurerm_network_interface_security_group_association" "nic_nsg_assoc_4_0" {
  network_interface_id      = azurerm_network_interface.nic_4_0.id
  network_security_group_id = azurerm_network_security_group.nic_nsg_0.id
}

resource "azurerm_network_interface_security_group_association" "nic_nsg_assoc_4_1" {
  network_interface_id      = azurerm_network_interface.nic_4_1.id
  network_security_group_id = azurerm_network_security_group.nic_nsg_1.id
}

resource "azurerm_network_interface_security_group_association" "nic_nsg_assoc_5_0" {
  network_interface_id      = azurerm_network_interface.nic_5_0.id
  network_security_group_id = azurerm_network_security_group.nic_nsg_2.id
}

resource "azurerm_network_interface_security_group_association" "nic_nsg_assoc_5_1" {
  network_interface_id      = azurerm_network_interface.nic_5_1.id
  network_security_group_id = azurerm_network_security_group.nic_nsg_3.id
}

resource "azurerm_network_interface_security_group_association" "nic_nsg_assoc_6_0" {
  network_interface_id      = azurerm_network_interface.nic_6_0.id
  network_security_group_id = azurerm_network_security_group.nic_nsg_0.id
}

resource "azurerm_network_interface_security_group_association" "nic_nsg_assoc_6_1" {
  network_interface_id      = azurerm_network_interface.nic_6_1.id
  network_security_group_id = azurerm_network_security_group.nic_nsg_1.id
}

resource "azurerm_network_interface_security_group_association" "nic_nsg_assoc_7_0" {
  network_interface_id      = azurerm_network_interface.nic_7_0.id
  network_security_group_id = azurerm_network_security_group.nic_nsg_2.id
}

resource "azurerm_network_interface_security_group_association" "nic_nsg_assoc_7_1" {
  network_interface_id      = azurerm_network_interface.nic_7_1.id
  network_security_group_id = azurerm_network_security_group.nic_nsg_3.id
}

# ── Route table on subnet-1 via VirtualAppliance (nic_0_0) ───────────────────

resource "azurerm_route_table" "rt_1" {
  name                = "rt-subnet-1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  route {
    name                   = "to-appliance"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_network_interface.nic_0_0.private_ip_address
  }
}

resource "azurerm_subnet_route_table_association" "rt_assoc_1" {
  subnet_id      = azurerm_subnet.subnet_1.id
  route_table_id = azurerm_route_table.rt_1.id
}
