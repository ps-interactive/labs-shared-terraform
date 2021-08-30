provider "azurerm" {
  version = "~>2.0"
  features {}
}

variable "location" {
  default = "eastus"
}
resource "azurerm_resource_group" "rg" {
  name = "pluralsight-resource-group"
  location = var.location
}

variable "remote_name" {
  default = "production"
}

# variable "git_user" {
#   default = "randomgitName"
# }

# variable "git_email" {
#   default = "random@test.com"
# }

resource "random_id" "id" {
  keepers = {
    resource_group = azurerm_resource_group.rg.name
  }

  byte_length = 2
}

resource "azurerm_storage_account" "lab_storage_account" {
  name                     = "lab${random_id.id.hex}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "lab_file_share" {
  name                 = "lab${random_id.id.hex}"
  storage_account_name = azurerm_storage_account.lab_storage_account.name
  quota                = 50
}
