provider "azurerm" {
  version = "~>2.0"
  features {}
}

variable "resource_group_name" {}
variable "location" {}

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
    resource_group = var.resource_group_name
  }

  byte_length = 2
}

resource "azurerm_storage_account" "lab_storage_account" {
  name                     = "lab${random_id.id.hex}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "lab_file_share" {
  name                 = "lab${random_id.id.hex}"
  storage_account_name = azurerm_storage_account.lab_storage_account.name
  quota                = 50
}

# resource "random_string" "nts_api_name" {
#   length      = 20
#   upper       = false
#   lower       = true
#   min_lower   = 7
#   min_numeric = 7
#   special     = false
# }

# resource "random_string" "deploy_user" {
#   length      = 5
#   upper       = false
#   lower       = true
#   min_lower   = 5
#   special     = false
# }

# resource "random_string" "deploy_password" {
#   length      = 10
#   upper       = false
#   lower       = true
#   min_lower   = 5
#   min_numeric = 5
#   special     = false
# }

# locals {
#   deploy_url = "https://${random_string.deploy_user.result}@${random_string.nts_api_name.result}.scm.azurewebsites.net/${random_string.nts_api_name.result}.git"
#   deploy_password_url = "https://${random_string.deploy_user.result}:${random_string.deploy_password.result}@${random_string.nts_api_name.result}.scm.azurewebsites.net/${random_string.nts_api_name.result}.git"
# }

resource "null_resource" "six" {
  provisioner "local-exec" {
    command = "git clone https://github.com/ps-interactive/lab_azure_manage-apis-microsoft-azure-with-api-management.git"
  }
}

resource "null_resource" "sp" {  
  provisioner "local-exec" {  
   command = "bash lab_azure_manage-apis-microsoft-azure-with-api-management/installation.sh"    
  }
  depends_on = [
    null_resource.six
  ]
}
