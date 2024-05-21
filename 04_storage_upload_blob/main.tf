terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.103.1"
    }
  }
}

variable "storageaccountname" {  
  type    = string 
  default = "mystorageaccount12334438"
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

# #the below time delay added because of problem with resource creation
# resource "time_sleep" "wait_50_seconds" {
#   create_duration = "50s"
  
# }

resource "azurerm_storage_account" "example_storage" {
  name                     = var.storageaccountname 
  resource_group_name      = azurerm_resource_group.example_rg.name
  location                 = azurerm_resource_group.example_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  #depends_on = [time_sleep.wait_50_seconds]   #the time delay added because of problem with resource creation

  tags = {
    environment = "staging"
  }
}



resource "azurerm_storage_container" "example_container" {
  name                  = "data-container"
  storage_account_name  = azurerm_storage_account.example_storage.name
  container_access_type = "blob"

}



resource "azurerm_storage_blob" "example_blob" {
  name                   = "exampleBlob-file"
  storage_account_name   = azurerm_storage_account.example_storage.name
  storage_container_name = azurerm_storage_container.example_container.name
  type                   = "Block"
  source                 = "main.tf"

}


