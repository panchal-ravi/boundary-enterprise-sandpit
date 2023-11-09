data "azuread_domains" "aad_domains" {}
data "azuread_client_config" "current" {}

resource "azuread_user" "admin" {
  user_principal_name   = "admin@${data.azuread_domains.aad_domains.domains[0].domain_name}"
  display_name          = "admin"
  mail_nickname         = "admin"
  password              = var.user_password
  account_enabled       = true
  force_password_change = false
}

resource "azuread_user" "analyst" {
  user_principal_name   = "analyst@${data.azuread_domains.aad_domains.domains[0].domain_name}"
  display_name          = "analyst"
  mail_nickname         = "analyst"
  password              = var.user_password
  account_enabled       = true
  force_password_change = false
}

resource "azuread_group" "admin" {
  display_name     = "admin"
  owners           = [data.azuread_client_config.current.object_id]
  security_enabled = true

  members = [
    azuread_user.admin.object_id,
  ]
}

resource "azuread_group" "analyst" {
  display_name     = "analyst"
  owners           = [data.azuread_client_config.current.object_id]
  security_enabled = true

  members = [
    azuread_user.analyst.object_id,
  ]
}

resource "azuread_application" "client_app" {
  display_name     = "Boundary OIDC Test App"
  owners           = [data.azuread_client_config.current.object_id]
  sign_in_audience = "AzureADMyOrg"

  feature_tags {
    enterprise = true
    gallery    = true
  }

  group_membership_claims = ["SecurityGroup"]

  web {
    /* homepage_url  = "https://app.example.net" */
    logout_url    = "https://${var.boundary_cluster_url}"
    redirect_uris = ["https://${var.boundary_cluster_url}/v1/auth-methods/oidc:authenticate:callback"]

    implicit_grant {
      access_token_issuance_enabled = true
      id_token_issuance_enabled     = true
    }
  }
}

resource "azuread_application_password" "client_app" {
  application_object_id = azuread_application.client_app.object_id
}