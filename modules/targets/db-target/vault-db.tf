resource "vault_mount" "db" {
  path = "db"
  type = "database"
}

resource "vault_database_secret_backend_connection" "postgres" {
  backend       = vault_mount.db.path
  name          = "postgres"
  allowed_roles = ["admin", "analyst"]

  postgresql {
    connection_url = "postgres://${var.rds_creds.username}:${var.rds_creds.password}@${aws_db_instance.db_target.address}/postgres"
  }
}

resource "vault_database_secret_backend_role" "role_admin" {
  backend             = vault_mount.db.path
  name                = "admin"
  db_name             = vault_database_secret_backend_connection.postgres.name
  creation_statements = ["CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; GRANT dba TO \"{{name}}\";"]
  default_ttl         = 300
  max_ttl             = 600
}

resource "vault_database_secret_backend_role" "role_analyst" {
  backend             = vault_mount.db.path
  name                = "analyst"
  db_name             = vault_database_secret_backend_connection.postgres.name
  creation_statements = ["CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; GRANT analyst TO \"{{name}}\";"]
  default_ttl         = 300
  max_ttl             = 600
}
