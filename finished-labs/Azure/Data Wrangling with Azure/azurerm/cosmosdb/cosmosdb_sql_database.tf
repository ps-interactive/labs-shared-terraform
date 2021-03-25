resource "azurerm_cosmosdb_sql_database" "sink" {
  account_name = azurerm_cosmosdb_account.cosmosdb.name
  name = "sink"
  resource_group_name = var.rg
}
