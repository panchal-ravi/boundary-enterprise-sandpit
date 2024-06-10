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
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.15.0"
    }
  }
}
