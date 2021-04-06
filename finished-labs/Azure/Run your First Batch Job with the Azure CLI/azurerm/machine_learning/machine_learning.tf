resource "azurerm_machine_learning_workspace" "pluralsight-ai" {
  name                    = "ht-ml-${var.azureml_random}"
  location                = var.rg_loc
  resource_group_name     = var.rg
  application_insights_id = var.app_insights_id
  key_vault_id            = var.vault_id
  storage_account_id      = var.storage_id

  identity {
    type = "SystemAssigned"
  }
}
