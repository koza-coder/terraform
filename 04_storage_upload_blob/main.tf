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

#the below time delay added because of problem with resource creation
resource "time_sleep" "wait_50_seconds" {
  create_duration = "50s"
  
}

resource "azurerm_storage_account" "example_storage" {
  name                     = var.storageaccountname 
  resource_group_name      = "testowa_rg"
  location                 = "West Europe"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  depends_on = [time_sleep.wait_50_seconds]   #the time delay added because of problem with resource creation

  tags = {
    environment = "staging"
  }
}

#the below time delay added because of problem with resource creation
resource "time_sleep" "wait_40_seconds" {
  create_duration = "40s"
depends_on = [time_sleep.wait_50_seconds] 
}

resource "azurerm_storage_container" "example_container" {
  name                  = "data-container"
  storage_account_name  = var.storageaccountname
  container_access_type = "blob"
  depends_on = [time_sleep.wait_40_seconds]   #the time delay added because of problem with resource creation

}

#the below time delay added because of problem with resource creation
resource "time_sleep" "wait_45_seconds" {
  create_duration = "45s"
  depends_on = [time_sleep.wait_40_seconds]
}


resource "azurerm_storage_blob" "example_blob" {
  name                   = "exampleBlob-file"
  storage_account_name   = var.storageaccountname
  storage_container_name = "data-container"
  type                   = "Block"
  source                 = "main.tf"
  depends_on = [time_sleep.wait_45_seconds]   #the time delay added because of problem with resource creation

}


