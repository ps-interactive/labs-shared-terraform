provider "azurerm" {
  features {}
}
variable "resource_group_name" {
}
variable "location" {
  default = "eastus"
}
resource "random_string" "storage_account_name" {
  length  = 10
  special = false
  upper   = false
}

resource "azurerm_resource_group" "globomantics" {
  name                     = format("globomantics%s",random_string.storage_account_name.result)
  location                 = var.location
}