# disable memory from being swapped to disk
disable_mlock = true

# API listener configuration block
listener "tcp"{
  # Should be the address of the NIC that the controller server will be reached on
  # Use 0.0.0.0 to listen on all interfaces
  address = "${private_ip}:9200"
  # The purpose of this listener block
  purpose = "api"

  # TLS Configuration
  tls_disable   = false
  tls_cert_file = "/etc/boundary.d/tls/boundary-cert.pem"
  tls_key_file  = "/etc/boundary.d/tls/boundary-key.pem"

  # Uncomment to enable CORS for the Admin UI. Be sure to set the allowed origin(s)
  # to appropriate values.
  #cors_enabled = true
  #cors_allowed_origins = [
  #  "https://yourcorp.yourdomain.com",
  #  "serve://boundary"
  #]
}

# Data-plane listener configuration block (used for worker coordination)
listener "tcp"{
  # Should be the IP of the NIC that the worker will connect on
  address = "${private_ip}:9201"
  # The purpose of this listener
  purpose = "cluster"
}

# Ops listener for operations like health checks for load balancers
listener "tcp"{
  # Should be the address of the interface where your external systems'
  # (eg: Load-Balancer and metrics collectors) will connect on.
  address = "${private_ip}:9203"
  # The purpose of this listener block
  purpose = "ops"

  tls_disable   = true
  # tls_cert_file = "/etc/boundary.d/tls/boundary-cert.pem"
  # tls_key_file  = "/etc/boundary.d/tls/boundary-key.pem"
}

# Controller configuration block
controller {
  # This name attr must be unique across all controller instances if running in HA mode
  name = "boundary-controller-${count}"
  description = "Boundary controller number ${count}"

  # This is the public hostname or IP where the workers can reach the
  # controller. This should typically be a load balancer address
  public_cluster_address = "${controller_lb_dns}:9201"

  # Enterprise license file, can also be the raw value or env: // value
  license = "file:///etc/boundary.d/license.hclic"

  # After receiving a shutdown signal, Boundary will wait 10s before initiating the shutdown process.
  graceful_shutdown_wait_duration = "10s"

  # Database URL for postgres. This is set in boundary.env and
  #consumed via the “env: //” notation.
  database {
      url = "env://POSTGRESQL_CONNECTION_STRING"
  }
}

# Events (logging) configuration. This
# configures logging for ALL events to both
# stderr and a file at /var/log/boundary/controller.log
events {
  audit_enabled       = true
  sysevents_enabled   = true
  observations_enable = true
  sink "stderr"{
    name = "all-events"
    description = "All events sent to stderr"
    event_types = [
      "*"
    ]
    format = "cloudevents-json"
  }
  sink {
    name = "file-sink"
    description = "All events sent to a file"
    event_types = [
      "audit"
    ]
    format = "cloudevents-json"
    deny_filters = [
      "\"/data/request_info/method\" contains \"ServerCoordinationService\"",
      "\"/data/request_info/path\" contains \"assets\"",
      "\"/data/request_info/path\" contains \"core\""
    ]
    file {
      path = "/var/log/boundary"
      file_name = "controller.log"
    }
    audit_config {
      audit_filter_overrides {
        sensitive = "" // disable applying filter to sensitive fields
        secret    = "redact"
      }
    }
  }
}

# Root KMS configuration block: this is the root key for Boundary
# Use a production KMS such as AWS KMS in production installs
kms "aead"{
  purpose = "root"
  aead_type = "aes-gcm"
  key = "${root_kms}"
  key_id = "global_root"
}

# Worker authorization KMS
# Use a production KMS such as AWS KMS for production installs
# This key is the same key used in the worker configuration
kms "aead"{
  purpose = "worker-auth"
  aead_type = "aes-gcm"
  key = "${worker_auth_kms}"
  key_id = "global_worker-auth"
}

kms "aead" {
  purpose = "bsr"
  aead_type = "aes-gcm"
  key = "${bsr_kms}"
  key_id = "bsr"
}

# Root KMS Key (managed by AWS KMS in this example)
# Keep in mind that sensitive values are provided via ENV VARS
# in this example, such as access_key and secret_key
// kms "awskms" {
//   purpose    = "root"
//   region     = "us-east-1"
//   kms_key_id = "19ec80b0-dfdd-4d97-8164-c6examplekey"
//   endpoint   = "https://vpce-0e1bb1852241f8cc6-pzi0do8n.kms.us-east-1.vpce.amazonaws.com"
// }

# Recovery KMS Key
// kms "awskms" {
//   purpose    = "recovery"
//   region     = "us-east-1"
//   kms_key_id = "19ec80b0-dfdd-4d97-8164-c6examplekey2"
//   endpoint   = "https://vpce-0e1bb1852241f8cc6-pzi0do8n.kms.us-east-1.vpce.amazonaws.com"
// }

# Worker-Auth KMS Key (optional, only needed if using
# KMS authenticated workers)
// kms "awskms" {
//   purpose    = "worker-auth"
//   region     = "us-east-1"
//   kms_key_id = "19ec80b0-dfdd-4d97-8164-c6examplekey3"
//   endpoint   = "https://vpce-0e1bb1852241f8cc6-pzi0do8n.kms.us-east-1.vpce.amazonaws.com"
// }
