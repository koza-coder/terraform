terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.103.1"
    }
  }
}


locals {
  subnet2adress-prefix = "10.0.2.0/24"
  location = "West Europe"
  rg_name = "testowa_rg"
}


provider "azurerm" {
  # Configuration options
  skip_provider_registration = true
  features {}
}

resource "azurerm_resource_group" "example_rg" {
  name     = local.rg_name
  location = local.location
  tags = {
    owner = "Jan Kowalski"
  }
}

resource "azurerm_virtual_network" "example" {
  name                = "first-example-network"
  location            = azurerm_resource_group.example_rg.location
  resource_group_name = azurerm_resource_group.example_rg.name
  address_space       = ["10.0.0.0/16"]

  subnet {
    name           = "subnet1"
    address_prefix = "10.0.1.0/24"
  }

  subnet {
    name           = "subnet2"
    address_prefix = local.subnet2adress-prefix

  }

  tags = {
    environment = "development"
  }
}