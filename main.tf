locals {
  deployment_id = lower("${var.deployment_name}-${random_string.suffix.result}")
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

module "boundary-cluster" {
  source                 = "./modules/infra/aws/cluster"
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
  az_ad_tenant_id        = var.az_ad_tenant_id
  az_ad_client_id        = var.az_ad_client_id
  az_ad_client_secret    = var.az_ad_client_secret
  user_password          = var.user_password
}


module "boundary-workers" {
  source = "./modules/infra/aws/workers"
  providers = {
    boundary = boundary.recovery
  }
  deployment_id                    = local.deployment_id
  owner                            = var.owner
  vpc_cidr_block                   = module.boundary-cluster.vpc_cidr_block
  vpc_id                           = module.boundary-cluster.vpc_id
  public_subnets                   = module.boundary-cluster.public_subnets
  private_subnets                  = module.boundary-cluster.private_subnets
  instance_type                    = var.aws_instance_type
  aws_keypair_key_name             = module.boundary-cluster.aws_keypair_keyname
  controller_internal_dns          = module.boundary-cluster.controller_internal_dns
  bastion_ip                       = module.boundary-cluster.bastion_ip
  bastion_security_group_id        = module.boundary-cluster.bastion_security_group_id
  worker_ingress_security_group_id = module.boundary-cluster.worker_ingress_security_group_id
  worker_egress_security_group_id  = module.boundary-cluster.worker_egress_security_group_id
  boundary_cluster_url             = module.boundary-cluster.boundary_cluster_url
  worker_instance_profile          = module.boundary-cluster.worker_instance_profile
}

module "boundary-resources" {
  source = "./modules/resources"
  providers = {
    boundary = boundary.recovery
  }
  auth0_domain            = var.auth0_domain
  boundary_cluster_url    = module.boundary-cluster.boundary_cluster_url
  client_id               = module.boundary-cluster.auth0_client.client_id
  client_secret           = module.boundary-cluster.auth0_client.client_secret
  okta_domain             = var.okta_domain
  okta_client_id          = module.boundary-cluster.okta_client.client_id
  okta_client_secret      = module.boundary-cluster.okta_client.client_secret
  az_ad_client_id         = module.boundary-cluster.azure_client.client_id
  az_ad_client_secret     = module.boundary-cluster.azure_client.client_secret
  az_ad_tenant_id         = var.az_ad_tenant_id
  az_ad_group_admin_id    = module.boundary-cluster.az_ad_group_admin_id
  az_ad_group_analyst_id  = module.boundary-cluster.az_ad_group_analyst_id
  vault_ip                = module.boundary-cluster.vault_ip
  static_creds_username   = var.rds_username
  static_creds_password   = var.rds_password
  boundary_admin_username = var.boundary_admin_username
  boundary_admin_password = var.boundary_admin_password
}


module "vault-credstore" {
  source     = "./modules/vault-credstore"
  projects   = module.boundary-resources.projects
  vault_ip   = module.boundary-cluster.vault_ip
  bastion_ip = module.boundary-cluster.bastion_ip
}

module "ssh-target" {
  source                           = "./modules/targets/ssh-target"
  deployment_id                    = local.deployment_id
  vpc_id                           = module.boundary-cluster.vpc_id
  vpc_cidr                         = module.boundary-cluster.vpc_cidr_block
  private_subnets                  = module.boundary-cluster.private_subnets
  aws_keypair_keyname              = module.boundary-cluster.aws_keypair_keyname
  vault_credstore_id               = module.vault-credstore.vault_credstore_id
  org_id                           = module.boundary-resources.org_id
  project_id                       = module.boundary-resources.project_id
  auth0_managed_group_admin_id     = module.boundary-resources.auth0_managed_group_admin_id
  okta_managed_group_admin_id      = module.boundary-resources.okta_managed_group_admin_id
  azure_managed_group_admin_id     = module.boundary-resources.azure_managed_group_admin_id
  bastion_ip                       = module.boundary-workers.ingress_worker_ip
  worker_ingress_security_group_id = module.boundary-cluster.worker_ingress_security_group_id
  worker_egress_security_group_id  = module.boundary-cluster.worker_egress_security_group_id
  session_storage_role_arn         = module.boundary-cluster.session_storage_role_arn
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
  vault_credstore_id               = module.vault-credstore.vault_credstore_id
  auth0_managed_group_admin_id     = module.boundary-resources.auth0_managed_group_admin_id
  auth0_managed_group_analyst_id   = module.boundary-resources.auth0_managed_group_analyst_id
  azure_managed_group_admin_id     = module.boundary-resources.azure_managed_group_admin_id
  azure_managed_group_analyst_id   = module.boundary-resources.azure_managed_group_analyst_id
  okta_managed_group_admin_id      = module.boundary-resources.okta_managed_group_admin_id
  okta_managed_group_analyst_id    = module.boundary-resources.okta_managed_group_analyst_id
  worker_ip                        = module.boundary-workers.ingress_worker_ip
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
  vault_credstore_id              = module.vault-credstore.vault_credstore_id
  org_id                          = module.boundary-resources.org_id
  project_id                      = module.boundary-resources.project_id
  auth0_managed_group_admin_id    = module.boundary-resources.auth0_managed_group_admin_id
  auth0_managed_group_analyst_id  = module.boundary-resources.auth0_managed_group_analyst_id
  azure_managed_group_admin_id    = module.boundary-resources.azure_managed_group_admin_id
  azure_managed_group_analyst_id  = module.boundary-resources.azure_managed_group_analyst_id
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
  vault_credstore_id                = module.vault-credstore.vault_credstore_id
  auth0_managed_group_admin_id      = module.boundary-resources.auth0_managed_group_admin_id
  auth0_managed_group_analyst_id    = module.boundary-resources.auth0_managed_group_analyst_id
  azure_managed_group_admin_id      = module.boundary-resources.azure_managed_group_admin_id
  azure_managed_group_analyst_id    = module.boundary-resources.azure_managed_group_analyst_id
  okta_managed_group_admin_id       = module.boundary-resources.okta_managed_group_admin_id
  okta_managed_group_analyst_id     = module.boundary-resources.okta_managed_group_analyst_id
  db_username                       = var.rds_username
  db_password                       = var.rds_password
  boundary_cluster_address_internal = module.boundary-cluster.boundary_cluster_url_internal
  boundary_static_credstore_id      = module.boundary-resources.static_credstore_id
  /* boundary_cluster_address          = module.boundary-cluster.boundary_cluster_url
  boundary_user                     = var.boundary_admin_username
  boundary_password                 = var.boundary_admin_password  */
  controller_ops_address           = module.boundary-cluster.controller_ops_address
  controller_node_exporter_address = module.boundary-cluster.controller_node_exporter_address
  ingress_worker_ip                = module.boundary-workers.ingress_worker_private_ip
  egress_worker_ip                 = module.boundary-workers.egress_worker_ip
  bastion_ip                       = module.boundary-cluster.bastion_ip
  controller_ips                   = module.boundary-cluster.controller_ips
  owner                            = var.owner
}
