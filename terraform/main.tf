provider "azurerm" {
  features {}
}

terraform {
  backend "azurerm" {}
}

resource "azurerm_resource_group" "default" {
  name     = "${var.name}-${var.environment}-rg"
  location = var.location
}

locals {
  storage_account_name = "${var.prefix}${var.name}${substr(var.environment, 0, 2)}"
}

resource "azurerm_storage_account" "default" {
  name                      = local.storage_account_name
  resource_group_name       = azurerm_resource_group.default.name
  location                  = azurerm_resource_group.default.location
  account_kind              = "StorageV2"
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  enable_https_traffic_only = true
  static_website {
    index_document = "index.html"
    error_404_document = "404.html"
  }
}

resource "azurerm_cdn_profile" "default" {
  name                = "${var.name}-cdn"
  location            = var.cdn_location
  resource_group_name = azurerm_resource_group.default.name
  sku                 = "Standard_Microsoft"
}

resource "azurerm_cdn_endpoint" "default" {
  name                = "${var.prefix}-${var.name}-${var.environment}"
  profile_name        = azurerm_cdn_profile.default.name
  location            = var.cdn_location
  resource_group_name = azurerm_resource_group.default.name
  origin_host_header  = azurerm_storage_account.default.primary_web_host
  origin {
    name      = "${var.prefix}-${var.name}-${var.environment}"
    host_name = azurerm_storage_account.default.primary_web_host
  }
}

output "storage_account" {
  value = azurerm_storage_account.default.name
}
