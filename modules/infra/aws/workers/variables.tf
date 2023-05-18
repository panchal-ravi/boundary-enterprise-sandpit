variable "vpc_id" {
  type = string
}
variable "vpc_cidr_block" {
  type = string
}
variable "bastion_security_group_id" {
  type = string
}
variable "instance_type" {
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
variable "owner" {
  type = string
}
variable "deployment_id" {
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

