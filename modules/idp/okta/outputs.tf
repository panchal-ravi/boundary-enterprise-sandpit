
output "client" {
  value = {
    client_id     = okta_app_oauth.my_client.client_id,
    client_secret = okta_app_oauth.my_client.client_secret
  }
}

output "managed_group" {
  value = {
    admin_id   = boundary_managed_group.db_admin.id,
    analyst_id = boundary_managed_group.db_analyst.id
  }
}
