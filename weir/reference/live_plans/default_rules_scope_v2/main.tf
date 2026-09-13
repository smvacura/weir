# Scenario: default_rules_scope_v2.
# Source public IPs provide explicit outbound connectivity for the public probes.
# Denies cover the probe port, leaving VM agent HTTPS connectivity available.
# Before probing, wait for cloud-init status --wait on the destination and check
# systemctl is-active probe-listener.service through az vm run-command.
locals {
  slug     = "default-rules-scope-v2"
  location = "eastus"
}

resource "azurerm_resource_group" "fixture" {
  name     = "${local.slug}-rg"
  location = local.location
}

resource "tls_private_key" "admin" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "azurerm_virtual_network" "sources" {
  name                = "${local.slug}-sources-vnet"
  location            = azurerm_resource_group.fixture.location
  resource_group_name = azurerm_resource_group.fixture.name
  address_space       = ["10.70.0.0/16"]
}

resource "azurerm_virtual_network" "destination" {
  name                = "${local.slug}-destination-vnet"
  location            = azurerm_resource_group.fixture.location
  resource_group_name = azurerm_resource_group.fixture.name
  address_space       = ["10.71.0.0/16"]
}

resource "azurerm_virtual_network_peering" "sources_to_destination" {
  name                         = "${local.slug}-sources-to-destination"
  resource_group_name          = azurerm_resource_group.fixture.name
  virtual_network_name         = azurerm_virtual_network.sources.name
  remote_virtual_network_id    = azurerm_virtual_network.destination.id
  allow_virtual_network_access = true
}

resource "azurerm_virtual_network_peering" "destination_to_sources" {
  name                         = "${local.slug}-destination-to-sources"
  resource_group_name          = azurerm_resource_group.fixture.name
  virtual_network_name         = azurerm_virtual_network.destination.name
  remote_virtual_network_id    = azurerm_virtual_network.sources.id
  allow_virtual_network_access = true
}

resource "azurerm_subnet" "baseline" {
  name                            = "${local.slug}-baseline-subnet"
  resource_group_name             = azurerm_resource_group.fixture.name
  virtual_network_name            = azurerm_virtual_network.sources.name
  address_prefixes                = ["10.70.1.0/24"]
  default_outbound_access_enabled = false
}

resource "azurerm_network_security_group" "baseline" {
  name                = "${local.slug}-baseline-nsg"
  location            = azurerm_resource_group.fixture.location
  resource_group_name = azurerm_resource_group.fixture.name
}

resource "azurerm_subnet_network_security_group_association" "baseline" {
  subnet_id                 = azurerm_subnet.baseline.id
  network_security_group_id = azurerm_network_security_group.baseline.id
}

resource "azurerm_public_ip" "baseline" {
  name                = "${local.slug}-baseline-pip"
  location            = azurerm_resource_group.fixture.location
  resource_group_name = azurerm_resource_group.fixture.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "baseline" {
  name                = "${local.slug}-baseline-nic"
  location            = azurerm_resource_group.fixture.location
  resource_group_name = azurerm_resource_group.fixture.name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.baseline.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.70.1.4"
    public_ip_address_id          = azurerm_public_ip.baseline.id
  }
}

resource "azurerm_linux_virtual_machine" "baseline" {
  name                            = "${local.slug}-baseline-vm"
  location                        = azurerm_resource_group.fixture.location
  resource_group_name             = azurerm_resource_group.fixture.name
  size                            = "Standard_F1ads_v7"
  admin_username                  = "azureuser"
  disable_password_authentication = true
  network_interface_ids           = [azurerm_network_interface.baseline.id]

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.admin.public_key_openssh
  }

  os_disk {
    name                 = "${local.slug}-baseline-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  depends_on = [
    azurerm_subnet_network_security_group_association.baseline,
    azurerm_virtual_network_peering.sources_to_destination,
    azurerm_virtual_network_peering.destination_to_sources,
  ]
}

resource "azurerm_subnet" "deny_virtual_network" {
  name                            = "${local.slug}-deny-virtual-network-subnet"
  resource_group_name             = azurerm_resource_group.fixture.name
  virtual_network_name            = azurerm_virtual_network.sources.name
  address_prefixes                = ["10.70.2.0/24"]
  default_outbound_access_enabled = false
}

resource "azurerm_network_security_group" "deny_virtual_network" {
  name                = "${local.slug}-deny-virtual-network-nsg"
  location            = azurerm_resource_group.fixture.location
  resource_group_name = azurerm_resource_group.fixture.name
  security_rule {
    name                       = "${local.slug}-deny-virtual-network-outbound"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "VirtualNetwork"
  }
}

resource "azurerm_subnet_network_security_group_association" "deny_virtual_network" {
  subnet_id                 = azurerm_subnet.deny_virtual_network.id
  network_security_group_id = azurerm_network_security_group.deny_virtual_network.id
}

resource "azurerm_public_ip" "deny_virtual_network" {
  name                = "${local.slug}-deny-virtual-network-pip"
  location            = azurerm_resource_group.fixture.location
  resource_group_name = azurerm_resource_group.fixture.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "deny_virtual_network" {
  name                = "${local.slug}-deny-virtual-network-nic"
  location            = azurerm_resource_group.fixture.location
  resource_group_name = azurerm_resource_group.fixture.name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.deny_virtual_network.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.70.2.4"
    public_ip_address_id          = azurerm_public_ip.deny_virtual_network.id
  }
}

