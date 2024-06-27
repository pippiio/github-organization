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

resource "github_organization_ruleset" "version_tag" {
  name        = "version-tag"
  target      = "tag"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["~ALL"]
      exclude = []
    }
    repository_name {
      include = ["~ALL"]
      exclude = []
    }
  }

  dynamic "bypass_actors" {
    for_each = { for key, team in var.teams : key => team if team.bypass_version_tag }

    content {
      actor_id    = github_team.this[bypass_actors.key].id
      actor_type  = "Team"
      bypass_mode = "always"
    }
  }

  rules {
    creation                = true
    update                  = true
    deletion                = true
    required_linear_history = true
    required_signatures     = true

    tag_name_pattern {
      name     = "Version Tagging"
      negate   = false
      operator = "regex"
      pattern  = "v*"
    }
  }
}
