
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
  name                     = "storageaccount1abcd1a"
  resource_group_name      = azurerm_resource_group.example_rg.name
  location                 = azurerm_resource_group.example_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags = {
    env = "dev"
  }

}

resource "azurerm_storage_container" "storage-container" {
  name                   = "data"
  storage_account_name   = azurerm_storage_account.storage-account1.name
  container_access_type  = "private"
  depends_on = [azurerm_storage_account.storage-account1]
  
}

resource "azurerm_storage_blob" "storage-blob" {
for_each = {
  file1 = "example1.txt"
  file2 = "example2.txt"
  file3 = "example3.txt"
}

  name = "${each.key}.txt"
  storage_account_name   = azurerm_storage_account.storage-account1.name
  storage_container_name = azurerm_storage_container.storage-container.name
  type                   = "Block"
  source                 = each.value
  depends_on = [azurerm_storage_container.storage-container]
  
}