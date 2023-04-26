storage "raft" {
  path    = "/opt/vault/data"
  node_id = "node1"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = "true"
}

disable_mlock = true
log_level     = "Trace"
log_format    = "standard"
api_addr      = "http://0.0.0.0:8200"
cluster_addr  = "https://127.0.0.1:8201"
ui            = true
