terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.103.1"
    }
  }
}

provider "azurerm" {
  # Configuration options
  skip_provider_registration = true
  features {}
}

resource "azurerm_resource_group" "example_rg" {
  name     = "testowa_rg"
  location = "East US"
  tags = {
    owner = "Jan Kowalski"
  }
}

resource "time_sleep" "wait_30_seconds" {
  create_duration = "30s"
}

resource "azurerm_storage_account" "example_storage" {
  name                     = "mystorageaccount12334455"
  resource_group_name      = "testowa_rg"
  location                 = "East US"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  depends_on = [time_sleep.wait_30_seconds]

  tags = {
    environment = "staging"
  }
}



