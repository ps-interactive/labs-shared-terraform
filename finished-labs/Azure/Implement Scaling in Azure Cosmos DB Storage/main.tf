provider "azurerm" {
  features {}
}


variable "resource_group_name" {
}
variable "location" {
  default = "eastus"
}

variable "cosmos_db_account_name" {
  default = "cosmosterraformdemoversion"
}

resource "azurerm_cosmosdb_account" "acc" {
  name = "${var.cosmos_db_account_name}"
  location = var.location
  resource_group_name = var.resource_group_name
  offer_type = "Standard"
  kind = "GlobalDocumentDB"
  enable_automatic_failover = true
  consistency_policy {
    consistency_level = "Session"
  }
  
  geo_location {
    location = var.location
    failover_priority = 0
  }
}


