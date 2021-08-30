# Purpose: Create resources for Azure ML Lab

# References:
# https://github.com/csiebler/azure-machine-learning-terraform

provider "azurerm" {
  features {
  }
  skip_provider_registration = true
}

terraform {
  required_providers {
    azurerm = {
      version = "~> 2.73"
    }
    random = {
      version = "~> 3.0"
    }
  }
}

data "azurerm_client_config" "current" {}

resource "random_string" "uniquenumbers" {
  length  = 12
  upper   = false
  lower   = false
  special = false
}

resource "azurerm_resource_group" "lab" {
  name     = "pslab-rg"
  location = "East US 2"
}

resource "azurerm_application_insights" "lab" {
  name                = "pslab-ml-studio-ai"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  application_type    = "web"
}

resource "azurerm_key_vault" "lab" {
  name                = "pslab${random_string.uniquenumbers.result}-kv"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "premium"
}



resource "azurerm_storage_account" "lab" {
  name                     = "pslabstor${random_string.uniquenumbers.result}"
  location                 = azurerm_resource_group.lab.location
  resource_group_name      = azurerm_resource_group.lab.name
  account_tier             = "Standard"
  account_replication_type = "ZRS"
}

# Create AML Workspace
resource "azurerm_machine_learning_workspace" "lab" {
  name                    = "pslab-ml-studio"
  location                = azurerm_resource_group.lab.location
  resource_group_name     = azurerm_resource_group.lab.name
  application_insights_id = azurerm_application_insights.lab.id
  key_vault_id            = azurerm_key_vault.lab.id
  storage_account_id      = azurerm_storage_account.lab.id

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_machine_learning_compute_instance" "ml_compute" {
  name                          = "pslab-instance01"
  location                      = azurerm_resource_group.lab.location
  machine_learning_workspace_id = azurerm_machine_learning_workspace.lab.id
  virtual_machine_size          = "Standard_DS12_v2"
}
