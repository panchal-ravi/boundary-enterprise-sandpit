resource "tls_private_key" "ca_private_key" {
  algorithm = "RSA"
}

resource "local_file" "ca_private_key" {
  content  = tls_private_key.ca_private_key.private_key_pem
  filename = "${path.module}/tmp/ca.key"
}

resource "tls_self_signed_cert" "ca_cert" {
  private_key_pem = tls_private_key.ca_private_key.private_key_pem

  is_ca_certificate = true

  subject {
    country             = "SG"
    province            = "Singapore"
    locality            = "Singapore"
    common_name         = "Demo Root CA"
    organization        = "Demo Organization"
    organizational_unit = "Demo Organization Root Certification Authority"
  }

  validity_period_hours = 43800 //  1825 days or 5 years

  allowed_uses = [
    "digital_signature",
    "cert_signing",
    "crl_signing",
  ]
}

resource "local_file" "ca_cert" {
  content  = tls_self_signed_cert.ca_cert.cert_pem
  filename = "${path.module}/tmp/ca.cert"
}

# Create private key for controller certificate 
resource "tls_private_key" "controller_private_key" {
  algorithm = "RSA"
}

resource "local_file" "controller_private_key" {
  content  = tls_private_key.controller_private_key.private_key_pem
  filename = "${path.module}/tmp/controller_private_key.key"
}

# Create CSR for for controller certificate 
resource "tls_cert_request" "controller_csr" {

  private_key_pem = tls_private_key.controller_private_key.private_key_pem

  dns_names = ["boundary.demo.com", "localhost", "127.0.0.1"]

  subject {
    country             = "SG"
    province            = "Singapore"
    locality            = "Singapore"
    common_name         = "boundary.demo.com"
    organization        = "Demo Organization"
    organizational_unit = "Development"
  }
}

# Sign Seerver Certificate by Private CA 
resource "tls_locally_signed_cert" "controller_signed_cert" {
  // CSR by the controller servers
  cert_request_pem = tls_cert_request.controller_csr.cert_request_pem
  // CA Private key 
  ca_private_key_pem = tls_private_key.ca_private_key.private_key_pem
  // CA certificate
  ca_cert_pem = tls_self_signed_cert.ca_cert.cert_pem

  validity_period_hours = 43800

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "server_auth",
    "client_auth",
  ]
}

resource "local_file" "controller_cert" {
  content  = tls_locally_signed_cert.controller_signed_cert.cert_pem
  filename = "${path.module}/tmp/controller.cert"
}