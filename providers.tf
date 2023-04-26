terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.20.0"
    }
    boundary = {
      source  = "hashicorp/boundary"
      version = "1.1.4"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "3.8.2"
    }
  }
}

provider "aws" {
  region = var.aws_region
}


provider "boundary" {
  addr                            = "https://${module.boundary-cluster.boundary_cluster_url}"
  auth_method_id                  = trimspace(file("${path.root}/generated/global_auth_method_id"))
  password_auth_method_login_name = "admin"
  password_auth_method_password   = trimspace(file("${path.root}/generated/boundary_password"))
  /* recovery_kms_hcl = trimspace(file("${path.root}/generated/kms_recovery.hcl")) */
  tls_insecure = true
}

provider "vault" {
  address = "http://${var.localhost}:8200"
  token   = trimspace(file("${path.root}/generated/vault_token"))
}
