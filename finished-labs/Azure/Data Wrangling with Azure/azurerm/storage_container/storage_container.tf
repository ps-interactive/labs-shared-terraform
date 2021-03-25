resource "azurerm_storage_container" "failed" {
  container_access_type = "private"
  name                  = "failed"
  storage_account_name  = var.sa
}

resource "azurerm_storage_container" "source" {
  container_access_type = "private"
  name                  = "source"
  storage_account_name  = var.sa
}
