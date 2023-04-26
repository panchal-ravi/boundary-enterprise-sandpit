/* 
resource "vault_mount" "kubernetes" {
  path = "kubernetes"
  type = "kubernetes"
}
*/

resource "vault_kubernetes_secret_backend" "config" {
  path                 = "kubernetes"
  description          = "kubernetes secrets engine description"
  kubernetes_host      = data.aws_eks_cluster.cluster.endpoint
  kubernetes_ca_cert   = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  service_account_jwt  = data.kubernetes_secret_v1.vault.data.token
  disable_local_ca_jwt = false
}

resource "vault_kubernetes_secret_backend_role" "sa-example" {
  backend                       = vault_kubernetes_secret_backend.config.path
  name                          = "my-role"
  allowed_kubernetes_namespaces = ["*"]
  token_max_ttl                 = 600
  token_default_ttl             = 600
  /* service_account_name          = "test-service-account-with-generated-token" */
  generated_role_rules =  <<EOT
{
    "rules":[
        {
          "apiGroups":[""],
          "resources":["pods", "services", "persistentvolumeclaims"],
          "verbs":["get", "list", "watch"]
        },
        {
          "apiGroups":["extensions", "apps"],
          "resources":["deployments", "replicasets", "statefulsets"],
          "verbs":["get", "list", "watch"]
        }
    ]
}
EOT
}