
resource "boundary_credential_store_static" "static_cred_store" {
  for_each    = local.scopes
  name        = "boundary-cred-store"
  description = "Static boundary credential store"
  scope_id    = boundary_scope.project[each.key].id
}

resource "boundary_credential_username_password" "static_db_creds" {
  for_each            = local.scopes
  name                = "static_db_creds"
  description         = "RDS admin credentials"
  credential_store_id = boundary_credential_store_static.static_cred_store[each.key].id
  username            = var.static_creds_username
  password            = var.static_creds_password
}
