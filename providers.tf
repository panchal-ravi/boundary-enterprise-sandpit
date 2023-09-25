terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.20.0"
    }
    boundary = {
      source  = "hashicorp/boundary"
      version = "1.1.9"
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
  alias            = "recovery"
  addr             = "https://${module.boundary-cluster.boundary_cluster_url}"
  recovery_kms_hcl = trimspace(file("${path.root}/generated/kms_recovery.hcl"))
  tls_insecure     = true
  //password_auth_method_login_name = var.boundary_admin_username
  //auth_method_id                  = trimspace(file("${path.root}/generated/global_auth_method_id"))
  //password_auth_method_password   = trimspace(file("${path.root}/generated/boundary_password"))
}


provider "boundary" {
  addr                            = "https://${module.boundary-cluster.boundary_cluster_url}"
  auth_method_id                  = module.boundary-resources.global_auth_method_id
  password_auth_method_login_name = var.boundary_admin_username
  password_auth_method_password   = var.boundary_admin_password
  tls_insecure                    = true
  //recovery_kms_hcl = trimspace(file("${path.root}/generated/kms_recovery.hcl"))
} 


provider "vault" {
  address = "http://${var.localhost}:8200"
  token   = trimspace(file("${path.root}/generated/vault_token"))
}
