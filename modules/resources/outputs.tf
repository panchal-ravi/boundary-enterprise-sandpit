output "project_id" {
  value = boundary_scope.project.id
}

output "org_id" {
  value = boundary_scope.org.id
}

output "auth0_managed_group_analyst_id" {
  value = boundary_managed_group.auth0_db_analyst.id
}

output "auth0_managed_group_admin_id" {
  value = boundary_managed_group.auth0_db_admin.id
}

output "okta_managed_group_analyst_id" {
  value = boundary_managed_group.okta_db_analyst.id
}

output "okta_managed_group_admin_id" {
  value = boundary_managed_group.okta_db_admin.id
}

output "static_credstore_id" {
  value = boundary_credential_store_static.static_cred_store.id
}

output "static_db_creds_id" {
  value = boundary_credential_username_password.static_db_creds.id
}
