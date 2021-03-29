# Create virtual network and subnets
resource "azurerm_virtual_network" "ps-virtual-network" {
  name                = "ps-virtual-network"
  address_space       = ["10.0.0.0/24"]
  location            = var.rg_loc
  resource_group_name = var.rg
  vm_protection_enabled = "false"
}

resource "azurerm_subnet" "ps-subnet" {
  name                 = "ps-subnet"
  resource_group_name  = var.rg
  virtual_network_name = azurerm_virtual_network.ps-virtual-network.name
  address_prefixes      = ["10.0.0.0/24"]
}

  
  # Add Network Security Group for HTTP
resource "azurerm_network_security_group" "ps-security-group" {
  name                = "ps-security-group"
  location            = var.rg_loc
  resource_group_name = var.rg
  security_rule {
    access                     = "Allow"
    destination_address_prefix = "*"
    destination_port_range     = "22"
    direction                  = "Inbound"
    name                       = "SSH"
    priority                   = "300"
    protocol                   = "TCP"
    source_address_prefix      = "*"
    source_port_range          = "*"
  }

  security_rule {
    access                     = "Allow"
    destination_address_prefix = "*"
    destination_port_range     = "27017"
    direction                  = "Inbound"
    name                       = "MongoDB"
    priority                   = "320"
    protocol                   = "*"
    source_address_prefix      = "*"
    source_port_range          = "*"
  }
}

resource "azurerm_network_interface" "ps-subnet-network-interface" {
  name                = "ps-subnet-network-interface"
  resource_group_name = var.rg
  location            = var.rg_loc
  enable_accelerated_networking = "false"
  enable_ip_forwarding          = "false"

  ip_configuration {
    name                          = azurerm_public_ip.ps-public-ip.name
    primary                       = "true"
    private_ip_address            = "10.0.0.4"
    private_ip_address_allocation = "Dynamic"
    private_ip_address_version    = "IPv4"
    public_ip_address_id          = azurerm_public_ip.ps-public-ip.id
    subnet_id                     = azurerm_subnet.ps-subnet.id
  }
}

resource "azurerm_network_interface_security_group_association" "ps-subnet-network-interface-nsg-assoc" {
  network_interface_id      = azurerm_network_interface.ps-subnet-network-interface.id
  network_security_group_id = azurerm_network_security_group.ps-security-group.id
}


resource "azurerm_public_ip" "ps-public-ip" {
  name                = "ps-public-ip"
  resource_group_name = var.rg
  location            = var.rg_loc
  allocation_method       = "Static"
  idle_timeout_in_minutes = "4"
  ip_version              = "IPv4"
  sku = "Standard"
  zones = [1]
}


resource "azurerm_network_watcher" "example" {
  name                = "network-nwwatcher"
  location            = var.rg_loc
  resource_group_name = var.rg
}
