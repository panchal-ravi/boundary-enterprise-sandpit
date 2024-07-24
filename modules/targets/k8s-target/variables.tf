variable "deployment_id" {
  type = string
}
variable "owner" {
  type = string
}
variable "vault_credstore_id" {
  type = string
}
variable "region" {
  type = string
}

variable "ingress_worker_ip" {
  type = string
}
variable "egress_worker_ip" {
  type = string
}
variable "boundary_version" {
  type = string
}
variable "infra_aws" {
  type = object({
    vpc_cidr_block                   = string
    vpc_id                           = string
    public_subnets                   = list(string)
    private_subnets                  = list(string)
    aws_keypair_key_name             = string
    controller_ips                   = list(string)
    controller_internal_dns          = string
    controller_ops_address           = list(string)
    controller_node_exporter_address = list(string)
    boundary_cluster_url_internal    = string
    bastion_ip                       = string
    vault_ip                         = string
    bastion_security_group_id        = string
    vault_security_group_id          = string
    worker_ingress_security_group_id = string
    worker_egress_security_group_id  = string
    boundary_cluster_url             = string
    worker_instance_profile          = string
    session_storage_role_arn         = string
  })
}

variable "boundary_resources" {
  type = object({
    org_id                   = string
    project_id               = string
    static_credstore_id      = string
    static_db_creds_id       = string
  })
}

variable "rds_creds" {
  type = object({
    username = string
    password = string
  })
}
