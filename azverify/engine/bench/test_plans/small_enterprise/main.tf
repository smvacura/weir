# Small enterprise benchmark
#
# Topology: hub-and-spoke (single VNet, no peering modeled yet)
#
#   Hub:    mgmt (bastion/jumpbox), nva (firewall appliance), monitor
#   Prod:   dmz, web, app, svc, db, cache, queue
#   Dev:    web, app, db, ci
#   Shared: backup, storage
#
# All prod/dev subnets route 0.0.0.0/0 through the NVA (nic-hub-nva-0 at 10.0.1.10).
# 16 subnets, 32 NICs, 48 HSA nodes.

resource "azurerm_resource_group" "rg" {
  name     = "small-enterprise-rg"
  location = "eastus"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "small-enterprise-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

# ── Hub subnets ───────────────────────────────────────────────────────────────

resource "azurerm_subnet" "hub_mgmt" {
  name                 = "subnet-hub-mgmt"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "hub_nva" {
  name                 = "subnet-hub-nva"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "hub_monitor" {
  name                 = "subnet-hub-monitor"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# ── Prod subnets ──────────────────────────────────────────────────────────────

resource "azurerm_subnet" "prod_dmz" {
  name                 = "subnet-prod-dmz"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.10.0/24"]
}

resource "azurerm_subnet" "prod_web" {
  name                 = "subnet-prod-web"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.11.0/24"]
}

resource "azurerm_subnet" "prod_app" {
  name                 = "subnet-prod-app"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.12.0/24"]
}

resource "azurerm_subnet" "prod_svc" {
  name                 = "subnet-prod-svc"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.13.0/24"]
}

resource "azurerm_subnet" "prod_db" {
  name                 = "subnet-prod-db"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.14.0/24"]
}

resource "azurerm_subnet" "prod_cache" {
  name                 = "subnet-prod-cache"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.15.0/24"]
}

resource "azurerm_subnet" "prod_queue" {
  name                 = "subnet-prod-queue"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.16.0/24"]
}

# ── Dev subnets ───────────────────────────────────────────────────────────────

resource "azurerm_subnet" "dev_web" {
  name                 = "subnet-dev-web"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.20.0/24"]
}

resource "azurerm_subnet" "dev_app" {
  name                 = "subnet-dev-app"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.21.0/24"]
}

resource "azurerm_subnet" "dev_db" {
  name                 = "subnet-dev-db"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.22.0/24"]
}

resource "azurerm_subnet" "dev_ci" {
  name                 = "subnet-dev-ci"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.23.0/24"]
}

# ── Shared subnets ────────────────────────────────────────────────────────────

resource "azurerm_subnet" "shared_backup" {
  name                 = "subnet-shared-backup"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.30.0/24"]
}

resource "azurerm_subnet" "shared_storage" {
  name                 = "subnet-shared-storage"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.31.0/24"]
}

# ── NSGs ──────────────────────────────────────────────────────────────────────

resource "azurerm_network_security_group" "nsg_hub_mgmt" {
  name                = "nsg-hub-mgmt"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "allow-ssh-inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "10.0.0.0/24"
  }
  security_rule {
    name                       = "allow-rdp-inbound"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "10.0.0.0/24"
  }
  security_rule {
    name                       = "allow-https-inbound"
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
    name                       = "allow-icmp-internal"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Icmp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "10.0.0.0/16"
    destination_address_prefix = "10.0.0.0/24"
  }
  security_rule {
    name                       = "allow-ssh-out"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "10.0.0.0/24"
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
    source_address_prefix      = "10.0.0.0/24"
    destination_address_prefix = "10.0.0.0/16"
  }
  security_rule {
    name                       = "allow-https-out"
    priority                   = 120
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
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

resource "azurerm_network_security_group" "nsg_hub_nva" {
  name                = "nsg-hub-nva"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "allow-all-internal-in"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "10.0.0.0/16"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "allow-all-internal-out"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "10.0.0.0/16"
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

resource "azurerm_network_security_group" "nsg_hub_monitor" {
  name                = "nsg-hub-monitor"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "allow-prometheus-scrape"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9090"
    source_address_prefix      = "10.0.0.0/16"
    destination_address_prefix = "10.0.2.0/24"
  }
  security_rule {
    name                       = "allow-logstash"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5044"
    source_address_prefix      = "10.0.0.0/16"
    destination_address_prefix = "10.0.2.0/24"
  }
  security_rule {
    name                       = "allow-elasticsearch"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9200"
    source_address_prefix      = "10.0.2.0/24"
    destination_address_prefix = "10.0.2.0/24"
  }
  security_rule {
    name                       = "allow-grafana"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3000"
    source_address_prefix      = "10.0.0.0/24"
    destination_address_prefix = "10.0.2.0/24"
  }
  security_rule {
    name                       = "allow-ssh-from-mgmt"
    priority                   = 140
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "10.0.0.0/24"
    destination_address_prefix = "10.0.2.0/24"
  }
  security_rule {
    name                       = "allow-alertmanager"
    priority                   = 150
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9093"
    source_address_prefix      = "10.0.0.0/24"
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

resource "azurerm_network_security_group" "nsg_prod_dmz" {
  name                = "nsg-prod-dmz"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "allow-https-inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "10.0.10.0/24"
  }
  security_rule {
    name                       = "allow-http-inbound"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "10.0.10.0/24"
  }
  security_rule {
    name                       = "allow-ssh-from-mgmt"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "10.0.0.0/24"
    destination_address_prefix = "10.0.10.0/24"
  }
  security_rule {
    name                       = "allow-waf-health"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "65503-65534"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "allow-metrics-out"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9090"
    source_address_prefix      = "10.0.10.0/24"
    destination_address_prefix = "10.0.2.0/24"
  }
  security_rule {
    name                       = "allow-web-out"
    priority                   = 110
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080-8090"
    source_address_prefix      = "10.0.10.0/24"
    destination_address_prefix = "10.0.11.0/24"
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

resource "azurerm_network_security_group" "nsg_prod_web" {
  name                = "nsg-prod-web"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "allow-http-from-dmz"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "10.0.10.0/24"
    destination_address_prefix = "10.0.11.0/24"
  }
  security_rule {
    name                       = "allow-https-from-dmz"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "10.0.10.0/24"
    destination_address_prefix = "10.0.11.0/24"
  }
  security_rule {
    name                       = "allow-app-port-from-dmz"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080-8090"
    source_address_prefix      = "10.0.10.0/24"
    destination_address_prefix = "10.0.11.0/24"
  }
  security_rule {
    name                       = "allow-ssh-from-mgmt"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "10.0.0.0/24"
    destination_address_prefix = "10.0.11.0/24"
  }
  security_rule {
    name                       = "allow-icmp-from-monitor"
    priority                   = 140
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Icmp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "10.0.2.0/24"
    destination_address_prefix = "10.0.11.0/24"
  }
  security_rule {
    name                       = "allow-app-out"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080-8090"
    source_address_prefix      = "10.0.11.0/24"
    destination_address_prefix = "10.0.12.0/24"
  }
  security_rule {
    name                       = "allow-grpc-out"
    priority                   = 110
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "50051"
    source_address_prefix      = "10.0.11.0/24"
    destination_address_prefix = "10.0.13.0/24"
  }
  security_rule {
    name                       = "allow-metrics-out"
    priority                   = 120
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9090"
    source_address_prefix      = "10.0.11.0/24"
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

resource "azurerm_network_security_group" "nsg_prod_app" {
  name                = "nsg-prod-app"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "allow-from-web"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080-8090"
    source_address_prefix      = "10.0.11.0/24"
    destination_address_prefix = "10.0.12.0/24"
  }
  security_rule {
    name                       = "allow-grpc-from-web"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "50051"
    source_address_prefix      = "10.0.11.0/24"
    destination_address_prefix = "10.0.12.0/24"
  }
  security_rule {
    name                       = "allow-grpc-from-svc"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "50051"
    source_address_prefix      = "10.0.13.0/24"
    destination_address_prefix = "10.0.12.0/24"
  }
  security_rule {
    name                       = "allow-ssh-from-mgmt"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "10.0.0.0/24"
    destination_address_prefix = "10.0.12.0/24"
  }
  security_rule {
    name                       = "allow-metrics-scrape"
    priority                   = 140
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9090"
    source_address_prefix      = "10.0.2.0/24"
    destination_address_prefix = "10.0.12.0/24"
  }
  security_rule {
    name                       = "allow-db-out"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5432"
    source_address_prefix      = "10.0.12.0/24"
    destination_address_prefix = "10.0.14.0/24"
  }
  security_rule {
    name                       = "allow-cache-out"
    priority                   = 110
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "6379"
    source_address_prefix      = "10.0.12.0/24"
    destination_address_prefix = "10.0.15.0/24"
  }
  security_rule {
    name                       = "allow-queue-out"
    priority                   = 120
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5672"
    source_address_prefix      = "10.0.12.0/24"
    destination_address_prefix = "10.0.16.0/24"
  }
  security_rule {
    name                       = "allow-svc-out"
    priority                   = 130
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "50051"
    source_address_prefix      = "10.0.12.0/24"
    destination_address_prefix = "10.0.13.0/24"
  }
  security_rule {
    name                       = "allow-metrics-out"
    priority                   = 140
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9090"
    source_address_prefix      = "10.0.12.0/24"
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

resource "azurerm_network_security_group" "nsg_prod_svc" {
  name                = "nsg-prod-svc"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "allow-grpc-from-web"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "50051"
    source_address_prefix      = "10.0.11.0/24"
    destination_address_prefix = "10.0.13.0/24"
  }
  security_rule {
    name                       = "allow-grpc-from-app"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "50051"
    source_address_prefix      = "10.0.12.0/24"
    destination_address_prefix = "10.0.13.0/24"
  }
  security_rule {
    name                       = "allow-grpc-internal"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "50051"
    source_address_prefix      = "10.0.13.0/24"
    destination_address_prefix = "10.0.13.0/24"
  }
  security_rule {
    name                       = "allow-ssh-from-mgmt"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "10.0.0.0/24"
    destination_address_prefix = "10.0.13.0/24"
  }
  security_rule {
    name                       = "allow-metrics-scrape"
    priority                   = 140
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9090"
    source_address_prefix      = "10.0.2.0/24"
    destination_address_prefix = "10.0.13.0/24"
  }
  security_rule {
    name                       = "allow-db-out"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5432"
    source_address_prefix      = "10.0.13.0/24"
    destination_address_prefix = "10.0.14.0/24"
  }
  security_rule {
    name                       = "allow-cache-out"
    priority                   = 110
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "6379"
    source_address_prefix      = "10.0.13.0/24"
    destination_address_prefix = "10.0.15.0/24"
  }
  security_rule {
    name                       = "allow-queue-out"
    priority                   = 120
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5672"
    source_address_prefix      = "10.0.13.0/24"
    destination_address_prefix = "10.0.16.0/24"
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

resource "azurerm_network_security_group" "nsg_prod_db" {
  name                = "nsg-prod-db"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "allow-postgres-from-app"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5432"
    source_address_prefix      = "10.0.12.0/24"
    destination_address_prefix = "10.0.14.0/24"
  }
  security_rule {
    name                       = "allow-postgres-from-svc"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5432"
    source_address_prefix      = "10.0.13.0/24"
    destination_address_prefix = "10.0.14.0/24"
  }
  security_rule {
    name                       = "allow-postgres-replica"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5433"
    source_address_prefix      = "10.0.14.0/24"
    destination_address_prefix = "10.0.14.0/24"
  }
  security_rule {
    name                       = "allow-ssh-from-mgmt"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "10.0.0.0/24"
    destination_address_prefix = "10.0.14.0/24"
  }
  security_rule {
    name                       = "allow-metrics-scrape"
    priority                   = 140
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9187"
    source_address_prefix      = "10.0.2.0/24"
    destination_address_prefix = "10.0.14.0/24"
  }
  security_rule {
    name                       = "allow-backup-out"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9000-9010"
    source_address_prefix      = "10.0.14.0/24"
    destination_address_prefix = "10.0.30.0/24"
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

resource "azurerm_network_security_group" "nsg_prod_cache" {
  name                = "nsg-prod-cache"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "allow-redis-from-app"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "6379"
    source_address_prefix      = "10.0.12.0/24"
    destination_address_prefix = "10.0.15.0/24"
  }
  security_rule {
    name                       = "allow-redis-from-svc"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "6379"
    source_address_prefix      = "10.0.13.0/24"
    destination_address_prefix = "10.0.15.0/24"
  }
  security_rule {
    name                       = "allow-redis-from-web"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "6379"
    source_address_prefix      = "10.0.11.0/24"
    destination_address_prefix = "10.0.15.0/24"
  }
  security_rule {
    name                       = "allow-redis-cluster"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "16379"
    source_address_prefix      = "10.0.15.0/24"
    destination_address_prefix = "10.0.15.0/24"
  }
  security_rule {
    name                       = "allow-ssh-from-mgmt"
    priority                   = 140
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "10.0.0.0/24"
    destination_address_prefix = "10.0.15.0/24"
  }
  security_rule {
    name                       = "allow-metrics-scrape"
    priority                   = 150
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9121"
    source_address_prefix      = "10.0.2.0/24"
    destination_address_prefix = "10.0.15.0/24"
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

resource "azurerm_network_security_group" "nsg_prod_queue" {
  name                = "nsg-prod-queue"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "allow-amqp-from-app"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5672"
    source_address_prefix      = "10.0.12.0/24"
    destination_address_prefix = "10.0.16.0/24"
  }
  security_rule {
    name                       = "allow-amqp-from-svc"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5672"
    source_address_prefix      = "10.0.13.0/24"
    destination_address_prefix = "10.0.16.0/24"
  }
  security_rule {
    name                       = "allow-amqps-from-app"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5671"
    source_address_prefix      = "10.0.12.0/24"
    destination_address_prefix = "10.0.16.0/24"
  }
  security_rule {
    name                       = "allow-mgmt-ui"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "15672"
    source_address_prefix      = "10.0.0.0/24"
    destination_address_prefix = "10.0.16.0/24"
  }
  security_rule {
    name                       = "allow-erlang-cluster"
    priority                   = 140
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "4369"
    source_address_prefix      = "10.0.16.0/24"
    destination_address_prefix = "10.0.16.0/24"
  }
  security_rule {
    name                       = "allow-ssh-from-mgmt"
    priority                   = 150
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "10.0.0.0/24"
    destination_address_prefix = "10.0.16.0/24"
  }
  security_rule {
    name                       = "allow-metrics-scrape"
    priority                   = 160
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "15692"
    source_address_prefix      = "10.0.2.0/24"
    destination_address_prefix = "10.0.16.0/24"
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

resource "azurerm_network_security_group" "nsg_dev_web" {
  name                = "nsg-dev-web"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "allow-http"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "10.0.0.0/16"
    destination_address_prefix = "10.0.20.0/24"
  }
  security_rule {
    name                       = "allow-https"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "10.0.0.0/16"
    destination_address_prefix = "10.0.20.0/24"
  }
  security_rule {
    name                       = "allow-app-ports"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080-8090"
    source_address_prefix      = "10.0.0.0/16"
    destination_address_prefix = "10.0.20.0/24"
  }
  security_rule {
    name                       = "allow-ssh-from-mgmt"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "10.0.0.0/24"
    destination_address_prefix = "10.0.20.0/24"
  }
  security_rule {
    name                       = "allow-ci-deploy"
    priority                   = 140
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080-8090"
    source_address_prefix      = "10.0.23.0/24"
    destination_address_prefix = "10.0.20.0/24"
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

resource "azurerm_network_security_group" "nsg_dev_app" {
  name                = "nsg-dev-app"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "allow-from-dev-web"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080-8090"
    source_address_prefix      = "10.0.20.0/24"
    destination_address_prefix = "10.0.21.0/24"
  }
  security_rule {
    name                       = "allow-grpc-from-dev-web"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "50051"
    source_address_prefix      = "10.0.20.0/24"
    destination_address_prefix = "10.0.21.0/24"
  }
  security_rule {
    name                       = "allow-ssh-from-mgmt"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "10.0.0.0/24"
    destination_address_prefix = "10.0.21.0/24"
  }
  security_rule {
    name                       = "allow-ci-deploy"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080-8090"
    source_address_prefix      = "10.0.23.0/24"
    destination_address_prefix = "10.0.21.0/24"
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

resource "azurerm_network_security_group" "nsg_dev_db" {
  name                = "nsg-dev-db"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "allow-postgres-from-dev"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5432"
    source_address_prefix      = "10.0.20.0/22"
    destination_address_prefix = "10.0.22.0/24"
  }
  security_rule {
    name                       = "allow-ssh-from-mgmt"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "10.0.0.0/24"
    destination_address_prefix = "10.0.22.0/24"
  }
  security_rule {
    name                       = "allow-ci-migrations"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5432"
    source_address_prefix      = "10.0.23.0/24"
    destination_address_prefix = "10.0.22.0/24"
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

resource "azurerm_network_security_group" "nsg_dev_ci" {
  name                = "nsg-dev-ci"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "allow-https-inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "10.0.0.0/16"
    destination_address_prefix = "10.0.23.0/24"
  }
  security_rule {
    name                       = "allow-ssh-from-mgmt"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "10.0.0.0/24"
    destination_address_prefix = "10.0.23.0/24"
  }
  security_rule {
    name                       = "allow-agent-port"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "7788"
    source_address_prefix      = "10.0.0.0/16"
    destination_address_prefix = "10.0.23.0/24"
  }
  security_rule {
    name                       = "allow-all-out-to-dev"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "10.0.23.0/24"
    destination_address_prefix = "10.0.20.0/22"
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

resource "azurerm_network_security_group" "nsg_shared_backup" {
  name                = "nsg-shared-backup"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "allow-backup-agent"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9000-9010"
    source_address_prefix      = "10.0.0.0/16"
    destination_address_prefix = "10.0.30.0/24"
  }
  security_rule {
    name                       = "allow-ssh-from-mgmt"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "10.0.0.0/24"
    destination_address_prefix = "10.0.30.0/24"
  }
  security_rule {
    name                       = "allow-storage-out"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "445"
    source_address_prefix      = "10.0.30.0/24"
    destination_address_prefix = "10.0.31.0/24"
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

resource "azurerm_network_security_group" "nsg_shared_storage" {
  name                = "nsg-shared-storage"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "allow-smb-from-backup"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "445"
    source_address_prefix      = "10.0.30.0/24"
    destination_address_prefix = "10.0.31.0/24"
  }
  security_rule {
    name                       = "allow-nfs-from-prod"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "2049"
    source_address_prefix      = "10.0.10.0/20"
    destination_address_prefix = "10.0.31.0/24"
  }
  security_rule {
    name                       = "allow-iscsi-from-db"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3260"
    source_address_prefix      = "10.0.14.0/24"
    destination_address_prefix = "10.0.31.0/24"
  }
  security_rule {
    name                       = "allow-ssh-from-mgmt"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "10.0.0.0/24"
    destination_address_prefix = "10.0.31.0/24"
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

# ── NSG associations ──────────────────────────────────────────────────────────

resource "azurerm_subnet_network_security_group_association" "assoc_hub_mgmt" {
  subnet_id                 = azurerm_subnet.hub_mgmt.id
  network_security_group_id = azurerm_network_security_group.nsg_hub_mgmt.id
}

resource "azurerm_subnet_network_security_group_association" "assoc_hub_nva" {
  subnet_id                 = azurerm_subnet.hub_nva.id
  network_security_group_id = azurerm_network_security_group.nsg_hub_nva.id
}

resource "azurerm_subnet_network_security_group_association" "assoc_hub_monitor" {
  subnet_id                 = azurerm_subnet.hub_monitor.id
  network_security_group_id = azurerm_network_security_group.nsg_hub_monitor.id
}

resource "azurerm_subnet_network_security_group_association" "assoc_prod_dmz" {
  subnet_id                 = azurerm_subnet.prod_dmz.id
  network_security_group_id = azurerm_network_security_group.nsg_prod_dmz.id
}

resource "azurerm_subnet_network_security_group_association" "assoc_prod_web" {
  subnet_id                 = azurerm_subnet.prod_web.id
  network_security_group_id = azurerm_network_security_group.nsg_prod_web.id
}

resource "azurerm_subnet_network_security_group_association" "assoc_prod_app" {
  subnet_id                 = azurerm_subnet.prod_app.id
  network_security_group_id = azurerm_network_security_group.nsg_prod_app.id
}

resource "azurerm_subnet_network_security_group_association" "assoc_prod_svc" {
  subnet_id                 = azurerm_subnet.prod_svc.id
  network_security_group_id = azurerm_network_security_group.nsg_prod_svc.id
}

resource "azurerm_subnet_network_security_group_association" "assoc_prod_db" {
  subnet_id                 = azurerm_subnet.prod_db.id
  network_security_group_id = azurerm_network_security_group.nsg_prod_db.id
}

resource "azurerm_subnet_network_security_group_association" "assoc_prod_cache" {
  subnet_id                 = azurerm_subnet.prod_cache.id
  network_security_group_id = azurerm_network_security_group.nsg_prod_cache.id
}

resource "azurerm_subnet_network_security_group_association" "assoc_prod_queue" {
  subnet_id                 = azurerm_subnet.prod_queue.id
  network_security_group_id = azurerm_network_security_group.nsg_prod_queue.id
}

resource "azurerm_subnet_network_security_group_association" "assoc_dev_web" {
  subnet_id                 = azurerm_subnet.dev_web.id
  network_security_group_id = azurerm_network_security_group.nsg_dev_web.id
}

resource "azurerm_subnet_network_security_group_association" "assoc_dev_app" {
  subnet_id                 = azurerm_subnet.dev_app.id
  network_security_group_id = azurerm_network_security_group.nsg_dev_app.id
}

resource "azurerm_subnet_network_security_group_association" "assoc_dev_db" {
  subnet_id                 = azurerm_subnet.dev_db.id
  network_security_group_id = azurerm_network_security_group.nsg_dev_db.id
}

resource "azurerm_subnet_network_security_group_association" "assoc_dev_ci" {
  subnet_id                 = azurerm_subnet.dev_ci.id
  network_security_group_id = azurerm_network_security_group.nsg_dev_ci.id
}

resource "azurerm_subnet_network_security_group_association" "assoc_shared_backup" {
  subnet_id                 = azurerm_subnet.shared_backup.id
  network_security_group_id = azurerm_network_security_group.nsg_shared_backup.id
}

resource "azurerm_subnet_network_security_group_association" "assoc_shared_storage" {
  subnet_id                 = azurerm_subnet.shared_storage.id
  network_security_group_id = azurerm_network_security_group.nsg_shared_storage.id
}

# ── NICs (2 per subnet) ───────────────────────────────────────────────────────

resource "azurerm_network_interface" "nic_hub_mgmt_0" {
  name                = "nic-hub-mgmt-0"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.hub_mgmt.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.0.10"
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
    private_ip_address            = "10.0.0.11"
  }
}

resource "azurerm_network_interface" "nic_hub_nva_0" {
  name                = "nic-hub-nva-0"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.hub_nva.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.10"
  }
}

resource "azurerm_network_interface" "nic_hub_nva_1" {
  name                = "nic-hub-nva-1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.hub_nva.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.11"
  }
}

resource "azurerm_network_interface" "nic_hub_monitor_0" {
  name                = "nic-hub-monitor-0"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.hub_monitor.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.2.10"
  }
}

resource "azurerm_network_interface" "nic_hub_monitor_1" {
  name                = "nic-hub-monitor-1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.hub_monitor.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.2.11"
  }
}

resource "azurerm_network_interface" "nic_prod_dmz_0" {
  name                = "nic-prod-dmz-0"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.prod_dmz.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.10.10"
  }
}

resource "azurerm_network_interface" "nic_prod_dmz_1" {
  name                = "nic-prod-dmz-1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.prod_dmz.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.10.11"
  }
}

resource "azurerm_network_interface" "nic_prod_web_0" {
  name                = "nic-prod-web-0"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.prod_web.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.11.10"
  }
}

resource "azurerm_network_interface" "nic_prod_web_1" {
  name                = "nic-prod-web-1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.prod_web.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.11.11"
  }
}

resource "azurerm_network_interface" "nic_prod_app_0" {
  name                = "nic-prod-app-0"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.prod_app.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.12.10"
  }
}

resource "azurerm_network_interface" "nic_prod_app_1" {
  name                = "nic-prod-app-1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.prod_app.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.12.11"
  }
}

resource "azurerm_network_interface" "nic_prod_svc_0" {
  name                = "nic-prod-svc-0"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.prod_svc.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.13.10"
  }
}

resource "azurerm_network_interface" "nic_prod_svc_1" {
  name                = "nic-prod-svc-1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.prod_svc.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.13.11"
  }
}

resource "azurerm_network_interface" "nic_prod_db_0" {
  name                = "nic-prod-db-0"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.prod_db.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.14.10"
  }
}

resource "azurerm_network_interface" "nic_prod_db_1" {
  name                = "nic-prod-db-1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.prod_db.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.14.11"
  }
}

resource "azurerm_network_interface" "nic_prod_cache_0" {
  name                = "nic-prod-cache-0"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.prod_cache.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.15.10"
  }
}

resource "azurerm_network_interface" "nic_prod_cache_1" {
  name                = "nic-prod-cache-1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.prod_cache.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.15.11"
  }
}

resource "azurerm_network_interface" "nic_prod_queue_0" {
  name                = "nic-prod-queue-0"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.prod_queue.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.16.10"
  }
}

resource "azurerm_network_interface" "nic_prod_queue_1" {
  name                = "nic-prod-queue-1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.prod_queue.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.16.11"
  }
}

resource "azurerm_network_interface" "nic_dev_web_0" {
  name                = "nic-dev-web-0"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.dev_web.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.20.10"
  }
}

