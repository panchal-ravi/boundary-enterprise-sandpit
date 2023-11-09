/*
variable "vpc_id" {
  type = string
}
variable "vpc_cidr_block" {
  type = string
}
variable "bastion_security_group_id" {
  type = string
}
variable "public_subnets" {
  type = list(string)
}
variable "private_subnets" {
  type = list(string)
}
variable "aws_keypair_key_name" {
  type = string
}
variable "controller_internal_dns" {
  type = string
}
variable "bastion_ip" {
  type = string
}
variable "boundary_cluster_url" {
  type = string
}
variable "worker_ingress_security_group_id" {
  type = string
}
variable "worker_egress_security_group_id" {
  type = string
}

variable "worker_instance_profile" {
  type = string
}
*/

variable "owner" {
  type = string
}
variable "deployment_id" {
  type = string
}
variable "instance_type" {
  type = string
}
variable "infra_aws" {
  type = object({
    vpc_cidr_block                   = string
    vpc_id                           = string
    public_subnets                   = list(string)
    private_subnets                  = list(string)
    aws_keypair_key_name             = string
    controller_internal_dns          = string
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