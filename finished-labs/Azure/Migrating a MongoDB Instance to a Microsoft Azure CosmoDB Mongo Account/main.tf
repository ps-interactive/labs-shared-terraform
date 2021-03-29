provider "azurerm" {
  features {}
}

variable "password" {
  default = "Password1234!"
}
variable "username" {
  default = "pluralsightadmin"
}

module "resource_group" {
  source = "./azurerm/resource_group"
}

module "networking" {
  source = "./azurerm/networking"
  rg = module.resource_group.azurerm_resource_group_rg_name
  rg_loc = module.resource_group.azurerm_resource_group_rg_location
}

module "mongodb" {
  source = "./azurerm/mongodb"
  rg = module.resource_group.azurerm_resource_group_rg_name
  rg_loc = module.resource_group.azurerm_resource_group_rg_location
  password = var.password
  prefix = "pluralsightmongodb"
  username = var.username
  network_interface_id = module.networking.azurerm_network_interface_ps-subnet-network-interface_id
}

module "install_mongo" {
  source = "./azurerm/remote_executor"
  password = var.password
  public_ip = module.mongodb.azurerm_linux_virtual_machine_mongo_ip
  username = var.username
}


module "cosmosdb" {
  source = "./azurerm/cosmosdb"
  rg = module.resource_group.azurerm_resource_group_rg_name
  rg_loc = module.resource_group.azurerm_resource_group_rg_location
}


module "data_factory" {
  source = "./azurerm/data_factory"
  rg = module.resource_group.azurerm_resource_group_rg_name
  rg_loc = module.resource_group.azurerm_resource_group_rg_location
}
