provider "azurerm" {
  features {}
}
variable "resource_group_name" {
  # this variable is automatically assigned by the cloud sandbox
}
variable "location" {
  # this variable is automatically assigned by the cloud sandbox
}
resource "random_id" "id" {
  keepers = {
    resource_group = var.resource_group_name
  }
  byte_length = 2
}
resource "azurerm_storage_account" "funcstorage" {
  name                     = "functionstorage${random_id.id.hex}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
resource "azurerm_app_service_plan" "example" {
  name                = "azure-functions-test-service-plan"
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "FunctionApp"
  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}
resource "azurerm_function_app" "example" {
  name                       = "functionslab${random_id.id.hex}"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  app_service_plan_id        = azurerm_app_service_plan.example.id
  storage_account_name       = azurerm_storage_account.funcstorage.name
  storage_account_access_key = azurerm_storage_account.funcstorage.primary_access_key
}
resource "azurerm_storage_account" "labstorage" {
  name                     = "functionslabstorage${random_id.id.hex}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}