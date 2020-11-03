
provider "azurerm" {
  version = "~> 2.30"
  features {}
}

variable "resource_group_name" {
  default = "pluralsight"
}

variable "location" {
  default = "eastus"
}

resource "azurerm_virtual_network" "westus" {
    name                = "westus-vnet"
    address_space       = ["10.0.0.0/16"]
    location            = "westus"
    resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "westus_dmz" {
  name                 = "dmz"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.westus.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_network_interface" "westus_nva" {
  name                 = "westus-nva-nic"
  location             = "westus"
  resource_group_name  = var.resource_group_name
  enable_ip_forwarding = true
#   internal_dns_name_label 

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.westus_dmz.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.0.4"
    primary                       = true
  }
}

resource "azurerm_windows_virtual_machine" "westus_nva" {
  name                = "westus-nva"
  resource_group_name = var.resource_group_name
  location            = "westus"
  size                = "Standard_DS1_v2"
  admin_username      = "****" # replace with an actual vm username
  admin_password      = "****" # replace with an actual vm password
  network_interface_ids = [
    azurerm_network_interface.westus_nva.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}

resource "azurerm_virtual_machine_extension" "westus_nva" {
  name                 = "port_forwarding"
  virtual_machine_id   = azurerm_windows_virtual_machine.westus_nva.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"
  
        settings = <<SETTINGS
        {
            "commandToExecute":"powershell Set-ItemProperty -Path HKLM:\\SYSTEM\\CurrentControlSet\\Services\\Tcpip\\Parameters -Name IpEnableRouter -Value 1; powershell Restart-Computer"
        }
    SETTINGS
}

resource "azurerm_subnet" "westus_data" {
  name                 = "data"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.westus.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "westus_data" {
  name                = "westus-data-nic"
  location            = "westus"
  resource_group_name = var.resource_group_name
#   internal_dns_name_label

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.westus_data.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.4"
    primary                       = true
  }
}

resource "azurerm_windows_virtual_machine" "westus_data" {
  name                = "westus-data"
  resource_group_name = var.resource_group_name
  location            = "westus"
  size                = "Standard_DS1_v2"
  admin_username      = "****" # replace with an actual vm username
  admin_password      = "****" # replace with an actual vm password
  network_interface_ids = [
    azurerm_network_interface.westus_data.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}

resource "azurerm_virtual_machine_extension" "westus_data" {
  name                 = "icmp"
  virtual_machine_id   = azurerm_windows_virtual_machine.westus_data.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"
  
        settings = <<SETTINGS
        {
            "commandToExecute":"powershell New-NetFirewallRule –DisplayName \"Allow ICMPv4-In\" –Protocol ICMPv4; powershell Restart-Computer"
        }
    SETTINGS
}

resource "azurerm_subnet" "westus_web" {
  name                 = "web"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.westus.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "westus_web" {
  name                = "westus-web-nic"
  location            = "westus"
  resource_group_name = var.resource_group_name
#   internal_dns_name_label

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.westus_web.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.2.4"
    primary                       = true
  }
}

resource "azurerm_windows_virtual_machine" "westus_web" {
  name                = "westus-web"
  resource_group_name = var.resource_group_name
  location            = "westus"
  size                = "Standard_DS1_v2"
  admin_username      = "****" # replace with an actual vm username
  admin_password      = "****" # replace with an actual vm password
  network_interface_ids = [
    azurerm_network_interface.westus_web.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}
