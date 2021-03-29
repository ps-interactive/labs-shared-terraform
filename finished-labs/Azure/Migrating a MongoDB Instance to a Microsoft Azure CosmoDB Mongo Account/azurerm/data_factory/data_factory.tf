resource "random_string" "random_adf" {
  length = 10
  special = false
  upper = false
  number = false
}

resource "azurerm_data_factory" "example" {
  name                = "adf${random_string.random_adf.result}"
  location            = var.rg_loc
  resource_group_name = var.rg
}
