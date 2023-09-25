variable "deployment_id" {
  type = string
}
variable "vpc_id" {
  type = string
}
variable "vpc_cidr" {
  type = string
}
variable "private_subnets" {
  description = "Private subnets"
  type        = list(any)
}
variable "aws_keypair_keyname" {
  type = string
}
variable "owner" {
  type = string
}
variable "vault_credstore_id" {
  type = string
}
variable "static_db_creds_id" {
  type = string
}
variable "boundary_static_credstore_id" {
  type = string
}
variable "auth0_managed_group_analyst_id" {
  type = string
}
variable "auth0_managed_group_admin_id" {
  type = string
}
variable "azure_managed_group_analyst_id" {
  type = string
}
variable "azure_managed_group_admin_id" {
  type = string
}
variable "okta_managed_group_analyst_id" {
  type = string
}
variable "okta_managed_group_admin_id" {
  type = string
}
variable "project_id" {
  type = string
}
variable "org_id" {
  type = string
}
variable "db_username" {
  type = string
}
variable "db_password" {
  type = string
}
variable "region" {
  type = string
}
variable "boundary_cluster_address_internal" {
  type = string
}
/*
variable "boundary_cluster_address" {
  type = string
} 
variable "boundary_user" {
  type = string
}
variable "boundary_password" {
  type = string
} */
variable "controller_ops_address" {
  type = list(string)
}
variable "controller_node_exporter_address" {
  type = list(string)
}
variable "ingress_worker_ip" {
  type = string
}
variable "egress_worker_ip" {
  type = string
}
variable "bastion_ip" {
  type = string
}
variable "controller_ips" {
  type = list(string)
}