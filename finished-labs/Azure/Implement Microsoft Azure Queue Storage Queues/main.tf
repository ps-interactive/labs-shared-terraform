provider "azurerm" {
  features {}
}
variable "resource_group_name" {
}
variable "location" {
  default = "eastus"
}

# Create storage account.
resource "random_string" "random_suffix" {
  length  = 10
  upper   = false
  number  = true
  lower   = false
  special = false
}

resource "azurerm_storage_account" "storage" {
  name                     = "azurequeueslab${random_string.random_suffix.result}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Create function app.
resource "azurerm_app_service_plan" "service_plan" {
  name                = "AzureQueuesLabServicePlan"
  resource_group_name = var.resource_group_name
  location            = var.location
  kind                = "FunctionApp"

  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "azurerm_function_app" "function_app" {
  name                       = "AzureQueuesLabFunctions"
  resource_group_name        = var.resource_group_name
  location                   = var.location
  app_service_plan_id        = azurerm_app_service_plan.service_plan.id
  storage_account_name       = azurerm_storage_account.storage.name
  storage_account_access_key = azurerm_storage_account.storage.primary_access_key
  version                    = "~2"
}

# Create logic app.
resource "azurerm_logic_app_workflow" "logic_app" {
  name                = "AzureQueuesLabLogicApp"
  resource_group_name        = var.resource_group_name
  location                   = var.location
}
