provider "azurerm" {
  features {}
}

variable "resource_group_name" {}
variable "location" {}

locals {
  mimetypes = {
    css   = "text/css"
    eot   = "application/vnd.ms-fontobject"
    html  = "text/html"
    jpg   = "image/jpeg"
    js    = "text/javascript"
    map   = "application/json"
    otf   = "font/otf"
    png   = "image/png"
    svg   = "image/svg+xml"
    ttf   = "font/ttf"
    woff  = "font/woff"
    woff2 = "font/woff2"
  }
}

resource "random_string" "cloudshell" {
  length  = 22
  upper   = false
  lower   = false
  special = false
}

resource "azurerm_storage_account" "cloudshell" {
  name                     = "cs${random_string.cloudshell.result}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "random_string" "_" {
  length  = 18
  upper   = false
  lower   = false
  special = false
}

resource "azurerm_storage_account" "_" {
  name                     = "static${random_string._.result}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "_" {
  name                 = "static"
  storage_account_name = azurerm_storage_account._.name
}

resource "azurerm_storage_blob" "_" {
  for_each = fileset("${path.module}/static", "**")

  name                   = each.value
  storage_account_name   = azurerm_storage_account._.name
  storage_container_name = azurerm_storage_container._.name
  type                   = "Block"
  content_type           = lookup(local.mimetypes, reverse(split(".", each.value))[0])
  source                 = "static/${each.value}"
}
