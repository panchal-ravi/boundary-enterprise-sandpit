locals {
  auth0_connection = "Username-Password-Authentication"
}

resource "auth0_client" "my_client" {
  name                = var.deployment_id
  description         = "Boundary auth0 client application"
  app_type            = "regular_web"
  callbacks           = ["https://${var.boundary_cluster_url}/v1/auth-methods/oidc:authenticate:callback"]
  allowed_logout_urls = ["https://${var.boundary_cluster_url}"]
  oidc_conformant     = true

  jwt_configuration {
    alg = "RS256"
  }
}

resource "auth0_action" "my_action" {
  name    = format("Add user role to token %s", timestamp())
  runtime = "node16"
  deploy  = true
  code    = <<-EOT
  /**
    * Handler that will be called during the execution of a PostLogin flow.
    *
    * @param {Event} event - Details about the user and the context in which they are logging in.
    * @param {PostLoginAPI} api - Interface whose methods can be used to change the behavior of the login.
    */
  exports.onExecutePostLogin = async (event, api) => {
    const namespace = 'test-ns';
    if (event.authorization) {
      api.idToken.setCustomClaim(`org-roles`, event.authorization.roles);
      api.accessToken.setCustomClaim(`org-roles`, event.authorization.roles);
    }
  };
  EOT

  supported_triggers {
    id      = "post-login"
    version = "v3"
  }
}

resource "auth0_trigger_binding" "login_flow" {
  trigger = "post-login"

  actions {
    id           = auth0_action.my_action.id
    display_name = auth0_action.my_action.name
  }
}

resource "auth0_role" "analyst" {
  name        = "analyst"
  description = "Analyst role with view only permissions"
}

resource "auth0_role" "admin" {
  name        = "admin"
  description = "Admin role with full permissions"
}

resource "auth0_user" "analyst" {
  connection_name = local.auth0_connection
  name            = "analyst"
  email           = "analyst@demo.com"
  email_verified  = true
  password        = var.user_password
  roles           = [auth0_role.analyst.id]
}

resource "auth0_user" "admin" {
  connection_name = local.auth0_connection
  name            = "admin"
  email           = "admin@demo.com"
  email_verified  = true
  password        = var.user_password
  roles           = [auth0_role.admin.id]
}
