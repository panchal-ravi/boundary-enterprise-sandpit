output "kibana_url" {
  value = "${data.kubernetes_service_v1.kibana.status.0.load_balancer.0.ingress.0.hostname}:5601"
}