# Allows anonymous (un-authenticated) users to list and authenticate against any
# auth method, list the global scope, and read and change password on their account ID
# at the global scope
/* resource "boundary_role" "global_anon_listing" {
  name     = "global_anon"
  scope_id = boundary_scope.global.id
  grant_strings = [
    "id=*;type=auth-method;actions=list,authenticate",
    "type=scope;actions=list",
    "id={{account.id}};actions=read,change-password"
  ]
  principal_ids = ["u_anon"]
} */

# Allows anonymous (un-authenticated) users to list and authenticate against any
# auth method, list the global scope, and read and change password on their account ID
# at the org level scope
resource "boundary_role" "org_anon_listing" {
  scope_id = boundary_scope.org.id
  name     = "org_anon"
  grant_strings = [
    "id=*;type=auth-method;actions=list,authenticate",
    "type=scope;actions=list",
    "id={{account.id}};actions=read,change-password"
  ]
  principal_ids = ["u_anon"]
}

resource "boundary_role" "default_org" {
  name           = "default_org"
  scope_id       = boundary_scope.global.id
  grant_scope_id = boundary_scope.org.id
  grant_strings = [
    "id=${boundary_scope.project.id};actions=read",
    "id={{.User.Id}};actions=read",
    "id=*;type=auth-token;actions=list,read:self,delete:self"
  ]
  principal_ids = [boundary_managed_group.auth0_db_analyst.id, boundary_managed_group.auth0_db_admin.id,
    boundary_managed_group.okta_db_analyst.id, boundary_managed_group.okta_db_admin.id
  ]
}

resource "boundary_role" "default_project" {
  name           = "default_project"
  scope_id       = boundary_scope.org.id
  grant_scope_id = boundary_scope.project.id
  grant_strings = [
    "id=*;type=session;actions=list,no-op",
    "id=*;type=session;actions=read:self,cancel:self",
  ]
  principal_ids = [boundary_managed_group.auth0_db_analyst.id, boundary_managed_group.auth0_db_admin.id,
    boundary_managed_group.okta_db_analyst.id, boundary_managed_group.okta_db_admin.id
  ]
}
