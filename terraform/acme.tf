provider "acme" {
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}

resource "tls_private_key" "private_key" {
  count = "${var.environment == "production" ? 1 : 0}"
  algorithm = "RSA"
}

resource "acme_registration" "reg" {
  count = "${var.environment == "production" ? 1 : 0}"
  account_key_pem = "${tls_private_key.private_key.private_key_pem}"
  email_address   = "joseph@lorich.me"
}

resource "acme_certificate" "default" {
  count = "${var.environment == "production" ? 1 : 0}"
  account_key_pem           = "${acme_registration.reg.account_key_pem}"
  common_name               = "joeylorich.net"
  subject_alternative_names = ["www.joeylorich.net"]

  dns_challenge {
    provider = "azure"
  }
}

locals {
  key_vault_name = "${var.prefix}${var.name}${substr(var.environment, 0, 2)}"
}

resource "azurerm_key_vault" "default" {
  count = "${var.environment == "production" ? 1 : 0}"
  name                        = local.key_vault_name
  location                    = azurerm_resource_group.default.location
  resource_group_name         = azurerm_resource_group.default.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id

  sku_name = "standard"

#   access_policy {
#     tenant_id = data.azurerm_client_config.current.tenant_id
#     object_id = data.azurerm_client_config.current.object_id

#     key_permissions = [
#       "get",
#     ]

#     secret_permissions = [
#       "get",
#     ]

#     storage_permissions = [
#       "get",
#     ]
#   }

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }
}

resource "azurerm_key_vault_certificate" "default" {
  count = "${var.environment == "production" ? 1 : 0}"
  name         = "joeylorich.net"
  key_vault_id = azurerm_key_vault.default.id

  certificate {
    contents = acme_certificate.default.certificate_p12
    password = acme_certificate.default.certificate_p12_password
  }

  certificate_policy {
    issuer_parameters {
      name = "Let's Encrypt"
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