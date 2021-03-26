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
//
//
//module "storage_account" {
//  source = "./azurerm/storage_account"
//  rg = module.resource_group.azurerm_resource_group_cloudshell_name
//}
//
//module "storage_share" {
//  source = "./azurerm/storage_share"
//  sa = module.storage_account.azurerm_storage_account_cloudshell_name
//}
