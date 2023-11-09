locals {
  deployment_id = lower("${var.deployment_name}-${random_string.suffix.result}")
  rds_creds = {
    username = var.rds_username
    password = var.rds_password
  }
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
  controller_db_username = var.controller_db_username
  controller_db_password = var.controller_db_password
}


module "boundary-workers" {
  source = "./modules/infra/aws/workers"
  providers = {
    boundary = boundary.recovery
  }
  owner         = var.owner
  deployment_id = local.deployment_id
  instance_type = var.aws_instance_type
  infra_aws     = module.boundary-cluster.infra_aws
}


module "boundary-resources" {
  source = "./modules/resources"
  providers = {
    boundary = boundary.recovery
  }
  boundary_cluster_url    = module.boundary-cluster.infra_aws.boundary_cluster_url
  vault_ip                = module.boundary-cluster.infra_aws.vault_ip
  static_creds_username   = var.rds_username
  static_creds_password   = var.rds_password
  boundary_admin_username = var.boundary_admin_username
  boundary_admin_password = var.boundary_admin_password
}

module "idp-auth0" {
  count                = var.idp_type == "auth0" ? 1 : 0
  source               = "./modules/idp/auth0"
  auth0_domain         = var.auth0_domain
  deployment_id        = local.deployment_id
  boundary_resources   = module.boundary-resources.resources
  boundary_cluster_url = module.boundary-cluster.infra_aws.boundary_cluster_url
  user_password        = var.user_password
}

module "idp-azure" {
  count                = var.idp_type == "azure" ? 1 : 0
  source               = "./modules/idp/azure"
  deployment_id        = local.deployment_id
  boundary_resources   = module.boundary-resources.resources
  boundary_cluster_url = module.boundary-cluster.infra_aws.boundary_cluster_url
  az_ad_tenant_id      = var.az_ad_tenant_id
  user_password        = var.user_password
}


module "idp-okta" {
  count                = var.idp_type == "okta" ? 1 : 0
  source               = "./modules/idp/okta"
  deployment_id        = local.deployment_id
  okta_domain          = var.okta_domain
  boundary_resources   = module.boundary-resources.resources
  boundary_cluster_url = module.boundary-cluster.infra_aws.boundary_cluster_url
  user_password        = var.user_password
}


module "vault-credstore" {
  source     = "./modules/vault-credstore"
  projects   = module.boundary-resources.projects
  vault_ip   = module.boundary-cluster.infra_aws.vault_ip
  bastion_ip = module.boundary-cluster.infra_aws.bastion_ip
}


module "ssh-target" {
  source             = "./modules/targets/ssh-target"
  deployment_id      = local.deployment_id
  owner              = var.owner
  infra_aws          = module.boundary-cluster.infra_aws
  vault_credstore_id = module.vault-credstore.vault_credstore_id
  boundary_resources = module.boundary-resources.resources
  bastion_ip         = module.boundary-workers.ingress_worker_ip
}


module "db-target" {
  source             = "./modules/targets/db-target"
  deployment_id      = local.deployment_id
  infra_aws          = module.boundary-cluster.infra_aws
  boundary_resources = module.boundary-resources.resources
  rds_creds          = local.rds_creds
  vault_credstore_id = module.vault-credstore.vault_credstore_id
  bastion_ip         = module.boundary-workers.ingress_worker_ip
}


module "rdp-target" {
  source             = "./modules/targets/rdp-target"
  owner              = var.owner
  deployment_id      = local.deployment_id
  vault_credstore_id = module.vault-credstore.vault_credstore_id
  infra_aws          = module.boundary-cluster.infra_aws
  boundary_resources = module.boundary-resources.resources
}


module "k8s-target" {
  source             = "./modules/targets/k8s-target"
  owner              = var.owner
  deployment_id      = local.deployment_id
  region             = var.aws_region
  infra_aws          = module.boundary-cluster.infra_aws
  boundary_resources = module.boundary-resources.resources
  rds_creds          = local.rds_creds
  vault_credstore_id = module.vault-credstore.vault_credstore_id
  ingress_worker_ip  = module.boundary-workers.ingress_worker_private_ip
  egress_worker_ip   = module.boundary-workers.egress_worker_ip
}

