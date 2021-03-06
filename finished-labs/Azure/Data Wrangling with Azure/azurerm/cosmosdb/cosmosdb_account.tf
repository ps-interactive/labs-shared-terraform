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
    max_interval_in_seconds = "5"
    max_staleness_prefix    = "100"
  }

  enable_automatic_failover       = "false"
  enable_free_tier                = "false"
  enable_multiple_write_locations = "false"

  geo_location {
    failover_priority = "0"
    location          = "eastus"
    zone_redundant    = "false"
  }

  is_virtual_network_filter_enabled = "false"
  kind                              = "GlobalDocumentDB"
  location                          = "eastus"
  name                              = "cosmosdb${random_string.random_cosmosdb.result}"
  offer_type                        = "Standard"
  public_network_access_enabled     = "true"
  resource_group_name               = var.rg
//  resource_group_name               = data.terraform_remote_state.resource_group.outputs.azurerm_resource_group_rg_name

  tags = {
    CosmosAccountType = "Non-Production"
    defaultExperience = "Core (SQL)"
  }
}
