variable "deployment_id" {
  type = string
}

variable "boundary_cluster_url" {
  type = string
}

variable "user_password" {
  type = string
}

variable "okta_domain" {
  type = string
}

variable "boundary_resources" {
  type = object({
    scopes          = any
    orgs            = any
    projects        = any
    global_scope_id = string
    org_id          = string
    project_id      = string
  })
}
