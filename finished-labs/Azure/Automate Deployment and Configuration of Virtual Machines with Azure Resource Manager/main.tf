provider "azurerm" {
  version = "~>2.0"
  features {}
}

variable "resource_group_name" {}
variable "location" {}

resource "random_id" "id" {
  keepers = {
    resource_group = var.resource_group_name
  }

  byte_length = 2
}

resource "azurerm_storage_account" "lab_storage_account" {
  name                     = "lab${random_id.id.hex}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "lab_file_share" {
  name                 = "lab${random_id.id.hex}"
  storage_account_name = azurerm_storage_account.lab_storage_account.name
  quota                = 50
}

resource "null_resource" "upload_key" {
  provisioner "local-exec" {
    command = <<-EOT
      az storage file upload \
        --account-key "${azurerm_storage_account.lab_storage_account.primary_access_key}" \
        --account-name "${azurerm_storage_account.lab_storage_account.name}" \
        -s "${azurerm_storage_share.lab_file_share.name}" \
        --source "${local_file.private_key.filename}" && \
      az storage file upload \
        --account-key "${azurerm_storage_account.lab_storage_account.primary_access_key}" \
        --account-name "${azurerm_storage_account.lab_storage_account.name}" \
        -s "${azurerm_storage_share.lab_file_share.name}" \
        --source "${local_file.public_key.filename}" && \
      az storage file upload \
        --account-key "${azurerm_storage_account.lab_storage_account.primary_access_key}" \
        --account-name "${azurerm_storage_account.lab_storage_account.name}" \
        -s "${azurerm_storage_share.lab_file_share.name}" \
        --source "keys" && \
      az storage file upload \
        --account-key "${azurerm_storage_account.lab_storage_account.primary_access_key}" \
        --account-name "${azurerm_storage_account.lab_storage_account.name}" \
        -s "${azurerm_storage_share.lab_file_share.name}" \
        --source "azuredeploy.json"
    EOT
  }
  depends_on = [local_file.private_key, local_file.public_key]
}

resource "tls_private_key" "lab_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  content         = tls_private_key.lab_private_key.private_key_pem
  filename        = "id_rsa"
  file_permission = "0400"
}

resource "local_file" "public_key" {
  content         = tls_private_key.lab_private_key.public_key_openssh
  filename        = "id_rsa.pub"
  file_permission = "0400"
}

resource "azurerm_virtual_network" "lab_vnet" {
  name                = "labVNet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "lab_subnet" {
  name                 = "labSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.lab_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "lab_public_ip" {
  name                = "labPublicIP"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_security_group" "lab_security_group" {
  name                = "labSecurityGroup"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "SSH"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "lab_nic" {
  name                = "labNIC"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "labNicConfiguration"
    subnet_id                     = azurerm_subnet.lab_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.lab_public_ip.id
  }
}

resource "azurerm_network_interface_security_group_association" "lab_sg_assoc" {
  network_interface_id      = azurerm_network_interface.lab_nic.id
  network_security_group_id = azurerm_network_security_group.lab_security_group.id
}
