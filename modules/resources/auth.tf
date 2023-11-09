resource "boundary_auth_method_password" "password" {
  scope_id              = boundary_scope.global.id
  description           = "Password authenticate method"
  min_login_name_length = 5
  min_password_length   = 8
}

resource "boundary_account_password" "admin" {
  auth_method_id = boundary_auth_method_password.password.id
  login_name     = var.boundary_admin_username
  password       = var.boundary_admin_password
}

resource "boundary_user" "admin" {
  name        = var.boundary_admin_username
  description = "admin user resource"
  account_ids = [boundary_account_password.admin.id]
  scope_id    = boundary_scope.global.id
}
