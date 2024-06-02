
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
  depends_on           = [azurerm_virtual_network.example-vn]

}

resource "azurerm_subnet" "subnet2" {
  name                 = "subnet2"
  resource_group_name  = local.rg_name
  virtual_network_name = azurerm_virtual_network.example-vn.name
  address_prefixes     = ["10.0.2.0/24"]
  depends_on           = [azurerm_virtual_network.example-vn]

}


resource "azurerm_network_interface" "example-interface" {
  name                = "example-nic"
  location            = azurerm_resource_group.example_rg.location
  resource_group_name = azurerm_resource_group.example_rg.name


  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example-public-ip.id
  }
}


output "subnets" {
  value      = azurerm_virtual_network.example-vn.subnet
  depends_on = [azurerm_subnet.subnet1, azurerm_subnet.subnet2]

}


resource "azurerm_public_ip" "example-public-ip" {
  name                = "pip1"
  resource_group_name = azurerm_resource_group.example_rg.name
  location            = azurerm_resource_group.example_rg.location
  allocation_method   = "Static"
}

resource "azurerm_network_security_group" "nsg-testowa1" {
  name                = "nsg-testowa1"
  location            = azurerm_resource_group.example_rg.location
  resource_group_name = azurerm_resource_group.example_rg.name

  security_rule {
    name                       = "allowRDPRule"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "dev"
  }
}

resource "azurerm_subnet_network_security_group_association" "association-nsg-testowa1" {
  subnet_id                 = azurerm_subnet.subnet1.id
  network_security_group_id = azurerm_network_security_group.nsg-testowa1.id
}


resource "azurerm_windows_virtual_machine" "vm-koza" {
  name                = "vm-koza"
  resource_group_name = azurerm_resource_group.example_rg.name
  location            = azurerm_resource_group.example_rg.location
  size                = "Standard_F2"
  admin_username      = "abcd"
  # WARNING: This is an example password and is not secure  !!!!!!!!
  #  !!!!!!!!
  admin_password = var.password
  # WARNING: This is an example password and is not secure  !!!!!!!!

  network_interface_ids = [
    azurerm_network_interface.example-interface.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}

resource "azurerm_managed_disk" "datadisk001" {
  name                 = "datadisk001"
  location             = azurerm_resource_group.example_rg.location
  resource_group_name  = azurerm_resource_group.example_rg.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "5"

}

resource "azurerm_virtual_machine_data_disk_attachment" "datadisk001-attachment" {
  managed_disk_id    = azurerm_managed_disk.datadisk001.id
  virtual_machine_id = azurerm_windows_virtual_machine.vm-koza.id
  lun                = "10"
  caching            = "ReadWrite"
}