resource "azurerm_key_vault" "pluralsight-vault" {
  name                = "ht-kv-${var.azureml_random}"
  location            = var.rg_loc
  resource_group_name = var.rg
  tenant_id           = var.tenant
  sku_name            = "premium"
}
