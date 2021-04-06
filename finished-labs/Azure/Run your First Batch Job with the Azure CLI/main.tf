provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

resource "random_string" "random" {
  length = 6
  special = false
  upper = false
  number = true
}

module "resource_group" {
  source = "./azurerm/resource_group"
}

module "storage_account" {
  source = "./azurerm/storage_account"
  rg = module.resource_group.azurerm_resource_group_rg_name
  rg_loc = module.resource_group.azurerm_resource_group_rg_location
}

module "key-vault" {
  source = "./azurerm/key_vault"
  azureml_random = random_string.random.result
  rg = module.resource_group.azurerm_resource_group_rg_name
  rg_loc = module.resource_group.azurerm_resource_group_rg_location
  tenant = data.azurerm_client_config.current.tenant_id
}

module "application_insights" {
  source = "./azurerm/application_insights"
  azureml_random = random_string.random.result
  rg = module.resource_group.azurerm_resource_group_rg_name
  rg_loc = module.resource_group.azurerm_resource_group_rg_location
}

module "machine-learning" {
  source = "./azurerm/machine_learning"
  app_insights_id = module.application_insights.azurerm_application_insights_pluralsight_app_insights_id
  azureml_random = random_string.random.result
  rg = module.resource_group.azurerm_resource_group_rg_name
  rg_loc = module.resource_group.azurerm_resource_group_rg_location
  storage_id = module.storage_account.azurerm_storage_account_storage_id
  vault_id = module.key-vault.azurerm_key_vault-pluralsight_vault_id
}

module "remote-executor" {
  source = "./azurerm/remote_executor"
  azureml_workspace_name = module.machine-learning.azurerm_machine_learning_workspace_pluralsight_ai_name
  rg = module.resource_group.azurerm_resource_group_rg_name
}
