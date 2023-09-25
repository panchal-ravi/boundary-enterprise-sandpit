variable "boundary_cluster_url" {
  type = string
}

variable "client_id" {
  type = string
}

variable "client_secret" {
  type = string
}

variable "auth0_domain" {
  type = string
}

variable "okta_client_id" {
  type = string
}

variable "okta_client_secret" {
  type = string
}

variable "okta_domain" {
  type = string
}
/* variable "bastion_ip" {
  type = string
} */
variable "vault_ip" {
  type = string
}

variable "static_creds_username" {
  type = string
}

variable "static_creds_password" {
  type = string
}
variable "boundary_admin_username" {
  type = string
}
variable "boundary_admin_password" {
  type = string
}

variable "az_ad_tenant_id" {
  type = string
}

variable "az_ad_client_id" {
  type = string
}

variable "az_ad_client_secret" {
  type = string
}
variable "az_ad_group_admin_id" {
  type = string
}
variable "az_ad_group_analyst_id" {
  type = string
}