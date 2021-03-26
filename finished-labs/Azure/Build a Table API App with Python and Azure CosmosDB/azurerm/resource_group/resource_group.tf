resource "azurerm_resource_group" "cloudshell" {
  location = "eastus"
  name     = "pluralsight-cloud-shell-storage-eastus"
}

resource "azurerm_resource_group" "rg" {
  location = "eastus"
  name     = "pluralsight-resource-group"
}
