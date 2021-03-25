provider "azurerm" {
  features {}
}

module "resource_group" {
  source = "./azurerm/resource_group"
}

module "cosmosdb" {
  source = "./azurerm/cosmosdb"
  rg = module.resource_group.azurerm_resource_group_rg_name
}


module "storage_account" {
  source = "./azurerm/storage_account"
  rg = module.resource_group.azurerm_resource_group_rg_name
}

module "storage_container" {
  source = "./azurerm/storage_container"
  sa = module.storage_account.azurerm_storage_account_storage_name
}

module "storage_blob" {
  source = "./azurerm/storage_blob"
  sc = module.storage_container.azurerm_storage_container_source_name
  sa = module.storage_account.azurerm_storage_account_storage_name
}

module "data_factory" {
  source = "./azurerm/data_factory"
  rg = module.resource_group.azurerm_resource_group_rg_name
  rg_loc = module.resource_group.azurerm_resource_group_rg_location
}
