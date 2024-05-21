terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.103.1"
    }
  }
}

variable "subnet2adress-prefix" {  
  type    = string 
  default = "10.0.2.0/24"
  }

provider "azurerm" {
  # Configuration options
  skip_provider_registration = true
  features {}
}

resource "azurerm_resource_group" "example_rg" {
  name     = "testowa_rg"
  location = "West Europe"
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
    address_prefix = var.subnet2adress-prefix

  }

  tags = {
    environment = "development"
  }
}