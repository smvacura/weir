# Internet egress crosscheck fixture
#
# Topology: one VNet (10.0.0.0/16), no peering. Every subnet differs in how it
# treats a destination outside the VNet, so the pairwise sampler alone cannot
# tell them apart — this fixture only pays off once the crosscheck can aim a
# packet at a public address.
#
#   open_egress    (10.0.1.0/24)  no NSG, no route table: default rules only
#   tag_denied_out (10.0.2.0/24)  outbound Deny on the Internet service tag
#   tag_allowed_in (10.0.3.0/24)  inbound Allow from the Internet service tag
#   via_nva        (10.0.4.0/24)  0.0.0.0/0 UDR to the appliance
#   nva            (10.0.5.0/24)  the forwarding appliance, default routes
#
# What each subnet is for:
#
# open_egress pins the compensating pair described in CLAUDE.md. The reference
# permits egress via AllowInternetOutBound; the engine permits it via
# AllowVNetOutbound, which is built with destination Any and so covers the
# internet by accident while internet_default_rules is still []. They agree
# today for the wrong reason, and fixing either half alone must break this
# subnet's verdict — that is the point of pinning it.
#
# tag_denied_out and tag_allowed_in exercise the Internet service tag in a user
# rule, in both directions. The tag is the complement of VirtualNetwork within
# the routable address space, so these also pin that an in-VNet address is not
# in the Internet tag and a public one is.
#
# via_nva exercises the clause that a 0.0.0.0/0 UDR deletes the reserved drop
# routes ("Azure removed the routes for the 10.0.0.0/8, 192.168.0.0/16, and
# 100.64.0.0/10 address prefixes ... when the UDR for the 0.0.0.0/0 address
# prefix was added"). The reference implements this in
# surviving_reserved_routes; effective_route_table.ml only drops the system
# route sharing the UDR's own prefix, so the /8 drop survives there and wins
# LPM over the /0. Forced tunnelling therefore black-holes private destinations
# in the engine and reaches the appliance in the reference.
#
# nva keeps its default routes so traffic tunnelled to it egresses from there,
# making via_nva -> internet a two-hop path rather than a dead end.
#
# No public IP resource: an azurerm_public_ip carries no address into the IR
# and a NIC ip_configuration has no public IP field, so SNAT is not modelled
# and adding one would only be decoration. Whether a VM without an outbound IP
# has internet access at all is out of scope here.
#
# Only "Internet" and "VirtualAppliance" appear as next_hop_type. The parser's
# next_hop_of_string_opt accepts Internet / VirtualNetwork / VirtualAppliance /
# VirtualGateway / Drop, but Terraform emits "VnetLocal" and "None" for the
# last two shapes, so a drop-route or VnetLocal UDR would fail to parse.

resource "azurerm_resource_group" "rg" {
  name     = "internet-egress-rg"
  location = "eastus"
}

