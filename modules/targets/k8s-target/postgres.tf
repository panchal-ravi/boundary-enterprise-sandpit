resource "kubernetes_config_map" "postgres_config" {
  metadata {
    name = "postgres-config"
  }

  data = {
    "POSTGRES_DB"       = "postgres"
    "POSTGRES_USER"     = "${var.db_username}"
    "POSTGRES_PASSWORD" = "${var.db_password}"
  }

}

resource "kubernetes_deployment_v1" "postgres_deployment" {
  metadata {
    name = "postgres"
    labels = {
      app = "postgres"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "postgres"
      }
    }

    template {
      metadata {
        labels = {
          app = "postgres"
        }
      }

      spec {
        container {
          image = "postgres:10.1"
          name  = "postgres"
          port {
            container_port = 5432
          }
          volume_mount {
            mount_path = "/var/lib/postgresql/data"
            name       = "postgresdb"
          }
          env_from {
            config_map_ref {
              name = "postgres-config"
            }
          }
        }
        volume {
          name = "postgresdb"
          persistent_volume_claim {
            claim_name = "postgres-pv-claim"
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "postgres_service" {
  metadata {
    name = "postgres"
  }
  spec {
    selector = {
      app = "postgres"
    }
    port {
      port = 5432
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_persistent_volume_v1" "postgres_pv_volume" {
  metadata {
    name = "postgres-pv-volume"
    labels = {
      type = "local"
      app  = "postgres"
    }
  }
  spec {
    storage_class_name = "manual"
    capacity = {
      storage = "5Gi"
    }
    access_modes = ["ReadWriteMany"]
    persistent_volume_source {
      host_path {
        path = "/mnt/data"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim_v1" "postgres_pv_claim" {
  metadata {
    name = "postgres-pv-claim"
    labels = {
      "app" = "postgres"
    }
  }
  spec {
    access_modes       = ["ReadWriteMany"]
    storage_class_name = "manual"
    resources {
      requests = {
        storage = "5Gi"
      }
    }
  }
}
