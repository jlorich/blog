resource "azuread_service_principal" "cdn" {
  application_id               = "205478c0-bd83-4e1b-a9d6-db63a3e1e1c8" # ID for AZURE CDN
  app_role_assignment_required = false
}