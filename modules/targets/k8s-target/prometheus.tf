locals {
  monitoring_namespace = "monitoring"
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = local.monitoring_namespace
  }
}

resource "kubernetes_service_account_v1" "prometheus" {
  metadata {
    name      = "prometheus"
    namespace = local.monitoring_namespace
  }
  depends_on = [kubernetes_namespace.monitoring]
}

resource "kubernetes_cluster_role_v1" "prometheus" {
  metadata {
    name = "prometheus"
  }

  rule {
    api_groups = [""]
    resources  = ["node", "services", "endpoints", "pods"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["extensions"]
    resources  = ["ingress"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding_v1" "prometheus" {
  metadata {
    name = "prometheus"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "prometheus"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "prometheus"
    namespace = "monitoring"
  }
}

resource "kubernetes_config_map_v1" "prometheus_cm" {
  metadata {
    name      = "prometheus"
    namespace = local.monitoring_namespace
  }
  data = {
    "prometheus.yml" = templatefile("${path.root}/files/observability/prometheus.yml.tpl", {
      controller_ops_address           = var.controller_ops_address,
      controller_node_exporter_address = var.controller_node_exporter_address,
      ingress_worker_ip                = var.ingress_worker_ip,
      egress_worker_ip                 = var.egress_worker_ip
    })
  }
  depends_on = [kubernetes_namespace.monitoring]
}

resource "kubernetes_service_v1" "prometheus_service" {
  metadata {
    name      = "prometheus"
    namespace = local.monitoring_namespace
  }
  spec {
    selector = {
      app = "prometheus",
    }
    port {
      port        = 9090
      target_port = 9090
      name        = "http"
    }
  }
  depends_on = [kubernetes_namespace.monitoring]
}

resource "kubernetes_deployment_v1" "prometheus_deployment" {
  metadata {
    name      = "prometheus"
    namespace = local.monitoring_namespace

    labels = {
      app = "prometheus"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "prometheus"
      }
    }

    template {
      metadata {
        labels = {
          app = "prometheus"
        }
      }

      spec {
        service_account_name = "prometheus"
        container {
          image = "prom/prometheus"
          name  = "prometheus"
          port {
            container_port = 9090
          }
          args = ["--storage.tsdb.retention.time=12h", "--config.file=/etc/prometheus/prometheus.yml", "--storage.tsdb.path=/prometheus/"]
          volume_mount {
            mount_path = "/etc/prometheus/"
            name       = "prometheus-config-volume"
          }
          volume_mount {
            mount_path = "/prometheus/"
            name       = "prometheus-storage-volume"
          }
        }
        volume {
          name = "prometheus-config-volume"
          config_map {
            /* default_mode = "420" */
            name = "prometheus"
          }
        }
        volume {
          name = "prometheus-storage-volume"
          empty_dir {}
        }
      }
    }
  }
  depends_on = [kubernetes_namespace.monitoring]
}
