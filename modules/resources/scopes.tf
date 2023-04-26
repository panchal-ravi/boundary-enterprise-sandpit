resource "boundary_scope" "global" {
  global_scope = true
  scope_id     = "global"
}

resource "boundary_scope" "org" {
  scope_id               = boundary_scope.global.id
  name                   = "demo-org"
  description            = "Demo Organization"
  auto_create_admin_role = true
}

resource "boundary_scope" "project" {
  name                   = "IT_Support"
  description            = "IT Support"
  scope_id               = boundary_scope.org.id
  auto_create_admin_role = true
}
