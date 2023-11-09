resource "okta_app_oauth" "my_client" {
  label                     = "Boundary OIDC Test App"
  type                      = "web"
  grant_types               = ["authorization_code"]
  redirect_uris             = ["https://${var.boundary_cluster_url}/v1/auth-methods/oidc:authenticate:callback"]
  post_logout_redirect_uris = ["https://${var.boundary_cluster_url}"]
  response_types            = ["code"]

  groups_claim {
    type        = "FILTER"
    filter_type = "REGEX"
    name        = "groups"
    value       = ".*"
  }
  lifecycle {
    ignore_changes = [groups]
  }
}

resource "okta_app_group_assignments" "my_client_groups" {
  app_id = okta_app_oauth.my_client.id
  group {
    id = okta_group.analyst.id
  }
  group {
    id = okta_group.admin.id
  }
}

resource "okta_user" "admin" {
  first_name = "Admin"
  last_name  = "User"
  login      = "admin@demo.com"
  email      = "admin@demo.com"
  password   = var.user_password
}

resource "okta_user" "analyst" {
  first_name = "Analyst"
  last_name  = "User"
  login      = "analyst@demo.com"
  email      = "analyst@demo.com"
  password   = var.user_password
}

resource "okta_group" "analyst" {
  name        = "analyst"
  description = "Analyst Group"
}

resource "okta_group" "admin" {
  name        = "admin"
  description = "Admin Group"
}


resource "okta_group_memberships" "analyst" {
  group_id = okta_group.analyst.id
  users = [
    okta_user.analyst.id,
  ]
}

resource "okta_group_memberships" "admin" {
  group_id = okta_group.admin.id
  users = [
    okta_user.admin.id,
  ]
}