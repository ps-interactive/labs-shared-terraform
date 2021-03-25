resource "azurerm_storage_blob" "source" {
  name                   = "source.csv"
  storage_account_name   = var.sa
  storage_container_name = var.sc
  type                   = "Block"
  source                 = "source.csv"
}
