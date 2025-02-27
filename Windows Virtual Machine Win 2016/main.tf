terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "tf-vm-rg" {
  name     = "tf-vm-rg"
  location = "East US"
}

resource "azurerm_virtual_network" "tf-vm-vnet" {
  name                = "tf-vm-network"
  resource_group_name = azurerm_resource_group.tf-vm-rg.name
  location            = azurerm_resource_group.tf-vm-rg.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "tf-vm-subnet-1" {
  name                 = "tf-vm-subnet-1"
  resource_group_name  = azurerm_resource_group.tf-vm-rg.name
  virtual_network_name = azurerm_virtual_network.tf-vm-vnet.name
  address_prefixes     = ["10.0.2.0/24"]

}


resource "azurerm_network_interface" "tf-vm-nic" {
  name                = "tf-vm-nic"
  location            = azurerm_resource_group.tf-vm-rg.location
  resource_group_name = azurerm_resource_group.tf-vm-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.tf-vm-subnet-1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.tf-vm-public-ip.id
  }

}

resource "azurerm_windows_virtual_machine" "tf-vm-0" {
  name                  = "tf-vm-0"
  resource_group_name   = azurerm_resource_group.tf-vm-rg.name
  location              = azurerm_resource_group.tf-vm-rg.location
  size                  = "standard_F2"
  admin_username        = "adminuser"
  admin_password        = "P@ssw0rd1234!"
  network_interface_ids = [azurerm_network_interface.tf-vm-nic.id]


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

resource "azurerm_network_security_group" "tf-vm-nsg" {
  name                = "tf-vm-nsg"
  location            = azurerm_resource_group.tf-vm-rg.location
  resource_group_name = azurerm_resource_group.tf-vm-rg.name

  security_rule {
    name                       = "RDP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "tf-vm-nsg-association" {
  subnet_id                 = azurerm_subnet.tf-vm-subnet-1.id
  network_security_group_id = azurerm_network_security_group.tf-vm-nsg.id
}

resource "azurerm_public_ip" "tf-vm-public-ip" {
  name                = "tf-vm-public-ip"
  location            = azurerm_resource_group.tf-vm-rg.location
  resource_group_name = azurerm_resource_group.tf-vm-rg.name
  allocation_method   = "Dynamic"

}
