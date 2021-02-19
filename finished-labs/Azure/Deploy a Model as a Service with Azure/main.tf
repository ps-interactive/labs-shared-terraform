# Purpose: Create resources for Azure ML Lab

# References:
# https://github.com/csiebler/azure-machine-learning-terraform

provider "azurerm" {
  features {
  }
  skip_provider_registration = true
}

terraform {
  required_providers {
    azurerm = {
      version = "~> 2.45"
    }
    null = {
      version = "~> 3.0"
    }
    random = {
      version = "~> 3.0"
    }
  }
}

variable "prefix" {
  type = string
  default = "pslab"
}

data "azurerm_client_config" "current" {}


resource "azurerm_resource_group" "lab" {
  name     = "${var.prefix}-rg"
  location = "East US 2"
}


# Create AML dependencies

resource "azurerm_application_insights" "lab" {
  name                = "${var.prefix}-ml-studio-ai"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  application_type    = "web"
}

resource "azurerm_key_vault" "lab" {
  name                = "${var.prefix}${random_string.uniquenumbers.result}-kv"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "premium"
}


# storage requires random name suffix
resource "random_string" "uniquenumbers" {
  length  =12
  upper   = false
  lower   = false
  special = false
}

resource "random_string" "uniqueletters" {
  length    = 8
  upper     = false
  lower     = true
  min_lower = 8
  special   = false
  number    = false
}

resource "azurerm_storage_account" "lab" {
  name                     = "${var.prefix}stor${random_string.uniquenumbers.result}"
  location                 = azurerm_resource_group.lab.location
  resource_group_name      = azurerm_resource_group.lab.name
  account_tier             = "Standard"
  account_replication_type = "ZRS"
}

# Create AML Workspace 

resource "azurerm_machine_learning_workspace" "lab" {
  name                    = "${var.prefix}-ml-studio"
  location                = azurerm_resource_group.lab.location
  resource_group_name     = azurerm_resource_group.lab.name
  application_insights_id = azurerm_application_insights.lab.id
  key_vault_id            = azurerm_key_vault.lab.id
  storage_account_id      = azurerm_storage_account.lab.id

  identity {
    type = "SystemAssigned"
  }
}

# Create Compute Resources in AML
# Create EITHER a amltarget, which is a VM cluster, or a computeinstance, a single VM
# Probably don't need both
# ALTERNATELY, use ACI
# 

resource "null_resource" "compute_resources" {
  provisioner "local-exec" {
    command="az extension add --upgrade --name azure-cli-ml"
  }

# create amltarget / VM cluster
  provisioner "local-exec" {
    command="az ml computetarget create amlcompute --max-nodes 2 --min-nodes 1 --name cpu-cluster --vm-size Standard_DS12_v2 --idle-seconds-before-scaledown 600 --assign-identity [system] --resource-group ${azurerm_machine_learning_workspace.lab.resource_group_name} --workspace-name ${azurerm_machine_learning_workspace.lab.name} --debug --verbose" #--vnet-name ${azurerm_subnet.aml_subnet.virtual_network_name} --subnet-name ${azurerm_subnet.aml_subnet.name} --vnet-resourcegroup-name ${azurerm_subnet.aml_subnet.resource_group_name} 
  }

# create computeinstance / single VM
  provisioner "local-exec" {
    command="az ml computetarget create computeinstance --name ${var.prefix}-instance-${substr(random_string.uniqueletters.result,1,4)} --vm-size Standard_DS12_v2 --resource-group ${azurerm_machine_learning_workspace.lab.resource_group_name} --workspace-name ${azurerm_machine_learning_workspace.lab.name}" # --vnet-name ${azurerm_subnet.aml_subnet.virtual_network_name} --subnet-name ${azurerm_subnet.aml_subnet.name} --vnet-resourcegroup-name ${azurerm_subnet.aml_subnet.resource_group_name} 
  }
 
  depends_on = [azurerm_machine_learning_workspace.lab]
}

output "mls_id" {
   value = azurerm_machine_learning_workspace.lab.id
}