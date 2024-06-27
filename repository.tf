resource "github_repository" "this" {
  for_each = var.repositories

  name                        = each.key
  description                 = each.value.description
  visibility                  = each.value.visibility
  homepage_url                = each.value.homepage
  has_issues                  = each.value.enable_issues
  has_projects                = each.value.enable_projects
  has_wiki                    = each.value.enable_wiki
  has_discussions             = each.value.enable_discussions
  allow_merge_commit          = each.value.allow_merge_commit
  allow_squash_merge          = each.value.allow_squash_merge
  allow_rebase_merge          = each.value.allow_rebase_merge
  delete_branch_on_merge      = each.value.delete_branch_on_merge
  auto_init                   = true
  archive_on_destroy          = false
  topics                      = each.value.topics
  vulnerability_alerts        = var.organization.enable_scanning
  is_template                 = each.value.is_template
  web_commit_signoff_required = true

  dynamic "template" {
    for_each = each.value.template != null ? [1] : []
    content {
      owner                = var.organization.name
      repository           = each.value.template
      include_all_branches = true
    }
  }
}

resource "github_branch_protection" "main" {
  for_each = var.repositories

  repository_id                   = github_repository.this[each.key].node_id
  pattern                         = "main"
  enforce_admins                  = !each.value.allow_bypass_protection
  allows_deletions                = false
  require_signed_commits          = true
  require_conversation_resolution = true

  required_pull_request_reviews {
    required_approving_review_count = each.value.required_approvals
    require_code_owner_reviews      = each.value.require_code_owner_reviews
    dismiss_stale_reviews           = true
    require_last_push_approval      = each.value.required_approvals > 0
  }

  required_status_checks {
    strict   = true
    contexts = each.value.required_status_checks
  }
}

resource "github_branch_protection" "all" {
  for_each = var.repositories

  repository_id          = github_repository.this[each.key].node_id
  pattern                = "*"
  enforce_admins         = !each.value.allow_bypass_protection
  allows_deletions       = true
  allows_force_pushes    = true
  require_signed_commits = true
}

resource "github_team_repository" "this" {
  for_each = { for entry in flatten([for repo_key, repo in var.repositories : [
    for team, permission in repo.team_permission : {
      key        = "${repo_key}/${team}"
      repo       = repo_key
      team       = team
      permission = permission
  }]]) : entry.key => entry }

  repository = github_repository.this[each.value.repo].name
  team_id    = github_team.this[each.value.team].id
  permission = each.value.permission == "read_write" ? "push" : "pull"
}

resource "github_repository_collaborator" "this" {
  for_each = { for entry in flatten([for repo_key, repo in var.repositories : [
    for collaborator, permission in repo.collaborator_permission : {
      key          = "${repo_key}/${collaborator}"
      repo         = repo_key
      collaborator = collaborator
      permission   = permission
  }]]) : entry.key => entry }

  repository = github_repository.this[each.value.repo].name
  username   = each.value.collaborator
  permission = each.value.permission ? "push" : "pull"
}
