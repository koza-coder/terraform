terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.103.1"
    }
  }
}


locals {
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

resource "azurerm_virtual_network" "example-vn" {
  name                = "first-example-network"
  location            = azurerm_resource_group.example_rg.location
  resource_group_name = azurerm_resource_group.example_rg.name
  address_space       = ["10.0.0.0/16"]

  tags = {
    environment = "development"
  }
}



  resource "azurerm_subnet" "subnet1" {
  name                 = "subnet1"
  resource_group_name  = local.rg_name
  virtual_network_name = azurerm_virtual_network.example-vn.name
  address_prefixes     = ["10.0.1.0/24"]
  depends_on = [ azurerm_virtual_network.example-vn ]

}

  resource "azurerm_subnet" "subnet2" {
  name                 = "subnet2"
  resource_group_name  = local.rg_name
  virtual_network_name = azurerm_virtual_network.example-vn.name
  address_prefixes     = ["10.0.2.0/24"]
  depends_on = [ azurerm_virtual_network.example-vn ]

}


resource "azurerm_network_interface" "example-interface" {
  name                = "example-nic"
  location            = azurerm_resource_group.example_rg.location
  resource_group_name = azurerm_resource_group.example_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
  }
}