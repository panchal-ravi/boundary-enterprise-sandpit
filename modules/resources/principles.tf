resource "boundary_managed_group" "auth0_db_admin" {
  name           = "auth0_db_admin"
  description    = "DB Admin managed group"
  auth_method_id = boundary_auth_method_oidc.auth0_oidc.id
  filter         = "\"admin\" in \"/userinfo/org-roles\""
}

resource "boundary_managed_group" "auth0_db_analyst" {
  name           = "auth0_db_analyst"
  description    = "DB Analyst managed group"
  auth_method_id = boundary_auth_method_oidc.auth0_oidc.id
  filter         = "\"analyst\" in \"/userinfo/org-roles\""
}

resource "boundary_managed_group" "okta_db_analyst" {
  name           = "okta_db_analyst"
  description    = "Okta - DB Analyst managed group"
  auth_method_id = boundary_auth_method_oidc.okta_oidc.id
  filter         = "\"analyst\" in \"/userinfo/groups\""
}

resource "boundary_managed_group" "okta_db_admin" {
  name           = "okta_db_admin"
  description    = "Okta - DB Admin managed group"
  auth_method_id = boundary_auth_method_oidc.okta_oidc.id
  filter         = "\"admin\" in \"/userinfo/groups\""
}

resource "boundary_account_password" "admin" {
  auth_method_id = boundary_auth_method_password.password.id
  type           = "password"
  login_name     = var.boundary_admin_username
  password       = var.boundary_admin_password
}

resource "boundary_user" "admin" {
  name        = var.boundary_admin_username
  description = "admin user resource"
  account_ids = [boundary_account_password.admin.id]
  scope_id    = boundary_scope.global.id
}
