provider "azurerm" {
    features {}
  }

  variable "resource_group_name" {    
    default = "ps-deploytest"
  }

  variable "location" {
    default = "eastus"
  }
  
  variable "tags" {

  }
  
  resource "random_string" "random" {
  keepers = {
    # Generate a new id each time we switch a resource group
    rg = "var.resource_group_name"
  }
  length = 5
  special = false
  upper = false
  }


# Creating Storage Account
resource "azurerm_storage_account" "ps-covid-dev-strg" {
  name                     = "pslabstgacc${random_string.random.result}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

#Creating Storage Queue
resource "azurerm_storage_queue" "ps-covid-queue" {
  name                 = "mylabqueue"
  storage_account_name = azurerm_storage_account.ps-covid-dev-strg.name
}

#Creating Storage Table
resource "azurerm_storage_table" "ps-covid-table" {
  name                 = "mylabtable"
  storage_account_name = azurerm_storage_account.ps-covid-dev-strg.name
}
