 provider "azurerm" {
    features {}
  }

  variable "resource_group_name" {
    default = "rg-ps-prod"
  }

  variable "location" {
    default = "eastus"
  }
  
# Create virtual network and subnets
  resource "azurerm_virtual_network" "ps-prod-vnet" {
   name                = "ps-prod-vnet"
   address_space       = ["10.2.0.0/16"]
   location            = var.location
   resource_group_name = var.resource_group_name
  }
  
  resource "azurerm_subnet" "ps-prod-snet-app1" {
   name                 = "ps-prod-snet-app1"
   resource_group_name  = var.resource_group_name
   virtual_network_name = azurerm_virtual_network.ps-prod-vnet.name
   address_prefixes      = ["10.2.1.0/24"]
  }

  resource "azurerm_subnet" "ps-prod-snet-app2" {
   name                 = "ps-prod-snet-app2"
   resource_group_name  = var.resource_group_name
   virtual_network_name = azurerm_virtual_network.ps-prod-vnet.name
   address_prefixes      = ["10.2.2.0/24"]
  }
  
  # Add Network Security Group for HTTP
  resource "azurerm_network_security_group" "prod_app_nsg" {
    name                = "prod_app_nsg"
    location            = var.location
    resource_group_name = var.resource_group_name
    
}

resource "azurerm_network_security_rule" "prod_app_nsg-rule" {
  name                        = "prod_app_nsg-rule"
  network_security_group_name = azurerm_network_security_group.prod_app_nsg.name
  resource_group_name         = var.resource_group_name
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

resource "azurerm_network_interface" "ps-prod-snet-app1-nic02" {
  name                = "ps-prod-snet-app1-nic02"
  resource_group_name = var.resource_group_name
  location            = var.location
  
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.ps-prod-snet-app1.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_security_group_association" "ps-prod-snet-app1-nic02-nsg-assoc" {
  network_interface_id      = azurerm_network_interface.ps-prod-snet-app1-nic02.id
  network_security_group_id = azurerm_network_security_group.prod_app_nsg.id
}

resource "azurerm_public_ip" "ps-prod-app1-pip" {
  name                = "ps-prod-app1-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku = "Standard"
  zones = [1]
}

resource "azurerm_lb" "ps-prod-app1-lb" {
  name                = "ps-prod-app1-lb"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku = "Standard"
  
  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.ps-prod-app1-pip.id
  }
}

resource "azurerm_lb_backend_address_pool" "ps-prod-app1-lb-bckpool" {
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.ps-prod-app1-lb.id
  name                = "ps-prod-app1-lb-bckpool"
}



resource "azurerm_lb_rule" "ps-prod-app1-lb-lb_rule" {
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.ps-prod-app1-lb.id
  name                           = "LBRule"
  protocol                       = "tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
  enable_floating_ip             = false
  backend_address_pool_id        = azurerm_lb_backend_address_pool.ps-prod-app1-lb-bckpool.id
  idle_timeout_in_minutes        = 5
  probe_id                       = azurerm_lb_probe.ps-prod-app1-lb-probe.id
  depends_on                     = [azurerm_lb_probe.ps-prod-app1-lb-probe]
}

resource "azurerm_lb_probe" "ps-prod-app1-lb-probe" {
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.ps-prod-app1-lb.id
  name                = "tcpProbe"
  protocol            = "tcp"
  port                = 80
  interval_in_seconds = 5
  number_of_probes    = 2
}

resource "azurerm_network_interface_backend_address_pool_association" "ps-prod-app1-lb-bckpool-nic-assoc" {
  backend_address_pool_id = azurerm_lb_backend_address_pool.ps-prod-app1-lb-bckpool.id
  ip_configuration_name   = "internal"
  network_interface_id    = azurerm_network_interface.ps-prod-snet-app1-nic02.id
}

# Data template Bash bootstrapping file
data "template_file" "linux-vm-cloud-init" {
  template = file("app1-cloud-init.sh")
}

resource "azurerm_linux_virtual_machine" "ps-prod-app1-vm02" {
  name                            = "ps-prod-app1-vm02"
  resource_group_name             = var.resource_group_name
  location                        = var.location
  size                            = "Standard_DS1_v2"
  admin_username                  = "ps-admin"
  admin_password                  = "P@ssw0rd1234!"
  custom_data = base64encode(data.template_file.linux-vm-cloud-init.rendered)
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.ps-prod-snet-app1-nic02.id,
  ]
  zone = 1
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
}