resource "azurerm_network_interface" "nic_dev_web_1" {
  name                = "nic-dev-web-1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.dev_web.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.20.11"
  }
}

resource "azurerm_network_interface" "nic_dev_app_0" {
  name                = "nic-dev-app-0"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.dev_app.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.21.10"
  }
}

resource "azurerm_network_interface" "nic_dev_app_1" {
  name                = "nic-dev-app-1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.dev_app.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.21.11"
  }
}

resource "azurerm_network_interface" "nic_dev_db_0" {
  name                = "nic-dev-db-0"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.dev_db.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.22.10"
  }
}

resource "azurerm_network_interface" "nic_dev_db_1" {
  name                = "nic-dev-db-1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.dev_db.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.22.11"
  }
}

resource "azurerm_network_interface" "nic_dev_ci_0" {
  name                = "nic-dev-ci-0"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.dev_ci.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.23.10"
  }
}

resource "azurerm_network_interface" "nic_dev_ci_1" {
  name                = "nic-dev-ci-1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.dev_ci.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.23.11"
  }
}

resource "azurerm_network_interface" "nic_shared_backup_0" {
  name                = "nic-shared-backup-0"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.shared_backup.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.30.10"
  }
}

resource "azurerm_network_interface" "nic_shared_backup_1" {
  name                = "nic-shared-backup-1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.shared_backup.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.30.11"
  }
}

