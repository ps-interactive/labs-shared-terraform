resource "random_string" "random_rg" {
  length = 10
  special = false
  upper = false
  number = false
}

resource "azurerm_resource_group" "rg" {
  location = "eastus"
  name     = "lab${random_string.random_rg.result}"
}
