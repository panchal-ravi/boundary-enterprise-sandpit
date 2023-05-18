data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.18.0"

  name                 = var.deployment_id
  cidr                 = var.vpc_cidr
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = var.private_subnets
  public_subnets       = var.public_subnets
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/${var.deployment_id}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.deployment_id}" = "shared"
    "kubernetes.io/role/elb"                     = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.deployment_id}" = "shared"
    "kubernetes.io/role/internal-elb"            = "1"
  }
}
