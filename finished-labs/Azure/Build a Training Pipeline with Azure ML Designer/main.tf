provider "azurerm" {
  skip_provider_registration = true
  features {}
}
variable "location" {
  default = "eastus"
}


data "azurerm_client_config" "current" {}

resource "random_string" "random" {
#   keepers = {
#     # Generate a new id each time we switch a resource group
#     rg = "var.resource_group_name"
#   }
  length  = 5
  special = false
  upper   = false
  #   override_special = "/@£$"
}

# Create Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "pluralsight-lab-${random_string.random.result}"
  location = var.location
}

#Creating Application Insights
resource "azurerm_application_insights" "ps-ai-mlspace" {
  name     = "ps-mlspace-insights"
  location = var.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
}

#Creating KeyVault
resource "azurerm_key_vault" "ps-kv-mlspace" {
  name     = "ps-mlspace-${random_string.random.result}"
  location = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
}

#Creating Storage Account
resource "azurerm_storage_account" "ps-strg-mlspace" {
  name = "strgmlspace${random_string.random.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

#Creating Azure Machine Learning Workspace
resource "azurerm_machine_learning_workspace" "ps-aml-mlspace" {
  name     = "ps-mlspace"
  location = var.location
  resource_group_name     = azurerm_resource_group.rg.name
  application_insights_id = azurerm_application_insights.ps-ai-mlspace.id
  key_vault_id            = azurerm_key_vault.ps-kv-mlspace.id
  storage_account_id      = azurerm_storage_account.ps-strg-mlspace.id

  identity {
    type = "SystemAssigned"
  }
}

# To reset random string
# terraform taint random_string.random
# terraform state rm random_string.random
