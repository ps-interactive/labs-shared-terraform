resource "random_string" "random_storage" {
  length = 10
  special = false
  upper = false
  number = false
}

resource "azurerm_storage_account" "storage" {
  access_tier               = "Hot"
  account_kind              = "StorageV2"
  account_replication_type  = "LRS"
  account_tier              = "Standard"
  allow_blob_public_access  = "true"
  enable_https_traffic_only = "true"
  is_hns_enabled            = "false"
  location                  = var.rg_loc
  min_tls_version           = "TLS1_2"
  name                      = random_string.random_storage.result

  network_rules {
    bypass         = ["AzureServices"]
    default_action = "Allow"
  }

  queue_properties {
    hour_metrics {
      enabled               = "true"
      include_apis          = "true"
      retention_policy_days = "7"
      version               = "1.0"
    }

    logging {
      delete                = "false"
      read                  = "false"
      retention_policy_days = "7"
      version               = "1.0"
      write                 = "false"
    }

    minute_metrics {
      enabled               = "false"
      include_apis          = "false"
      retention_policy_days = "7"
      version               = "1.0"
    }
  }

  resource_group_name = var.rg
}
