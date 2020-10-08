provider "azurerm" {
  features {}
}

variable "resource_group_name" {}
variable "location" {}

resource "random_string" "_" {
  length  = 16
  upper   = false
  lower   = false
  special = false
}

resource "azurerm_storage_account" "_" {
  name                     = "function${random_string._.result}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "_" {
  name                = "ASP"
  resource_group_name = var.resource_group_name
  location            = var.location
  kind                = "FunctionApp"

  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "azurerm_function_app" "_" {
  name                       = "servicebus${random_string._.result}"
  resource_group_name        = var.resource_group_name
  location                   = var.location
  app_service_plan_id        = azurerm_app_service_plan._.id
  storage_account_name       = azurerm_storage_account._.name
  storage_account_access_key = azurerm_storage_account._.primary_access_key
}
