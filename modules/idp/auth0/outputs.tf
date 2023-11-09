output "client" {
  value = {
    client_id     = auth0_client.my_client.client_id,
    client_secret = auth0_client.my_client.client_secret
  }
}

output "managed_group" {
  value = {
    admin_id   = boundary_managed_group.db_admin.id,
    analyst_id = boundary_managed_group.db_analyst.id
  }
}
