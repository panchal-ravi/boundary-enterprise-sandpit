disable_mlock = true

# listener denoting this is a worker proxy
listener "tcp" {
  address = "${private_ip}:9202"
  purpose = "proxy"
}


listener "tcp" {
    address = "${private_ip}:9203"
    purpose = "ops"
    tls_disable = true
}
  
worker {
    # Name attr must be unique
    public_addr = "${public_ip}"
    initial_upstreams = ["${controller_lb_dns}:9201"]
    auth_storage_path = "/etc/boundary.d/auth_storage"
    recording_storage_path="/etc/boundary.d/session_storage"
    controller_generated_activation_token = "${activation_token}"
    tags {
        type = ["ingress", "upstream", "worker1"]
    }
}

# Events (logging) configuration. This
# configures logging for ALL events to both
# stderr and a file at /var/log/boundary/<boundary_use>.log
events {
  audit_enabled       = true
  sysevents_enabled   = true
  observations_enable = true
  sink "stderr" {
    name = "all-events"
    description = "All events sent to stderr"
    event_types = ["*"]
    format = "cloudevents-json"
  }
  sink {
    name = "file-sink"
    description = "All events sent to a file"
    event_types = ["*"]
    format = "cloudevents-json"
    file {
      path = "/var/log/boundary"
      file_name = "ingress-worker.log"
    }

    audit_config {
      audit_filter_overrides {
        // sensitive = "redact"
        secret    = "redact"
      }
    }
  }
}

kms "aead"{
    purpose = "worker-auth-storage"
    aead_type = "aes-gcm"
    key = "${worker_auth_storage_kms}"
    key_id = "global_worker_auth_storage"
}

# kms block for encrypting the authentication PKI material
// kms "awskms" {
//   purpose    = "worker-auth-storage"
//   region     = "us-east-1"
//   kms_key_id = "19ec80b0-dfdd-4d97-8164-c6examplekey3"
//   endpoint   = "https://vpce-0e1bb1852241f8cc6-pzi0do8n.kms.us-east-1.vpce.amazonaws.com"
// }

