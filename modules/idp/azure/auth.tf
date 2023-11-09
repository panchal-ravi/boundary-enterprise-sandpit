resource "boundary_auth_method_oidc" "this" {
  scope_id             = var.boundary_resources.org_id
  name                 = "Azure"
  description          = "Azure OIDC auth method for Digital Channels"
  type                 = "oidc"
  issuer               = "https://login.microsoftonline.com/${var.az_ad_tenant_id}/v2.0"
  client_id            = azuread_application.client_app.application_id
  client_secret        = azuread_application_password.client_app.value
  callback_url         = "https://${var.boundary_cluster_url}/v1/auth-methods/oidc:authenticate:callback"
  api_url_prefix       = "https://${var.boundary_cluster_url}"
  signing_algorithms   = ["RS256"]
  claims_scopes        = ["profile", "email"]
  is_primary_for_scope = true
  max_age              = 10
}

