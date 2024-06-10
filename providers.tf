terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.20.0"
    }
    boundary = {
      source  = "hashicorp/boundary"
      version = "1.1.15"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "4.2.0"
    }

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

provider "aws" {
  region = var.aws_region
}


provider "boundary" {
  alias            = "recovery"
  addr             = "https://${module.boundary-cluster.infra_aws.boundary_cluster_url}"
  recovery_kms_hcl = trimspace(file("${path.root}/generated/kms_recovery.hcl"))
  tls_insecure     = true
  //password_auth_method_login_name = var.boundary_admin_username
  //auth_method_id                  = trimspace(file("${path.root}/generated/global_auth_method_id"))
  //password_auth_method_password   = trimspace(file("${path.root}/generated/boundary_password"))
}


provider "boundary" {
  addr                            = "https://${module.boundary-cluster.infra_aws.boundary_cluster_url}"
  auth_method_id                  = module.boundary-resources.global_auth_method_id
  auth_method_login_name = var.boundary_admin_username
  auth_method_password   = var.boundary_admin_password
  tls_insecure                    = true
  //recovery_kms_hcl = trimspace(file("${path.root}/generated/kms_recovery.hcl"))
}


provider "vault" {
  address = "http://${var.localhost}:8200"
  token   = trimspace(file("${path.root}/generated/vault_token"))
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

provider "azuread" {
  tenant_id     = var.az_ad_tenant_id
  client_id     = var.az_ad_client_id
  client_secret = var.az_ad_client_secret
}