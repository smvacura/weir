# VNet peering crosscheck fixture
#
# Topology: two peered VNets, bidirectional peering, no route tables/appliances.
#
#   Hub (10.0.0.0/16):   shared (10.0.1.0/24), mgmt (10.0.2.0/24)
#   Spoke (10.1.0.0/16): web (10.1.1.0/24), app (10.1.2.0/24)
#
# NSGs are written so that, at tcp/443 (the port the crosscheck sampler tests),
# reachability differs by pair:
#   - hub_shared is reachable from every other subnet, and can reach every
#     other subnet (its NSG allows the whole hub range in, and both the hub
#     and spoke ranges out).
#   - hub_mgmt is isolated from the spoke in both directions: its own NSG
#     only allows hub-local traffic in, and only allows hub-local traffic out.
#   - spoke_web's NSG only allows egress to hub_shared, not hub_mgmt, so its
#     isolation from hub_mgmt is enforced on the source side.
#   - spoke_app's NSG allows egress to the whole hub range (including
#     hub_mgmt), so its isolation from hub_mgmt is enforced purely by
#     hub_mgmt's own inbound rules on the destination side.
# Both peered VNets rely on the automatic AllowVNetInBound/AllowVNetOutbound
# default rules (effective_nsg.ml's vnetlocal_default_rules) to grant the
# peered range access where no deny-all rule at a lower priority intercepts
# it first.

resource "azurerm_resource_group" "rg" {
  name     = "vnet-peering-rg"
  location = "eastus"
}

resource "azurerm_virtual_network" "hub" {
  name                = "vnet-hub"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_virtual_network" "spoke" {
  name                = "vnet-spoke"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                      = "hub-to-spoke"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.spoke.id
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                      = "spoke-to-hub"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.spoke.name
  remote_virtual_network_id = azurerm_virtual_network.hub.id
}

# ── Subnets ────────────────────────────────────────────────────────────────

