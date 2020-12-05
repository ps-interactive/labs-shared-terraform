provider "azurerm" {
  version = "~> 2.30"
  features {}
}

variable "resource_group_name" {
  default = "pluralsight"
}

variable "location" {
  default = "eastus"
}

resource "random_string" "application_name" {
  length = 24
  upper = false
  lower = true
  number = false
  special = false
}

resource "azurerm_storage_account" "application" {
  name                = random_string.application_name.result
  location            = var.location
  resource_group_name = var.resource_group_name

  account_tier              = "Standard"
  account_kind              = "StorageV2"
  access_tier               = "Hot"
  account_replication_type  = "LRS"
  allow_blob_public_access  = true
}

resource "azurerm_search_service" "application" {
  name                = random_string.application_name.result
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "standard"
}

resource "azurerm_sql_server" "application" {
  name                         = random_string.application_name.result
  location                     = var.location
  resource_group_name          = var.resource_group_name
  version                      = "12.0"
  administrator_login          = "carvedrock"
  administrator_login_password = "********"
}

resource "azurerm_sql_database" "application" {
  name                = random_string.application_name.result
  location            = var.location
  resource_group_name = var.resource_group_name
  server_name         = azurerm_sql_server.application.name
  edition             = "Basic"
}

resource "azurerm_cosmosdb_account" "db" {
  name                = random_string.application_name.result
  location            = var.location
  resource_group_name = var.resource_group_name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"  

  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 10
    max_staleness_prefix    = 200
  }

  geo_location {
    location          = var.location
    failover_priority = 0
  }
}