resource "azurerm_linux_virtual_machine" "deny_virtual_network" {
  name                            = "${local.slug}-deny-virtual-network-vm"
  location                        = azurerm_resource_group.fixture.location
  resource_group_name             = azurerm_resource_group.fixture.name
  size                            = "Standard_F1ads_v7"
  admin_username                  = "azureuser"
  disable_password_authentication = true
  network_interface_ids           = [azurerm_network_interface.deny_virtual_network.id]

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.admin.public_key_openssh
  }

  os_disk {
    name                 = "${local.slug}-deny-virtual-network-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  depends_on = [
    azurerm_subnet_network_security_group_association.deny_virtual_network,
    azurerm_virtual_network_peering.sources_to_destination,
    azurerm_virtual_network_peering.destination_to_sources,
  ]
}

resource "azurerm_subnet" "deny_internet" {
  name                            = "${local.slug}-deny-internet-subnet"
  resource_group_name             = azurerm_resource_group.fixture.name
  virtual_network_name            = azurerm_virtual_network.sources.name
  address_prefixes                = ["10.70.3.0/24"]
  default_outbound_access_enabled = false
}

resource "azurerm_network_security_group" "deny_internet" {
  name                = "${local.slug}-deny-internet-nsg"
  location            = azurerm_resource_group.fixture.location
  resource_group_name = azurerm_resource_group.fixture.name
  security_rule {
    name                       = "${local.slug}-deny-internet-outbound"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "Internet"
  }
}

resource "azurerm_subnet_network_security_group_association" "deny_internet" {
  subnet_id                 = azurerm_subnet.deny_internet.id
  network_security_group_id = azurerm_network_security_group.deny_internet.id
}

resource "azurerm_public_ip" "deny_internet" {
  name                = "${local.slug}-deny-internet-pip"
  location            = azurerm_resource_group.fixture.location
  resource_group_name = azurerm_resource_group.fixture.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "deny_internet" {
  name                = "${local.slug}-deny-internet-nic"
  location            = azurerm_resource_group.fixture.location
  resource_group_name = azurerm_resource_group.fixture.name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.deny_internet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.70.3.4"
    public_ip_address_id          = azurerm_public_ip.deny_internet.id
  }
}

resource "azurerm_linux_virtual_machine" "deny_internet" {
  name                            = "${local.slug}-deny-internet-vm"
  location                        = azurerm_resource_group.fixture.location
  resource_group_name             = azurerm_resource_group.fixture.name
  size                            = "Standard_F1ads_v7"
  admin_username                  = "azureuser"
  disable_password_authentication = true
  network_interface_ids           = [azurerm_network_interface.deny_internet.id]

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.admin.public_key_openssh
  }

  os_disk {
    name                 = "${local.slug}-deny-internet-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  depends_on = [
    azurerm_subnet_network_security_group_association.deny_internet,
    azurerm_virtual_network_peering.sources_to_destination,
    azurerm_virtual_network_peering.destination_to_sources,
  ]
}

resource "azurerm_subnet" "destination" {
  name                            = "${local.slug}-destination-subnet"
  resource_group_name             = azurerm_resource_group.fixture.name
  virtual_network_name            = azurerm_virtual_network.destination.name
  address_prefixes                = ["10.71.1.0/24"]
  default_outbound_access_enabled = false
}

resource "azurerm_network_security_group" "destination" {
  name                = "${local.slug}-destination-nsg"
  location            = azurerm_resource_group.fixture.location
  resource_group_name = azurerm_resource_group.fixture.name
  security_rule {
    name                       = "${local.slug}-allow-listener-inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "destination" {
  subnet_id                 = azurerm_subnet.destination.id
  network_security_group_id = azurerm_network_security_group.destination.id
}

resource "azurerm_public_ip" "destination" {
  name                = "${local.slug}-destination-pip"
  location            = azurerm_resource_group.fixture.location
  resource_group_name = azurerm_resource_group.fixture.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "destination" {
  name                = "${local.slug}-destination-nic"
  location            = azurerm_resource_group.fixture.location
  resource_group_name = azurerm_resource_group.fixture.name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.destination.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.71.1.4"
    public_ip_address_id          = azurerm_public_ip.destination.id
  }
}

resource "azurerm_linux_virtual_machine" "destination" {
  name                            = "${local.slug}-destination-vm"
  location                        = azurerm_resource_group.fixture.location
  resource_group_name             = azurerm_resource_group.fixture.name
  size                            = "Standard_F1ads_v7"
  admin_username                  = "azureuser"
  disable_password_authentication = true
  network_interface_ids           = [azurerm_network_interface.destination.id]

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.admin.public_key_openssh
  }

  os_disk {
    name                 = "${local.slug}-destination-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  # Uses the image's Python runtime; no package download is needed.
  custom_data = base64encode(<<-CLOUD_INIT
    #cloud-config
    write_files:
      - path: /etc/systemd/system/probe-listener.service
        permissions: '0644'
        content: |
          [Unit]
          Description=Fixture TCP listener
          After=network.target

          [Service]
          User=nobody
          ExecStart=/usr/bin/python3 -m http.server 8080 --bind 0.0.0.0 --directory /tmp
          Restart=always
          RestartSec=1

          [Install]
          WantedBy=multi-user.target
    runcmd:
      - [systemctl, daemon-reload]
      - [systemctl, enable, --now, probe-listener.service]
    CLOUD_INIT
  )
  depends_on = [
    azurerm_subnet_network_security_group_association.destination,
    azurerm_virtual_network_peering.sources_to_destination,
    azurerm_virtual_network_peering.destination_to_sources,
  ]
}
