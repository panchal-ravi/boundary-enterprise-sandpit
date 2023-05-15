resource "kubernetes_config_map_v1" "grafana_cm" {
  metadata {
    name      = "grafana"
    namespace = local.monitoring_namespace
  }
  data = {
    "prometheus_datasource.yml" = templatefile("${path.root}/files/observability/prometheus_datasource.yml.tpl", {
      prometheus_server_url       = "http://prometheus.monitoring:9090"
    })
  }
  depends_on = [kubernetes_namespace.monitoring]
}

resource "kubernetes_service_v1" "grafana_service" {
  metadata {
    name      = "grafana"
    namespace = local.monitoring_namespace
  }
  spec {
    selector = {
      app       = "grafana",
    }
    port {
      port        = 3000
      target_port = 3000
      name        = "http"
    }
  }
  depends_on = [kubernetes_namespace.monitoring]
}

resource "kubernetes_deployment_v1" "grafana_deployment" {
  metadata {
    name      = "grafana"
    namespace = local.monitoring_namespace

    labels = {
      app = "grafana"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "grafana"
      }
    }

    template {
      metadata {
        labels = {
          app = "grafana"
        }
      }

      spec {
        container {
          image = "grafana/grafana"
          name  = "grafana"
          port {
            container_port = 3000
          }
          volume_mount {
            mount_path = "/etc/grafana/provisioning/datasources/"
            name       = "grafana-config-volume"
          }
        }
        volume {
          name = "grafana-config-volume"
          config_map {
            name = "grafana"
          }
        }
      }
    }
  }
  depends_on = [kubernetes_namespace.monitoring, kubernetes_deployment_v1.prometheus_deployment]
}
