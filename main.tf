provider "azurerm" {
    subscription_id = "abb119be-c8dd-42be-9b60-64269a565c61"
  client_id       = "a20d5aa9-3048-40db-9f4c-a9ca299682cd"
  client_secret   = "602.UsePMu9clcH4oT~V4ho54Z2L.NUNP."
  tenant_id       = "426008e7-7e3f-4ad1-ba2d-7fd1e5c4d3b2"
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
  name                = "Boogeyman-nic"
  location            = azurerm_resource_group.resource_gp1.location
  resource_group_name = azurerm_resource_group.resource_gp1.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.resource_sbnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "BoogeymanVirtualLinuxMachine" {
  name                = "Boogeyman-machine"
  resource_group_name = azurerm_resource_group.resource_gp1.name
  location            = azurerm_resource_group.resource_gp1.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.resource_interface1.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("home/azureuser/.ssh/id_rsa.pub")
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
