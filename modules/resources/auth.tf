resource "boundary_auth_method_password" "password" {
  scope_id              = boundary_scope.global.id
  description           = "Password authenticate method"
  min_login_name_length = 5
  min_password_length   = 8
}

resource "boundary_auth_method_oidc" "auth0_oidc" {
  scope_id             = boundary_scope.org.id
  name                 = "Auth0"
  description          = "OIDC auth method for Demo Organization"
  type                 = "oidc"
  issuer               = "https://${var.auth0_domain}/"
  client_id            = var.client_id
  client_secret        = var.client_secret
  callback_url         = "https://${var.boundary_cluster_url}/v1/auth-methods/oidc:authenticate:callback"
  api_url_prefix       = "https://${var.boundary_cluster_url}"
  signing_algorithms   = ["RS256"]
  claims_scopes        = ["profile", "email", "groups"]
  is_primary_for_scope = true
  max_age              = 0
}


resource "boundary_auth_method_oidc" "okta_oidc" {
  scope_id             = boundary_scope.org.id
  name                 = "Okta"
  description          = "OKta OIDC auth method for Demo Organization"
  type                 = "oidc"
  issuer               = "https://${var.okta_domain}"
  client_id            = var.okta_client_id
  client_secret        = var.okta_client_secret
  callback_url         = "https://${var.boundary_cluster_url}/v1/auth-methods/oidc:authenticate:callback"
  api_url_prefix       = "https://${var.boundary_cluster_url}"
  signing_algorithms   = ["RS256"]
  claims_scopes        = ["profile", "email", "groups"]
  is_primary_for_scope = false

  max_age = 10
}
