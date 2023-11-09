resource "boundary_auth_method_oidc" "this" {
  scope_id             = var.boundary_resources.org_id
  name                 = "Okta"
  description          = "OKta OIDC auth method for Middleware"
  type                 = "oidc"
  issuer               = "https://${var.okta_domain}"
  client_id            = okta_app_oauth.my_client.client_id
  client_secret        = okta_app_oauth.my_client.client_secret
  callback_url         = "https://${var.boundary_cluster_url}/v1/auth-methods/oidc:authenticate:callback"
  api_url_prefix       = "https://${var.boundary_cluster_url}"
  signing_algorithms   = ["RS256"]
  claims_scopes        = ["profile", "email", "groups"]
  is_primary_for_scope = true
  max_age = 0
}
