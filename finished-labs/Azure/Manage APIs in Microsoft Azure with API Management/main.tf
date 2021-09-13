provider "azurerm" {
  version = "~>2.0"
  features {}
}

variable "location" {
  default = "eastus"
}
resource "azurerm_resource_group" "rg" {
  name     = "pluralsight-resource-group"
  location = var.location
}

resource "random_id" "id" {
  keepers = {
    resource_group = azurerm_resource_group.rg.name
  }

  byte_length = 2
}

resource "azurerm_storage_account" "lab_storage_account" {
  name                     = "lab${random_id.id.hex}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "lab_file_share" {
  name                 = "lab${random_id.id.hex}"
  storage_account_name = azurerm_storage_account.lab_storage_account.name
  quota                = 50
}


resource "azurerm_app_service_plan" "traffic_api_plan" {
  name                = "traffic-api-plan-${random_id.id.hex}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Free"
    size = "F1"
  }
}

resource "azurerm_app_service" "traffic_api_service" {
  name                = "traffic-api-service-${random_id.id.hex}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.traffic_api_plan.id

  site_config {
    linux_fx_version          = "DOTNETCORE|3.1"
    always_on                 = false
    use_32_bit_worker_process = true
  }
}
