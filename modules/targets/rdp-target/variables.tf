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
variable "auth0_managed_group_analyst_id" {
  type = string
}
variable "auth0_managed_group_admin_id" {
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
variable "credlib_vault_db_admin_id" {
  type = string
}
variable "credlib_vault_db_analyst_id" {
  type = string
}
variable "static_credstore_id" {
  type = string
}
variable "worker_egress_security_group_id" {
  type = string
}