resource "azurerm_virtual_network" "main" {
  name                = "vnet-main"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

# ── Subnets ────────────────────────────────────────────────────────────────

resource "azurerm_subnet" "open_egress" {
  name                 = "subnet-open-egress"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "tag_denied_out" {
  name                 = "subnet-tag-denied-out"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "tag_allowed_in" {
  name                 = "subnet-tag-allowed-in"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.3.0/24"]
}

resource "azurerm_subnet" "via_nva" {
  name                 = "subnet-via-nva"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.4.0/24"]
}

resource "azurerm_subnet" "nva" {
  name                 = "subnet-nva"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.5.0/24"]
}

# ── NSGs ───────────────────────────────────────────────────────────────────

# Outbound to the internet is denied at 100, above the 65001
# AllowInternetOutBound default; in-VNet egress still works.
resource "azurerm_network_security_group" "nsg_tag_denied_out" {
  name                = "nsg-tag-denied-out"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "deny-internet-out"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "10.0.2.0/24"
    destination_address_prefix = "Internet"
  }
  security_rule {
    name                       = "allow-vnet-out"
    priority                   = 110
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "10.0.2.0/24"
    destination_address_prefix = "VirtualNetwork"
  }
  security_rule {
    name                       = "deny-all-out"
    priority                   = 4000
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "allow-vnet-in"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "VirtualNetwork"
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
}

# The mirror image: a public source is admitted at 100, above the deny-all that
# would otherwise catch it, while in-VNet sources come in at 110.
resource "azurerm_network_security_group" "nsg_tag_allowed_in" {
  name                = "nsg-tag-allowed-in"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "allow-internet-in"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "Internet"
    destination_address_prefix = "10.0.3.0/24"
  }
  security_rule {
    name                       = "allow-vnet-in"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "10.0.3.0/24"
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
    name                       = "allow-internet-out"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "10.0.3.0/24"
    destination_address_prefix = "Internet"
  }
  security_rule {
    name                       = "allow-vnet-out"
    priority                   = 110
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "10.0.3.0/24"
    destination_address_prefix = "VirtualNetwork"
  }
  security_rule {
    name                       = "deny-all-out"
    priority                   = 4000
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "assoc_tag_denied_out" {
  subnet_id                 = azurerm_subnet.tag_denied_out.id
  network_security_group_id = azurerm_network_security_group.nsg_tag_denied_out.id
}

resource "azurerm_subnet_network_security_group_association" "assoc_tag_allowed_in" {
  subnet_id                 = azurerm_subnet.tag_allowed_in.id
  network_security_group_id = azurerm_network_security_group.nsg_tag_allowed_in.id
}

# ── Forced tunnelling ──────────────────────────────────────────────────────

# via_nva carries no NSG: the verdict here is meant to turn on routing alone.
resource "azurerm_route_table" "rt_via_nva" {
  name                = "rt-via-nva"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  route {
    name                   = "default-to-nva"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_network_interface.nic_nva_0.private_ip_address
  }
}

resource "azurerm_subnet_route_table_association" "rt_assoc_via_nva" {
  subnet_id      = azurerm_subnet.via_nva.id
  route_table_id = azurerm_route_table.rt_via_nva.id
}

# ── NICs (2 per subnet, so the sampler has a distinct host for self-pairs) ──

resource "azurerm_network_interface" "nic_open_egress_0" {
  name                = "nic-open-egress-0"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.open_egress.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.10"
  }
}

resource "azurerm_network_interface" "nic_open_egress_1" {
  name                = "nic-open-egress-1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.open_egress.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.11"
  }
}

resource "azurerm_network_interface" "nic_tag_denied_out_0" {
  name                = "nic-tag-denied-out-0"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.tag_denied_out.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.2.10"
  }
}

resource "azurerm_network_interface" "nic_tag_denied_out_1" {
  name                = "nic-tag-denied-out-1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.tag_denied_out.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.2.11"
  }
}

resource "azurerm_network_interface" "nic_tag_allowed_in_0" {
  name                = "nic-tag-allowed-in-0"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.tag_allowed_in.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.3.10"
  }
}

resource "azurerm_network_interface" "nic_tag_allowed_in_1" {
  name                = "nic-tag-allowed-in-1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.tag_allowed_in.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.3.11"
  }
}

resource "azurerm_network_interface" "nic_via_nva_0" {
  name                = "nic-via-nva-0"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.via_nva.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.4.10"
  }
}

resource "azurerm_network_interface" "nic_via_nva_1" {
  name                = "nic-via-nva-1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.via_nva.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.4.11"
  }
}

resource "azurerm_network_interface" "nic_nva_0" {
  name                  = "nic-nva-0"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  ip_forwarding_enabled = true
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.nva.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.5.10"
  }
}

resource "azurerm_network_interface" "nic_nva_1" {
  name                = "nic-nva-1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.nva.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.5.11"
  }
}
