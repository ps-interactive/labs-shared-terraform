resource "azurerm_cosmosdb_sql_container" "movies" {
  account_name = azurerm_cosmosdb_account.cosmosdb.name
  database_name = azurerm_cosmosdb_sql_database.sink.name
  name = "movies"
  resource_group_name = var.rg
  partition_key_path="/Rating"
  partition_key_version = 1
  throughput            = 400
}
