provider "azurerm" {
  features {}
}

variable "resource_group_name" {}
variable "location" {}

resource "azurerm_virtual_network" "_" {
  name                = "globomantics"
  address_space       = ["10.0.0.0/16"]
  resource_group_name = var.resource_group_name
  location            = var.location
}

resource "azurerm_public_ip" "_" {
  name                = "public"
  allocation_method   = "Static"
  sku                 = "Standard"
  resource_group_name = var.resource_group_name
  location            = var.location
}

resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  address_prefixes     = ["10.0.1.0/24"]
  virtual_network_name = azurerm_virtual_network._.name
  resource_group_name  = var.resource_group_name
}


resource "azurerm_bastion_host" "_" {
  name                = "bastion"
  resource_group_name = var.resource_group_name
  location            = var.location

  ip_configuration {
    name                 = "public"
    subnet_id            = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip._.id
  }
}

resource "azurerm_subnet" "_" {
  name                 = "internal"
  address_prefixes     = ["10.0.0.0/24"]
  virtual_network_name = azurerm_virtual_network._.name
  resource_group_name  = var.resource_group_name
}

resource "azurerm_network_interface" "_" {
  count = 2

  name                = "nic${count.index}"
  resource_group_name = var.resource_group_name
  location            = var.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet._.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "_" {
  count = 2

  name                            = "vm${count.index}"
  size                            = "Standard_A1_v2"
  network_interface_ids           = [azurerm_network_interface._[count.index].id]
  admin_username                  = #insert username
  admin_password                  = #insert password
  disable_password_authentication = false
  resource_group_name             = var.resource_group_name
  location                        = var.location

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

resource "random_string" "storage_account_name" {
  length  = 12
  special = false
  upper   = false
}

resource "azurerm_storage_account" "_" {
  name                     = "globomantics${random_string.storage_account_name.result}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  resource_group_name      = var.resource_group_name
  location                 = var.location

  static_website {
    index_document = "index.html"
  }
}

resource "azurerm_storage_blob" "_" {
  name                   = "index.html"
  storage_account_name   = azurerm_storage_account._.name
  storage_container_name = "$web"
  type                   = "Block"
  content_type           = "text/html"
  source_content         = <<EOF
<!DOCTYPE html>
<html>
  <head>
    <title>Globomantics</title>
    <meta charset="utf-8"/>
  </head>
  <body>
    <h1>Globomantics</h1>
  </body>
</html>
EOF
}

resource "random_string" "cdn_profile_name" {
  length  = 12
  special = false
  upper   = false
}

resource "azurerm_cdn_profile" "_" {
  name = "globomantics${random_string.cdn_profile_name.result}"
  sku  = "Standard_Microsoft"

  resource_group_name = var.resource_group_name
  location            = var.location
}

resource "azurerm_cdn_endpoint" "_" {
  name         = "globomantics"
  profile_name = azurerm_cdn_profile._.name

  resource_group_name = var.resource_group_name
  location            = var.location
  origin_host_header  = azurerm_storage_account._.primary_web_host

  origin {
    name      = "globomantics"
    host_name = azurerm_storage_account._.primary_web_host
  }
}
