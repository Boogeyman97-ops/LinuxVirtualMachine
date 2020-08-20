provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "resource_gp1" {
  name     = "Boogeyman-resources"
  location = "East US"
}

resource "azurerm_virtual_network" "resource_vnet1" {
  name                = "Boogeyman-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.resource_gp1.location
  resource_group_name = azurerm_resource_group.resource_gp1.name
}

resource "azurerm_subnet" "resource_sbnet" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.resource_gp1.name
  virtual_network_name = azurerm_virtual_network.resource_vnet1.name
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_network_interface" "resource_interface1" {
  name                = "example-nic"
  location            = azurerm_resource_group.resource_gp1.location
  resource_group_name = azurerm_resource_group.resource_gp1.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.resource_sbnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "BoogeymanVirtualLinux" {
  name                = "Boogeyman-machine"
  resource_group_name = azurerm_resource_group.resource_gp1.name
  location            = azurerm_resource_group.resource_gp1.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.resource_interface1.id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}
