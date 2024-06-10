resource "boundary_managed_group" "db_admin" {
  name           = "db_admin"
  description    = "DB Admin managed group"
  auth_method_id = boundary_auth_method_oidc.this.id
  filter         = "\"${azuread_group.admin.object_id}\" in \"/token/groups\""
  /* filter         = var.idp_type == "auth0" || var.idp_type == "okta" ? "\"admin\" in \"/userinfo/org-roles\"" : "\"${var.az_ad_group_admin_id}\" in \"/token/groups\"" */
}

resource "boundary_managed_group" "db_analyst" {
  name           = "db_analyst"
  description    = "DB Admin managed group"
  auth_method_id = boundary_auth_method_oidc.this.id
  filter         = "\"${azuread_group.analyst.object_id}\" in \"/token/groups\""
  /* filter         = var.idp_type == "auth0" || var.idp_type == "okta" ? "\"analyst\" in \"/userinfo/org-roles\"" : "\"${var.az_ad_group_analyst_id}\" in \"/token/groups\"" */
}


resource "boundary_role" "default_org" {
  for_each       = var.boundary_resources.scopes
  name           = "default_org_${each.key}"
  scope_id       = var.boundary_resources.global_scope_id
  grant_scope_ids = [var.boundary_resources.orgs[each.key].id]
  grant_strings = [
    "ids=${var.boundary_resources.projects[each.key].id};actions=read",
    "ids={{.User.Id}};actions=read",
    "ids=*;type=auth-token;actions=list,read:self,delete:self"
  ]
  /* principal_ids = local.principal_ids[each.key] */
  principal_ids = [boundary_managed_group.db_analyst.id, boundary_managed_group.db_admin.id]
}


resource "boundary_role" "default_project" {
  for_each       = var.boundary_resources.scopes
  name           = "default_project"
  scope_id       = var.boundary_resources.orgs[each.key].id
  grant_scope_ids = [var.boundary_resources.projects[each.key].id]
  grant_strings = [
    "ids=*;type=session;actions=list,no-op",
    "ids=*;type=session;actions=read:self,cancel:self",
  ]
  /* principal_ids = local.principal_ids[each.key] */
  principal_ids = [boundary_managed_group.db_analyst.id, boundary_managed_group.db_admin.id]
}

resource "local_file" "managed_group_admin_id" {
  content = boundary_managed_group.db_admin.id
  filename = "${path.root}/generated/managed_group_admin_id"
}

resource "local_file" "managed_group_analyst_id" {
  content = boundary_managed_group.db_analyst.id
  filename = "${path.root}/generated/managed_group_analyst_id"
}