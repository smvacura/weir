terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.1.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "4ea0407d-ce9c-47ef-9c86-9dc6224e45f2"
}

# Basic single resource
resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "eastus"
}