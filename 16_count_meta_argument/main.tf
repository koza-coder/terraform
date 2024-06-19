
#if you want to print a graph, then run: 
# terraform graph -type=plan | dot -Tpng >graph.png 
locals {
  location = "West Europe"
  rg_name  = "testowa_rg"
}


resource "azurerm_resource_group" "example_rg" {
  name     = local.rg_name
  location = local.location
  tags = {
    owner = "Jan Kowalski"
  }
}

resource "azurerm_storage_account" "storage-account1" {
  count                    = 3
  name                     = "${count.index}storageaccount1abcd1"
  resource_group_name      = azurerm_resource_group.example_rg.name
  location                 = azurerm_resource_group.example_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags = {
    env = "dev"
  }

}