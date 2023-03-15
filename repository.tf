resource "github_repository" "this" {
  for_each = var.repositories

  name                   = each.key
  description            = each.value.description
  visibility             = each.value.visibility
  homepage_url           = each.value.homepage
  has_issues             = each.value.enable_issues
  has_projects           = each.value.enable_projects
  has_wiki               = each.value.enable_wiki
  allow_merge_commit     = each.value.allow_merge_commit
  allow_squash_merge     = each.value.allow_squash_merge
  allow_rebase_merge     = each.value.allow_rebase_merge
  delete_branch_on_merge = each.value.delete_branch_on_merge
  auto_init              = true
  archive_on_destroy     = false

  # topics - (Optional) The list of topics of the repository.
  # template - (Optional) Use a template repository to create this resource. See Template Repositories below for details.
  # vulnerability_alerts = var.config.enable_scanning
}

resource "github_branch_protection" "main" {
  for_each = var.repositories

  repository_id                   = github_repository.this[each.key].node_id
  pattern                         = "main"
  enforce_admins                  = true
  allows_deletions                = false
  require_signed_commits          = true
  require_conversation_resolution = true

  required_pull_request_reviews {
    required_approving_review_count = each.value.required_approvals
    require_code_owner_reviews      = each.value.require_code_owner_reviews
    dismiss_stale_reviews           = true
    require_last_push_approval      = true
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
  enforce_admins         = true
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
  permission = each.value.permission ? "push" : "pull"
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