# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# config file version
apiVersion: 1

datasources:
- name: boundary
  type: prometheus
  access: server
  orgId: 1
  url: ${prometheus_server_url}
  password:
  user:
  database:
  basicAuth:
  basicAuthUser:
  basicAuthPassword:
  withCredentials:
  isDefault:
  jsonData:
     graphiteVersion: "1.1"
     tlsAuth: false
     tlsAuthWithCACert: false
  secureJsonData:
    tlsCACert: ""
    tlsClientCert: ""
    tlsClientKey: ""
  version: 1
  editable: true