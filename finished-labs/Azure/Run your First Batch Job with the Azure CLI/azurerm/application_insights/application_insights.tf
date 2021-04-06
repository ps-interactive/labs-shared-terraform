resource "azurerm_application_insights" "pluralsight-app-insights" {
  name                = "ht-ai-${var.azureml_random}"
  location            = var.rg_loc
  resource_group_name = var.rg
  application_type    = "web"
}