resource "azurerm_network_interface" "nic_shared_storage_0" {
  name                = "nic-shared-storage-0"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.shared_storage.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.31.10"
  }
}

resource "azurerm_network_interface" "nic_shared_storage_1" {
  name                = "nic-shared-storage-1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.shared_storage.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.31.11"
  }
}

# ── Route tables: prod/dev subnets route through NVA ─────────────────────────

resource "azurerm_route_table" "rt_prod" {
  name                = "rt-prod"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  route {
    name                   = "to-nva"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_network_interface.nic_hub_nva_0.private_ip_address
  }
}

resource "azurerm_route_table" "rt_dev" {
  name                = "rt-dev"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  route {
    name                   = "to-nva"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_network_interface.nic_hub_nva_0.private_ip_address
  }
}

resource "azurerm_subnet_route_table_association" "rt_assoc_prod_dmz" {
  subnet_id      = azurerm_subnet.prod_dmz.id
  route_table_id = azurerm_route_table.rt_prod.id
}

resource "azurerm_subnet_route_table_association" "rt_assoc_prod_web" {
  subnet_id      = azurerm_subnet.prod_web.id
  route_table_id = azurerm_route_table.rt_prod.id
}

resource "azurerm_subnet_route_table_association" "rt_assoc_prod_app" {
  subnet_id      = azurerm_subnet.prod_app.id
  route_table_id = azurerm_route_table.rt_prod.id
}

