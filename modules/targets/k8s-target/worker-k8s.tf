resource "kubernetes_config_map" "config" {
  metadata {
    name = "boundary-k8s-worker-config"
  }

  data = {
    "boundary-worker.hcl" = "${templatefile("${path.root}/files/boundary/boundary-worker-k8s-configmap.hcl.tpl", {
      controller_lb_dns = var.boundary_cluster_address_internal,
      public_addr       = kubernetes_service_v1.service.status.0.load_balancer.0.ingress.0.hostname
    })}"
  }
}


resource "kubernetes_stateful_set_v1" "statefulset" {
  metadata {
    name = "boundary-worker-k8s"
    labels = {
      app       = "boundary",
      component = "worker",
      env       = "k8s"
    }
  }

  spec {
    replicas     = 1
    service_name = "boundary-k8s-worker-svc"

    selector {
      match_labels = {
        app       = "boundary",
        component = "worker",
        env       = "k8s"
      }
    }

    template {
      metadata {
        labels = {
          app       = "boundary",
          component = "worker",
          env       = "k8s"
        }
      }

      spec {
        container {
          image   = "hashicorp/boundary-worker-hcp:0.12.2-hcp"
          name    = "boundary-worker"
          command = ["boundary-worker", "server", "-config", "/etc/boundary/boundary-worker.hcl"]
          port {
            container_port = 9202
          }
          volume_mount {
            mount_path = "/etc/boundary"
            name       = "boundary-config"
          }
          volume_mount {
            mount_path = "/home/boundary"
            name       = "worker-data"
          }
          security_context {
            privileged = true
          }
        }
        volume {
          name = "boundary-config"
          config_map {
            name = "boundary-k8s-worker-config"
          }
        }
      }
    }
    volume_claim_template {
      metadata {
        name = "worker-data"
      }
      spec {
        access_modes = ["ReadWriteOnce"]
        resources {
          requests = {
            storage = "5Gi"
          }
        }
      }
    }
  }
}


resource "kubernetes_service_v1" "service" {
  metadata {
    name = "boundary-k8s-worker-svc"
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-type" = "nlb"
    }
  }
  spec {
    selector = {
      app       = "boundary",
      component = "worker",
      env       = "k8s"
    }
    port {
      port        = 9202
      target_port = 9202
      name        = "data"
    }
    type = "LoadBalancer"
  }
}

resource "kubernetes_service_v1" "worker_service_internal" {
  metadata {
    name = "boundary-k8s-worker-svc-internal"
    annotations = {
      "prometheus.io/port"   = "9203"
      "prometheus.io/scrape" = "true"
    }
  }
  spec {
    selector = {
      app       = "boundary",
      component = "worker",
      env       = "k8s"
    }
    port {
      port        = 9203
      target_port = 9203
      name        = "ops"
    }
  }
}


resource "null_resource" "register_k8s_worker" {
  provisioner "local-exec" {
    command = "kubectl exec -i $(kubectl get po -oname --kubeconfig ${path.root}/kubeconfig | grep -i boundary) --kubeconfig ${path.root}/kubeconfig -- cat /home/boundary/worker1/auth_request_token > ${path.root}/generated/k8s_auth_request_token"
  }

  provisioner "local-exec" {
    command = <<-EOD
      export BOUNDARY_ADDR=https://${var.boundary_cluster_address}
      export BOUNDARY_RECOVERY_CONFIG=${path.root}/generated/kms_recovery.hcl
      export BOUNDARY_TLS_INSECURE=true
      boundary workers create worker-led -scope-id=global -worker-generated-auth-token=${trimspace(file("${path.root}/generated/k8s_auth_request_token"))}
      EOD
  }

  depends_on = [
    null_resource.kubeconfig, kubernetes_stateful_set_v1.statefulset
  ]
}


