# Allows anonymous (un-authenticated) users to list and authenticate against any
# auth method, list the global scope, and read and change password on their account ID
# at the global scope
resource "boundary_role" "global_anon_listing" {
  scope_id = "global"
  grant_strings = [
    "ids=*;type=auth-method;actions=list,authenticate",
    "ids=*;type=scope;actions=list,no-op",
    "ids={{.Account.Id}};actions=read,change-password"
  ]
  grant_scope_ids = ["this", "descendants"]
  principal_ids = ["u_anon"]
}

resource "boundary_role" "global_admin" {
  scope_id      = boundary_scope.global.id
  name          = "global_admin_role"
  grant_strings = ["ids=*;type=*;actions=*"]
  grant_scope_ids = ["this", "descendants"]
  principal_ids = [boundary_user.admin.id]
}

/*
resource "boundary_role" "org_admin" {
  for_each      = local.scopes
  scope_id      = boundary_scope.org[each.key].id
  name          = "org_admin_role"
  grant_strings = ["ids=*;type=*;actions=*"]
  principal_ids = [boundary_user.admin.id]
}

resource "boundary_role" "project_admin" {
  for_each      = local.scopes
  scope_id      = boundary_scope.project[each.key].id
  name          = "project_admin_role"
  grant_strings = ["ids=*;type=*;actions=*"]
  principal_ids = [boundary_user.admin.id]
}

resource "boundary_role" "org_anon_listing" {
  for_each = local.scopes
  scope_id = boundary_scope.org[each.key].id
  name     = "org_anon"
  grant_strings = [
    "ids=*;type=auth-method;actions=list,authenticate",
    "type=scope;actions=list",
    "ids={{account.id}};actions=read,change-password"
  ]
  principal_ids = ["u_anon"]
}
resource "boundary_role" "default_org" {
  for_each       = local.scopes
  name           = "default_org_${each.key}"
  scope_id       = boundary_scope.global.id
  grant_scope_id = boundary_scope.org[each.key].id
  grant_strings = [
    "id=${boundary_scope.project[each.key].id};actions=read",
    "id={{.User.Id}};actions=read",
    "id=*;type=auth-token;actions=list,read:self,delete:self"
  ]
  // principal_ids = local.principal_ids[each.key]
  principal_ids = [boundary_managed_group.db_analyst.id, boundary_managed_group.db_admin.id]
}

resource "boundary_role" "default_project" {
  for_each       = local.scopes
  name           = "default_project"
  scope_id       = boundary_scope.org[each.key].id
  grant_scope_id = boundary_scope.project[each.key].id
  grant_strings = [
    "id=*;type=session;actions=list,no-op",
    "id=*;type=session;actions=read:self,cancel:self",
  ]
  // principal_ids = local.principal_ids[each.key]
  principal_ids = [boundary_managed_group.db_analyst.id, boundary_managed_group.db_admin.id]
}
*/