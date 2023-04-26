resource "boundary_credential_store_static" "static_cred_store" {
  name        = "boundary-cred-store"
  description = "Static boundary credential store"
  scope_id    = boundary_scope.project.id
}

resource "boundary_credential_username_password" "static_db_creds" {
  name                = "static_db_creds"
  description         = "RDS admin credentials"
  credential_store_id = boundary_credential_store_static.static_cred_store.id
  username            = var.static_creds_username
  password            = var.static_creds_password
}