resource "azurerm_subnet" "hub_shared" {
  name                 = "subnet-hub-shared"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "hub_mgmt" {
  name                 = "subnet-hub-mgmt"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "spoke_web" {
  name                 = "subnet-spoke-web"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = ["10.1.1.0/24"]
}

resource "azurerm_subnet" "spoke_app" {
  name                 = "subnet-spoke-app"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = ["10.1.2.0/24"]
}

# ── NSGs ───────────────────────────────────────────────────────────────────

resource "azurerm_network_security_group" "nsg_hub_shared" {
  name                = "nsg-hub-shared"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "allow-https-from-spoke"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "10.1.0.0/16"
    destination_address_prefix = "10.0.1.0/24"
  }
  security_rule {
    name                       = "allow-https-from-hub"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "10.0.0.0/16"
    destination_address_prefix = "10.0.1.0/24"
  }
  security_rule {
    name                       = "deny-all-in"
    priority                   = 4000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "allow-https-to-spoke"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "10.0.1.0/24"
    destination_address_prefix = "10.1.0.0/16"
  }
  security_rule {
    name                       = "allow-https-to-hub"
    priority                   = 110
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "10.0.1.0/24"
    destination_address_prefix = "10.0.0.0/16"
  }
  security_rule {
    name                       = "deny-all-out"
    priority                   = 4001
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "nsg_hub_mgmt" {
  name                = "nsg-hub-mgmt"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "allow-https-from-hub"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "10.0.0.0/16"
    destination_address_prefix = "10.0.2.0/24"
  }
  security_rule {
    name                       = "deny-all-in"
    priority                   = 4000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "allow-https-to-hub"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "10.0.2.0/24"
    destination_address_prefix = "10.0.0.0/16"
  }
  security_rule {
    name                       = "deny-all-out"
    priority                   = 4001
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "nsg_spoke_web" {
  name                = "nsg-spoke-web"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "allow-https-from-hub"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "10.0.0.0/16"
    destination_address_prefix = "10.1.1.0/24"
  }
  security_rule {
    name                       = "allow-https-from-spoke"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "10.1.0.0/16"
    destination_address_prefix = "10.1.1.0/24"
  }
  security_rule {
    name                       = "deny-all-in"
    priority                   = 4000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "allow-https-to-spoke"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "10.1.1.0/24"
    destination_address_prefix = "10.1.0.0/16"
  }
  security_rule {
    name                       = "allow-https-to-hub-shared"
    priority                   = 110
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "10.1.1.0/24"
    destination_address_prefix = "10.0.1.0/24"
  }
  security_rule {
    name                       = "deny-all-out"
    priority                   = 4001
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "nsg_spoke_app" {
  name                = "nsg-spoke-app"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "allow-https-from-hub"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "10.0.0.0/16"
    destination_address_prefix = "10.1.2.0/24"
  }
  security_rule {
    name                       = "allow-https-from-spoke"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "10.1.0.0/16"
    destination_address_prefix = "10.1.2.0/24"
  }
  security_rule {
    name                       = "deny-all-in"
    priority                   = 4000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "allow-https-to-hub"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "10.1.2.0/24"
    destination_address_prefix = "10.0.0.0/16"
  }
  security_rule {
    name                       = "allow-https-to-spoke"
    priority                   = 110
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "10.1.2.0/24"
    destination_address_prefix = "10.1.0.0/16"
  }
  security_rule {
    name                       = "deny-all-out"
    priority                   = 4001
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# ── NSG associations ──────────────────────────────────────────────────────

resource "azurerm_subnet_network_security_group_association" "assoc_hub_shared" {
  subnet_id                 = azurerm_subnet.hub_shared.id
  network_security_group_id = azurerm_network_security_group.nsg_hub_shared.id
}

resource "azurerm_subnet_network_security_group_association" "assoc_hub_mgmt" {
  subnet_id                 = azurerm_subnet.hub_mgmt.id
  network_security_group_id = azurerm_network_security_group.nsg_hub_mgmt.id
}

resource "azurerm_subnet_network_security_group_association" "assoc_spoke_web" {
  subnet_id                 = azurerm_subnet.spoke_web.id
  network_security_group_id = azurerm_network_security_group.nsg_spoke_web.id
}

resource "azurerm_subnet_network_security_group_association" "assoc_spoke_app" {
  subnet_id                 = azurerm_subnet.spoke_app.id
  network_security_group_id = azurerm_network_security_group.nsg_spoke_app.id
}

# ── NICs (2 per subnet) ─────────────────────────────────────────────────────

resource "azurerm_network_interface" "nic_hub_shared_0" {
  name                = "nic-hub-shared-0"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.hub_shared.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.10"
  }
}

resource "azurerm_network_interface" "nic_hub_shared_1" {
  name                = "nic-hub-shared-1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.hub_shared.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.11"
  }
}

resource "azurerm_network_interface" "nic_hub_mgmt_0" {
  name                = "nic-hub-mgmt-0"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.hub_mgmt.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.2.10"
  }
}

resource "azurerm_network_interface" "nic_hub_mgmt_1" {
  name                = "nic-hub-mgmt-1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.hub_mgmt.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.2.11"
  }
}

resource "azurerm_network_interface" "nic_spoke_web_0" {
  name                = "nic-spoke-web-0"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.spoke_web.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.1.1.10"
  }
}

resource "azurerm_network_interface" "nic_spoke_web_1" {
  name                = "nic-spoke-web-1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.spoke_web.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.1.1.11"
  }
}

resource "azurerm_network_interface" "nic_spoke_app_0" {
  name                = "nic-spoke-app-0"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.spoke_app.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.1.2.10"
  }
}

resource "azurerm_network_interface" "nic_spoke_app_1" {
  name                = "nic-spoke-app-1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.spoke_app.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.1.2.11"
  }
}
