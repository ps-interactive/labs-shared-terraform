provider "azurerm" {
  skip_provider_registration = true
  features {}
}

variable "location" {
  default = "eastus"
}

resource "azurerm_resource_group" "Production" {
  name     = "Production"
  location = var.location
}

resource "azurerm_resource_group" "Staging" {
  name     = "Staging"
  location = var.location

  tags = {
    Team = "QA"
  }
}

resource "random_string" "storage_account_name" {
  length      = 14
  lower       = true
  upper       = false
  special     = false
}

resource "azurerm_storage_account" "api" {
  name                = random_string.storage_account_name.result
  location            = var.location
  resource_group_name = azurerm_resource_group.Staging.name

  account_tier              = "Standard"
  account_kind              = "StorageV2"
  account_replication_type  = "LRS"
  access_tier               = "Hot"

  tags = {
    Team  = "QA"
    Test1 = "Test1"
    Test2 = "Test2"
    Test3 = "Test3"
    Test4 = "Test4"
    Test5 = "Test5"
    Test6 = "Test6"
  }
}
