#test

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.103.1"
    }
  }
}

provider "azurerm" {
  # Configuration options
  skip_provider_registration = true
    features {}
}

resource "azurerm_resource_group" "example" {
  name     = "testowa_grupa_zasobow"
  location = "East US"
}
