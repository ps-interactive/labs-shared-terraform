output "azurerm_linux_virtual_machine_mongo_name" {
  value = azurerm_linux_virtual_machine.main.name
}

output "azurerm_linux_virtual_machine_mongo_id" {
  value = azurerm_linux_virtual_machine.main.id
}

output "azurerm_linux_virtual_machine_mongo_ip" {
  value = azurerm_linux_virtual_machine.main.public_ip_address
}
