
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

output "subnet1and2" {
  value = tolist([azurerm_subnet.subnet1, azurerm_subnet.subnet2])
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
    name                       = "allowSSHRule"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
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
resource "tls_private_key" "linux-vm-key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "local_file" "linux-vm-key-file" {
  content    = tls_private_key.linux-vm-key.private_key_pem
  filename   = "linux-vm-key.pem"
  depends_on = [tls_private_key.linux-vm-key]
}

resource "azurerm_linux_virtual_machine" "linux-vm-koza" {
  name                = "linux-vm-koza"
  resource_group_name = azurerm_resource_group.example_rg.name
  location            = azurerm_resource_group.example_rg.location
  #after the creation of the VM, change the VM size a different one and re-run the "terraform apply" command to see the changes
  size           = "Standard_B2s"
  depends_on     = [tls_private_key.linux-vm-key]
  admin_username = "abcd"
  admin_ssh_key {
    username   = "abcd"
    public_key = tls_private_key.linux-vm-key.public_key_openssh
  }
  # WARNING: This is an example password and is not secure  !!!!!!!!
  #  !!!!!!!!
  admin_password = var.password_VM
  # WARNING: This is an example password and is not secure  !!!!!!!!

  network_interface_ids = [
    azurerm_network_interface.example-interface.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}
