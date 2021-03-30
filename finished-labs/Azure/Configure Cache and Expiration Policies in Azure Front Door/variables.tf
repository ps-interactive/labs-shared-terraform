provider "azurerm" {
  skip_provider_registration = true
  features {}
}

provider "random" {}

variable "resource_group_name" {
#  default = "pluralsight-5314bf6f-1603643685430"
}
variable "location" {
#  default = "eastus"
}