disable_mlock = true
listener "tcp" {
  purpose = "proxy"
  address = "0.0.0.0:9202"
}

listener "tcp" {
  purpose = "ops"
  address = "0.0.0.0:9203"
  tls_disable = true
}

worker {
  public_addr = "${public_addr}"
  initial_upstreams = ["${controller_lb_dns}:9201"]
  auth_storage_path = "/home/boundary/worker1"
  controller_generated_activation_token = "${activation_token}"
  tags {
    type = ["eks", "worker-k8s"]
  }
}