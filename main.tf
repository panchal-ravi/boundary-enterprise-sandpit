locals {
  deployment_id = lower("${var.deployment_name}-${random_string.suffix.result}")
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

module "boundary-cluster" {
  source                 = "./modules/cluster/aws"
  deployment_id          = local.deployment_id
  owner                  = var.owner
  vpc_cidr               = var.aws_vpc_cidr
  public_subnets         = var.aws_public_subnets
  private_subnets        = var.aws_private_subnets
  instance_type          = var.aws_instance_type
  controller_count       = var.controller_count
  auth0_domain           = var.auth0_domain
  auth0_client_id        = var.auth0_client_id
  auth0_client_secret    = var.auth0_client_secret
  okta_org_name          = var.okta_org_name
  okta_base_url          = var.okta_base_url
  okta_api_token         = var.okta_api_token
  controller_db_username = var.controller_db_username
  controller_db_password = var.controller_db_password
  user_password          = var.user_password
}


module "boundary-resources" {
  source                = "./modules/resources"
  auth0_domain          = var.auth0_domain
  boundary_cluster_url  = module.boundary-cluster.boundary_cluster_url
  client_id             = module.boundary-cluster.auth0_client.client_id
  client_secret         = module.boundary-cluster.auth0_client.client_secret
  okta_domain           = var.okta_domain
  okta_client_id        = module.boundary-cluster.okta_client.client_id
  okta_client_secret    = module.boundary-cluster.okta_client.client_secret
  vault_ip              = module.boundary-cluster.vault_ip
  static_creds_username = var.rds_username
  static_creds_password = var.rds_password
}


module "vault-credstore" {
  source               = "./modules/vault-credstore"
  project_id           = module.boundary-resources.project_id
  vault_ip             = module.boundary-cluster.vault_ip
  bastion_ip           = module.boundary-cluster.bastion_ip
  boundary_cluster_url = module.boundary-cluster.boundary_cluster_url
  boundary_password    = trimspace(file("${path.root}/generated/boundary_password"))
}

module "ssh-target" {
  source                           = "./modules/targets/ssh-target"
  deployment_id                    = local.deployment_id
  vpc_id                           = module.boundary-cluster.vpc_id
  vpc_cidr                         = module.boundary-cluster.vpc_cidr_block
  private_subnets                  = module.boundary-cluster.private_subnets
  aws_keypair_keyname              = module.boundary-cluster.aws_keypair_keyname
  vault_credstore_id               = trimspace(file("${path.root}/generated/vault_credstore_id")) //module.vault-credstore.vault_credstore_id
  org_id                           = module.boundary-resources.org_id
  project_id                       = module.boundary-resources.project_id
  auth0_managed_group_admin_id     = module.boundary-resources.auth0_managed_group_admin_id
  okta_managed_group_admin_id      = module.boundary-resources.okta_managed_group_admin_id
  boundary_cluster_url             = module.boundary-cluster.boundary_cluster_url
  boundary_password                = trimspace(file("${path.root}/generated/boundary_password"))
  bastion_ip                       = module.boundary-cluster.ingress_worker_ip
  worker_ingress_security_group_id = module.boundary-cluster.worker_ingress_security_group_id
  worker_egress_security_group_id  = module.boundary-cluster.worker_egress_security_group_id
  owner                            = var.owner
}

module "db-target" {
  source                           = "./modules/targets/db-target"
  deployment_id                    = local.deployment_id
  vpc_id                           = module.boundary-cluster.vpc_id
  vpc_cidr                         = module.boundary-cluster.vpc_cidr_block
  private_subnets                  = module.boundary-cluster.private_subnets
  org_id                           = module.boundary-resources.org_id
  project_id                       = module.boundary-resources.project_id
  rds_username                     = var.rds_username
  rds_password                     = var.rds_password
  vault_credstore_id               = trimspace(file("${path.root}/generated/vault_credstore_id")) //module.vault-credstore.vault_credstore_id
  auth0_managed_group_admin_id     = module.boundary-resources.auth0_managed_group_admin_id
  auth0_managed_group_analyst_id   = module.boundary-resources.auth0_managed_group_analyst_id
  okta_managed_group_admin_id      = module.boundary-resources.okta_managed_group_admin_id
  okta_managed_group_analyst_id    = module.boundary-resources.okta_managed_group_analyst_id
  worker_ip                        = module.boundary-cluster.ingress_worker_ip
  worker_ingress_security_group_id = module.boundary-cluster.worker_ingress_security_group_id
  worker_egress_security_group_id  = module.boundary-cluster.worker_egress_security_group_id
  vault_security_group_id          = module.boundary-cluster.vault_security_group_id
}



module "rdp-target" {
  source                          = "./modules/targets/rdp-target"
  deployment_id                   = local.deployment_id
  vpc_id                          = module.boundary-cluster.vpc_id
  vpc_cidr                        = module.boundary-cluster.vpc_cidr_block
  private_subnets                 = module.boundary-cluster.private_subnets
  aws_keypair_keyname             = module.boundary-cluster.aws_keypair_keyname
  vault_credstore_id              = trimspace(file("${path.root}/generated/vault_credstore_id")) //module.vault-credstore.vault_credstore_id
  org_id                          = module.boundary-resources.org_id
  project_id                      = module.boundary-resources.project_id
  auth0_managed_group_admin_id    = module.boundary-resources.auth0_managed_group_admin_id
  auth0_managed_group_analyst_id  = module.boundary-resources.auth0_managed_group_analyst_id
  okta_managed_group_admin_id     = module.boundary-resources.okta_managed_group_admin_id
  okta_managed_group_analyst_id   = module.boundary-resources.okta_managed_group_analyst_id
  credlib_vault_db_admin_id       = module.db-target.credlib_vault_db_admin_id
  credlib_vault_db_analyst_id     = module.db-target.credlib_vault_db_analyst_id
  static_credstore_id             = module.boundary-resources.static_credstore_id
  worker_egress_security_group_id = module.boundary-cluster.worker_egress_security_group_id
  owner                           = var.owner
}

module "k8s-target" {
  source                            = "./modules/targets/k8s-target"
  deployment_id                     = local.deployment_id
  vpc_id                            = module.boundary-cluster.vpc_id
  vpc_cidr                          = module.boundary-cluster.vpc_cidr_block
  region                            = var.aws_region
  private_subnets                   = module.boundary-cluster.private_subnets
  aws_keypair_keyname               = module.boundary-cluster.aws_keypair_keyname
  static_db_creds_id                = module.boundary-resources.static_db_creds_id
  org_id                            = module.boundary-resources.org_id
  project_id                        = module.boundary-resources.project_id
  vault_credstore_id                = trimspace(file("${path.root}/generated/vault_credstore_id")) //module.vault-credstore.vault_credstore_id
  auth0_managed_group_admin_id      = module.boundary-resources.auth0_managed_group_admin_id
  auth0_managed_group_analyst_id    = module.boundary-resources.auth0_managed_group_analyst_id
  okta_managed_group_admin_id       = module.boundary-resources.okta_managed_group_admin_id
  okta_managed_group_analyst_id     = module.boundary-resources.okta_managed_group_analyst_id
  db_username                       = var.rds_username
  db_password                       = var.rds_password
  boundary_cluster_address_internal = module.boundary-cluster.boundary_cluster_url_internal
  boundary_cluster_address          = module.boundary-cluster.boundary_cluster_url
  boundary_user                     = "admin"
  boundary_password                 = trimspace(file("${path.root}/generated/boundary_password"))
  owner                             = var.owner
}
