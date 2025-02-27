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

resource "azurerm_resource_group" "rg-SA" {
  name     = "SA-ResourceGroup"
  location = "East US"
}

resource "azurerm_storage_account" "kdsstorage" {
  name                     = "kdsstorage123"
  resource_group_name      = azurerm_resource_group.rg-SA.name
  location                 = azurerm_resource_group.rg-SA.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "dev"
    Department  = "Management"
  }
}

resource "azurerm_storage_container" "containername" {
  name                  = "technologycontainer"
  storage_account_name  = azurerm_storage_account.kdsstorage.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "containernameReach" {
  name                  = "researchcontainer"
  storage_account_name  = azurerm_storage_account.kdsstorage.name
  container_access_type = "private"
}