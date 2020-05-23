provider "azurerm" {

}

terraform {
  backend "azurerm" {}
}

resource "azurerm_resource_group" "default" {
  name     = "${var.name}-${var.environment}-rg"
  location = "westus"
}

locals {
  storage_account_name = "${var.prefix}${var.name}${substr(var.environment, 0, 2)}"
}

resource "azurerm_storage_account" "default" {
  name                      = local.storage_account_name
  resource_group_name       = azurerm_resource_group.default.name
  location                  = "westus2"
  account_kind              = "StorageV2"
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  enable_https_traffic_only = true
  static_website {
    index_document = "index.html"
  }
}

output "storage_account" {
  value = azurerm_storage_account.default.name
}
