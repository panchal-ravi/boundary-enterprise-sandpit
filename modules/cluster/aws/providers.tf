terraform {
  required_providers {
    auth0 = {
      source  = "auth0/auth0"
      version = "0.39.0"
    }
    okta = {
      source  = "okta/okta"
      version = "3.40.0"
    }
  }
}

provider "auth0" {
  domain        = var.auth0_domain
  client_id     = var.auth0_client_id
  client_secret = var.auth0_client_secret
  debug         = true
}

provider "okta" {
  org_name  = var.okta_org_name
  base_url  = var.okta_base_url
  api_token = var.okta_api_token
}