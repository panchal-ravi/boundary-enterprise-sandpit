resource "boundary_auth_method_oidc" "this" {
  scope_id             = var.boundary_resources.org_id
  name                 = "Auth0"
  description          = "Auth0 OIDC authentication method"
  type                 = "oidc"
  issuer               = "https://${var.auth0_domain}/"
  client_id            = auth0_client.my_client.client_id
  client_secret        = auth0_client.my_client.client_secret
  callback_url         = "https://${var.boundary_cluster_url}/v1/auth-methods/oidc:authenticate:callback"
  api_url_prefix       = "https://${var.boundary_cluster_url}"
  signing_algorithms   = ["RS256"]
  claims_scopes        = ["profile", "email", "groups"]
  is_primary_for_scope = true
  max_age              = 0
}

/*
resource "boundary_auth_method_oidc" "auth0_oidc" {
  scope_id             = boundary_scope.org[local.digital_channel_org].id
  name                 = "Auth0"
  description          = "OIDC auth method for Digital Channels"
  type                 = "oidc"
  issuer               = "https://${var.auth0_domain}/"
  client_id            = var.client_id
  client_secret        = var.client_secret
  callback_url         = "https://${var.boundary_cluster_url}/v1/auth-methods/oidc:authenticate:callback"
  api_url_prefix       = "https://${var.boundary_cluster_url}"
  signing_algorithms   = ["RS256"]
  claims_scopes        = ["profile", "email", "groups"]
  is_primary_for_scope = false
  max_age              = 0
}
*/