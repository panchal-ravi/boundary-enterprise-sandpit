variable "deployment_id" {
  type = string
}

variable "owner" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnets" {
  description = "Public subnets"
  type        = list(any)
}
variable "private_subnets" {
  description = "Private subnets"
  type        = list(any)
}

variable "instance_type" {
  type = string
}

variable "controller_db_username" {
  type = string
}

variable "controller_db_password" {
  type = string
}

variable "controller_count" {
  type = number
}
variable "auth0_domain" {
  type = string
}

variable "auth0_client_id" {
  type = string
}

variable "auth0_client_secret" {
  type = string
}

variable "okta_api_token" {
  type = string
}

variable "okta_base_url" {
  type = string
}

variable "okta_org_name" {
  type = string
}

variable "user_password" {
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