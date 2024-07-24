locals {
  elastic_namespace = "elastic-system"
}

resource "kubernetes_namespace" "elastic" {
  metadata {
    name = local.elastic_namespace
  }
  # depends_on = [module.eks]
}

resource "null_resource" "deploy_elastic_stack" {
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = <<-EOD
    kubectl apply -f ${path.root}/files/observability/elastic-crds.yml --kubeconfig ${path.root}/kubeconfig
    kubectl apply -f ${path.root}/files/observability/elastic-operator.yml --kubeconfig ${path.root}/kubeconfig
    kubectl apply -f ${path.root}/files/observability/elastic-search.yml --kubeconfig ${path.root}/kubeconfig
    kubectl apply -f ${path.root}/files/observability/kibana.yml --kubeconfig ${path.root}/kubeconfig
    EOD
  }
  depends_on = [null_resource.kubeconfig, kubernetes_namespace.elastic]
}

resource "time_sleep" "wait_for_elastic" {
  depends_on      = [null_resource.deploy_elastic_stack]
  create_duration = "60s"
}

data "kubernetes_service_v1" "elastic" {
  metadata {
    name = "quickstart-es-http"
  }
  depends_on = [time_sleep.wait_for_elastic]
}

data "kubernetes_service_v1" "kibana" {
  metadata {
    name = "quickstart-kb-http"
  }
  depends_on = [time_sleep.wait_for_elastic]
}

data "kubernetes_secret_v1" "elastic" {
  metadata {
    name = "quickstart-es-elastic-user"
  }
  depends_on = [time_sleep.wait_for_elastic]
}

resource "null_resource" "delete_elastic_stack" {
  provisioner "local-exec" {
    when    = destroy
    command = <<-EOD
    kubectl delete -f ${path.root}/files/observability/elastic-search.yml --kubeconfig ${path.root}/kubeconfig
    kubectl delete -f ${path.root}/files/observability/kibana.yml --kubeconfig ${path.root}/kubeconfig
    EOD
  }
}
