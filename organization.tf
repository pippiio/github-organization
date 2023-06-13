resource "github_organization_settings" "this" {
  billing_email = var.organization.billing_email
  email         = var.organization.public_email
  company       = var.organization.name
  name          = var.organization.display_name
  description   = var.organization.description
  location      = var.organization.location
  blog          = var.organization.website

  has_organization_projects                                = true
  has_repository_projects                                  = true
  default_repository_permission                            = "none"
  web_commit_signoff_required                              = true
  members_can_create_repositories                          = false
  members_can_create_public_repositories                   = false
  members_can_create_private_repositories                  = false
  members_can_create_internal_repositories                 = false
  members_can_create_pages                                 = var.organization.enable_pages
  members_can_create_public_pages                          = var.organization.enable_pages
  members_can_create_private_pages                         = var.organization.enable_pages
  members_can_fork_private_repositories                    = false
  dependabot_alerts_enabled_for_new_repositories           = var.organization.enable_scanning
  dependabot_security_updates_enabled_for_new_repositories = var.organization.enable_scanning
  dependency_graph_enabled_for_new_repositories            = var.organization.enable_scanning
  secret_scanning_enabled_for_new_repositories             = var.organization.enable_scanning
}

resource "github_membership" "this" {
  for_each = var.organization.members

  username = each.key
  role     = each.value
}
