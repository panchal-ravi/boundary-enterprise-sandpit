variable "vault_ip" {
  type = string
}

variable "static_creds_username" {
  type = string
}

variable "static_creds_password" {
  type = string
}
variable "boundary_admin_username" {
  type = string
}
variable "boundary_admin_password" {
  type = string
}

variable "boundary_cluster_url" {
  type = string
}

/*
variable "idp_type" {
  type = string
}

variable "auth_method_oidc" {
  type = object({
    name                 = string
    description          = string
    issuer               = string
    client_id            = string
    client_secret        = string
    callback_url         = optional(string)
    api_url_prefix       = optional(string)
    signing_algorithms   = optional(list(string))
    claims_scopes        = optional(list(string))
    is_primary_for_scope = optional(bool)
    max_age              = optional(number)
  })
  default = {
    name                 = ""
    description          = ""
    issuer               = ""
    api_url_prefix       = ""
    callback_url         = ""
    client_id            = ""
    client_secret        = ""
    claims_scopes        = ["profile", "email", "groups"]
    signing_algorithms   = ["RS256"]
    is_primary_for_scope = true
    max_age              = 0
  }
}
*/