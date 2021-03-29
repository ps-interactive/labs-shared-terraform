resource "random_string" "random_cosmosdb" {
  length = 10
  special = false
  upper = false
  number = false
}

resource "azurerm_cosmosdb_account" "cosmosdb" {
  analytical_storage_enabled = "false"

  consistency_policy {
    consistency_level       = "Session"
    max_interval_in_seconds = "86400"
    max_staleness_prefix    = "1000000"
  }

  enable_automatic_failover       = "false"
  enable_free_tier                = "false"
  enable_multiple_write_locations = "false"
  capabilities {
    name = "EnableAggregationPipeline"
  }

  capabilities {
    name = "mongoEnableDocLevelTTL"
  }

  capabilities {
    name = "EnableMongo"
  }
  geo_location {
    failover_priority = "0"
    location          = var.rg_loc
    zone_redundant    = "false"
  }

  is_virtual_network_filter_enabled = "false"
  kind                              = "MongoDB"
  location                          = var.rg_loc
  name                              = "cosmosdb${random_string.random_cosmosdb.result}"
  offer_type                        = "Standard"
  public_network_access_enabled     = "true"
  resource_group_name               = var.rg
}

resource "azurerm_cosmosdb_mongo_database" "pluralsight" {
  name                = "pluralsight"
  resource_group_name = var.rg
  account_name        = azurerm_cosmosdb_account.cosmosdb.name
}

resource "azurerm_cosmosdb_mongo_collection" "movies" {
  name                = "movies"
  resource_group_name = var.rg
  account_name        = azurerm_cosmosdb_account.cosmosdb.name
  database_name       = azurerm_cosmosdb_mongo_database.pluralsight.name

  default_ttl_seconds = "777"
  shard_key           = "Title"
  throughput          = 400
}