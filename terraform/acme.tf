provider "acme" {
  server_url = "https://acme-staging-v02.api.letsencrypt.org/directory"
}

data "azurerm_client_config" "current" {
}

resource "tls_private_key" "default" {
  algorithm = "RSA"
}

resource "acme_registration" "default" {
  account_key_pem = tls_private_key.default.private_key_pem
  email_address   = "admin@${var.domain}"
}

resource "acme_certificate" "default" {
  account_key_pem           = acme_registration.default.account_key_pem
  common_name               = var.environment == "production" ? var.domain : "${var.environment}.${var.domain}"
  subject_alternative_names = var.environment == "production" ? ["www.${var.domain}"] : []

  dns_challenge {
    provider = "azure"
    config = {
      AZURE_RESOURCE_GROUP = var.dns_resource_group
    }
  }
}

locals {
  key_vault_name = "${var.prefix}-${var.name}-${var.environment}-kv"
}

resource "azurerm_key_vault" "default" {
  name                = local.key_vault_name
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  network_acls {
    bypass = "AzureServices"
    default_action = "Allow"
  }

  # Allow the current identity (e.g. whatever is running Terraform) to manage this KeyVault
  access_policy    
  {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    certificate_permissions = [
      "get",
      "create",
      "import",
      "delete",
      "update"
    ]
  }

  # Allow Azure CDN to be able to get secrets from this KeyVault
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azuread_service_principal.cdn.object_id

    secret_permissions = [
      "get"
    ]
  }
}

resource "azurerm_key_vault_certificate" "default" {
  name         = "${replace(var.domain, ".", "_")}-${substr(var.environment, 0, 2)}"
  key_vault_id = azurerm_key_vault.default.id

  certificate {
    contents = acme_certificate.default.certificate_p12
    password = acme_certificate.default.certificate_p12_password
  }

  certificate_policy {
    issuer_parameters {
      name = "Unknown"
    }

    key_properties {
      exportable = true
      key_size   = 2048
      key_type   = "RSA"
      reuse_key  = false
    }

    secret_properties {
      content_type = "application/x-pkcs12"
    }
  }
}