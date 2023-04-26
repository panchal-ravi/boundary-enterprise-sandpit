variable "deployment_name" {
  type = string
}

variable "owner" {
  description = "Resource owner identified using an email address"
  type        = string
  default     = "rp"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = ""
}

variable "aws_vpc_cidr" {
  description = "AWS VPC CIDR"
  type        = string
  default     = "10.200.0.0/16"
}

variable "aws_private_subnets" {
  description = "AWS private subnets"
  type        = list(any)
  default     = ["10.200.20.0/24", "10.200.21.0/24", "10.200.22.0/24"]
}

variable "aws_private_subnets_eks" {
  description = "AWS private subnets"
  type        = list(any)
  default     = ["10.200.30.0/24", "10.200.31.0/24", "10.200.32.0/24"]
}


variable "aws_public_subnets" {
  description = "AWS public subnets"
  type        = list(any)
  default     = ["10.200.10.0/24", "10.200.11.0/24", "10.200.12.0/24"]
}

variable "aws_instance_type" {
  description = "AWS instance type"
  type        = string
  default     = "t3.micro"
}

variable "controller_db_username" {
  type = string
}

variable "controller_db_password" {
  type = string
}

variable "controller_count" {
  type    = number
  default = 1
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
variable "okta_domain" {
  type = string
}
variable "okta_org_name" {
  type = string
}

variable "user_password" {
  type = string
}

variable "localhost" {
  type = string
  default = "127.0.0.1"
}

variable "rds_username" {
  type = string
}

variable "rds_password" {
  type = string
}

/* 
variable "rdp_username" {
  type = string
}

variable "rdp_password" {
  type = string
} 

*/
