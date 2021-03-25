output "azurerm_cosmosdb_account_cosmosdb_id" {
  value = azurerm_cosmosdb_account.cosmosdb.id
}

output "azurerm_cosmosdb_sql_container_movies_id" {
  value = azurerm_cosmosdb_sql_container.movies.id
}

output "azurerm_cosmosdb_sql_database_sink_id" {
  value = azurerm_cosmosdb_sql_database.sink.id
}
