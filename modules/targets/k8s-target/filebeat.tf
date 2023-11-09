resource "null_resource" "filebeat" {
  count = length(var.infra_aws.controller_ips)


  provisioner "file" {
    content = templatefile("${path.root}/files/observability/filebeat.yml.tpl", {
      elastic_url      = data.kubernetes_service_v1.elastic.status.0.load_balancer.0.ingress.0.hostname,
      kibana_url       = data.kubernetes_service_v1.kibana.status.0.load_balancer.0.ingress.0.hostname,
      elastic_password = data.kubernetes_secret_v1.elastic.data.elastic
    })
    destination = "/tmp/filebeat.yml"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/filebeat.yml /etc/filebeat/filebeat.yml",
      "sudo chown root:root /etc/filebeat/filebeat.yml",
      "sudo systemctl start filebeat || sudo systemctl restart filebeat",
    ]
  }

  connection {
    bastion_host        = var.infra_aws.bastion_ip
    bastion_user        = "ubuntu"
    agent               = false
    bastion_private_key = file("${path.root}/generated/ssh_key")

    host        = var.infra_aws.controller_ips[count.index]
    user        = "ubuntu"
    private_key = file("${path.root}/generated/ssh_key")
  }

  depends_on = [time_sleep.wait_for_elastic]
}
