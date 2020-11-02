provider "azurerm" {
  features {}
}
variable "resource_group_name" {
  # this variable is automatically assigned by the cloud sandbox
}
variable "location" {
  # this variable is automatically assigned by the cloud sandbox
}

data "azurerm_client_config" "current" {}

# this resource returns a random 14 character string that contains 7 lowercase and 7 uppercase letters
resource "random_string" "sa_random_id" {
  length      = 14
  upper       = false
  lower       = true
  min_lower   = 7
  min_numeric = 7
  special     = false
}

# this resource creates a storage account using the random string from above
resource "azurerm_storage_account" "sa_cloudshell" {

  # this line uses that random string and appends pssacs to the front.
  name                     = "pssacs${lower(random_string.sa_random_id.result)}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "standard"
  account_replication_type = "LRS"
  account_kind             = "Storagev2"
  allow_blob_public_access = "true"  
}

# this resource returns a random 14 character string that contains 7 lowercase and 7 uppercase letters
resource "random_string" "kv_random_id" {
  length      = 14
  upper       = false
  lower       = true
  min_lower   = 7
  min_numeric = 7
  special     = false
}

# this resource creates a storage account using the random string from above
resource "azurerm_key_vault" "kv_cloudshell" {

  # this line uses that random string and appends pssacs to the front.
  name                     = "pssacs${lower(random_string.kv_random_id.result)}"
  resource_group_name      = var.resource_group_name
  location                 = var.location 
  sku_name                 = "standard"
  tenant_id                = data.azurerm_client_config.current.tenant_id
}