resource "azurerm_subnet_route_table_association" "rt_assoc_prod_svc" {
  subnet_id      = azurerm_subnet.prod_svc.id
  route_table_id = azurerm_route_table.rt_prod.id
}

resource "azurerm_subnet_route_table_association" "rt_assoc_prod_db" {
  subnet_id      = azurerm_subnet.prod_db.id
  route_table_id = azurerm_route_table.rt_prod.id
}

resource "azurerm_subnet_route_table_association" "rt_assoc_prod_cache" {
  subnet_id      = azurerm_subnet.prod_cache.id
  route_table_id = azurerm_route_table.rt_prod.id
}

resource "azurerm_subnet_route_table_association" "rt_assoc_prod_queue" {
  subnet_id      = azurerm_subnet.prod_queue.id
  route_table_id = azurerm_route_table.rt_prod.id
}

resource "azurerm_subnet_route_table_association" "rt_assoc_dev_web" {
  subnet_id      = azurerm_subnet.dev_web.id
  route_table_id = azurerm_route_table.rt_dev.id
}

resource "azurerm_subnet_route_table_association" "rt_assoc_dev_app" {
  subnet_id      = azurerm_subnet.dev_app.id
  route_table_id = azurerm_route_table.rt_dev.id
}

resource "azurerm_subnet_route_table_association" "rt_assoc_dev_db" {
  subnet_id      = azurerm_subnet.dev_db.id
  route_table_id = azurerm_route_table.rt_dev.id
}

resource "azurerm_subnet_route_table_association" "rt_assoc_dev_ci" {
  subnet_id      = azurerm_subnet.dev_ci.id
  route_table_id = azurerm_route_table.rt_dev.id
}
