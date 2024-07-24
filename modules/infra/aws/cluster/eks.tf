
module "eks" {
  source                          = "terraform-aws-modules/eks/aws"
  version                         = "~> 19.0"
  cluster_name                    = var.deployment_id
  cluster_version                 = "1.29"
  vpc_id                          = module.vpc.vpc_id
  subnet_ids                      = [module.vpc.private_subnets[0], module.vpc.private_subnets[1]]
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  cluster_service_ipv4_cidr       = "172.20.0.0/18"

  eks_managed_node_group_defaults = {
  }

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
    /*
    aws-ebs-csi-driver = {
      most_recent              = true
      service_account_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/AmazonEKS_EBS_CSI_DriverRole"
    }
    */
  }
  cluster_security_group_additional_rules = {
    ops_private_access_egress = {
      description = "Ops Private Egress"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "egress"
      cidr_blocks = [module.vpc.vpc_cidr_block]
    }
    ops_private_access_ingress = {
      description = "Ops Private Ingress"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      cidr_blocks = [module.vpc.vpc_cidr_block]
    }
  }
  eks_managed_node_groups = {
    default = {
      min_size               = 1
      max_size               = 3
      desired_size           = 2
      instance_types         = ["t3.medium"]
      key_name               = aws_key_pair.this.key_name
      vpc_security_group_ids = [module.private-ssh.security_group_id]
      iam_role_additional_policies = {
        AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
      }
    }
  }

  tags = {
    owner = var.owner
  }
}