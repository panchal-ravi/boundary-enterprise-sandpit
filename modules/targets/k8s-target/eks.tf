data "aws_caller_identity" "current" {}

# module "eks" {
#   source                          = "terraform-aws-modules/eks/aws"
#   version                         = "~> 19.0"
#   cluster_name                    = var.deployment_id
#   cluster_version                 = "1.29"
#   vpc_id                          = var.infra_aws.vpc_id
#   subnet_ids                      = [var.infra_aws.private_subnets[0], var.infra_aws.private_subnets[1]]
#   cluster_endpoint_private_access = true
#   cluster_endpoint_public_access  = true
#   cluster_service_ipv4_cidr       = "172.20.0.0/18"

#   eks_managed_node_group_defaults = {
#   }

#   cluster_addons = {
#     coredns = {
#       most_recent = true
#     }
#     kube-proxy = {
#       most_recent = true
#     }
#     vpc-cni = {
#       most_recent = true
#     }
#     aws-ebs-csi-driver = {
#       most_recent = true
#     }
#     /*
#     aws-ebs-csi-driver = {
#       most_recent              = true
#       service_account_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/AmazonEKS_EBS_CSI_DriverRole"
#     }
#     */
#   }
#   cluster_security_group_additional_rules = {
#     ops_private_access_egress = {
#       description = "Ops Private Egress"
#       protocol    = "-1"
#       from_port   = 0
#       to_port     = 0
#       type        = "egress"
#       cidr_blocks = [var.infra_aws.vpc_cidr_block]
#     }
#     ops_private_access_ingress = {
#       description = "Ops Private Ingress"
#       protocol    = "-1"
#       from_port   = 0
#       to_port     = 0
#       type        = "ingress"
#       cidr_blocks = [var.infra_aws.vpc_cidr_block]
#     }
#   }
#   eks_managed_node_groups = {
#     default = {
#       min_size               = 1
#       max_size               = 3
#       desired_size           = 2
#       instance_types         = ["t3.medium"]
#       key_name               = var.infra_aws.aws_keypair_key_name
#       vpc_security_group_ids = [module.private-ssh.security_group_id]
#       iam_role_additional_policies = {
#         AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
#       }
#     }
#   }

#   tags = {
#     owner = var.owner
#   }
# }

/*
resource "aws_iam_role" "ebs-csi-role" {
  name = "AmazonEKS_EBS_CSI_DriverRole"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/oidc.eks.${var.region}.amazonaws.com/id/${split("/", module.eks.oidc_provider)[2]}"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "${module.eks.oidc_provider}:aud" : "sts.amazonaws.com",
            "${module.eks.oidc_provider}:sub" : "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          }
        }
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "ebs_csi_role_attach" {
  role       = aws_iam_role.ebs-csi-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}
*/

# The Kubernetes provider is included here so the EKS module can complete successfully. Otherwise, it throws an error when creating `kubernetes_config_map.aws_auth`.
# Retrieve EKS cluster configuration

data "aws_eks_cluster" "cluster" {
  name = var.deployment_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.deployment_id
}

resource "kubernetes_namespace" "test" {
  metadata {
    name = "test"
  }
  # depends_on = [module.eks]
}

resource "kubernetes_namespace" "vault" {
  metadata {
    name = "vault"
  }
  # depends_on = [module.eks]
}

resource "kubernetes_service_account_v1" "vault" {
  metadata {
    name      = "vault"
    namespace = "vault"
  }
  depends_on = [kubernetes_namespace.vault]
}

resource "kubernetes_secret_v1" "vault" {
  metadata {
    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account_v1.vault.metadata.0.name
    }
    generate_name = "vault-"
    namespace     = "vault"
  }

  type                           = "kubernetes.io/service-account-token"
  wait_for_service_account_token = true
}

resource "kubernetes_cluster_role_v1" "vault_role" {
  metadata {
    name = "k8s-full-secrets-abilities-with-labels"
  }

  rule {
    api_groups = [""]
    resources  = ["namespaces"]
    verbs      = ["get"]
  }
  rule {
    api_groups = [""]
    resources  = ["serviceaccounts", "serviceaccounts/token"]
    verbs      = ["create", "update", "delete"]
  }
  rule {
    api_groups = ["rbac.authorization.k8s.io"]
    resources  = ["rolebindings", "clusterrolebindings"]
    verbs      = ["create", "update", "delete"]
  }
  rule {
    api_groups = ["rbac.authorization.k8s.io"]
    resources  = ["roles", "clusterroles"]
    verbs      = ["bind", "escalate", "create", "update", "delete"]
  }
  # depends_on = [module.eks]
}

resource "kubernetes_cluster_role_binding_v1" "vault_role_binding" {
  metadata {
    name = "k8s-full-secrets-abilities-with-labels"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "k8s-full-secrets-abilities-with-labels"
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.vault.metadata.0.name
    namespace = kubernetes_service_account_v1.vault.metadata.0.namespace
  }
  # depends_on = [module.eks]
}


data "kubernetes_secret_v1" "vault" {
  metadata {
    name      = kubernetes_secret_v1.vault.metadata.0.name
    namespace = kubernetes_secret_v1.vault.metadata.0.namespace
  }
  # depends_on = [module.eks]
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
}

resource "local_file" "vault_k8s_token" {
  filename = "${path.root}/generated/vault-k8s-token"
  content  = data.kubernetes_secret_v1.vault.data.token
}

resource "local_file" "k8s_ca_cert" {
  filename = "${path.root}/generated/k8s_ca.crt"
  content  = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
}

resource "null_resource" "kubeconfig" {
  provisioner "local-exec" {
    command = "aws eks --region ${var.region} update-kubeconfig --name ${var.deployment_id} --kubeconfig ${path.root}/kubeconfig"
  }

  # depends_on = [
  #   module.eks
  # ]
}

/* resource "null_resource" "delete_k8s" {

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOD
      rm ${path.root}/generated/k8s_ca.crt 
      EOD
  }
} */



