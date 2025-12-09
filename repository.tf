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
    for_each = each.value.template_repository != null ? [1] : []
    content {
      owner                = var.organization.name
      repository           = each.value.template_repository
      include_all_branches = true
    }
  }

  lifecycle {
    ignore_changes = [
      template,
    ]
  }
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
