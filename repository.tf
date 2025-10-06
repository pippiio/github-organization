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

resource "github_repository_ruleset" "default" {
  for_each = var.repositories

  name        = format("%s-%s", each.key, github_repository.this[each.key].default_branch)
  repository  = github_repository.this[each.key].name
  target      = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["~DEFAULT_BRANCH"]
      exclude = []
    }
  }

  rules {
    creation            = true  # restrict creation of default branch
    update              = false # allows PR merges on default branch
    deletion            = true  # restrict deletion of default branch
    required_signatures = true  # require signatures on default branch

    pull_request {
      required_approving_review_count   = each.value.required_approvals
      require_code_owner_review         = each.value.require_code_owner_reviews
      dismiss_stale_reviews_on_push     = true
      require_last_push_approval        = each.value.required_approvals > 0
      required_review_thread_resolution = true
    }
  }
}

resource "github_repository_ruleset" "all" {
  for_each = var.repositories

  name        = format("%s-%s", each.key, "all")
  repository  = github_repository.this[each.key].name
  target      = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["~ALL"]
      exclude = []
    }
  }

  rules {
    creation            = false # do not restrict creation 
    update              = false
    deletion            = false
    required_signatures = true
    non_fast_forward    = false
  }
}

resource "github_repository_ruleset" "tags" {
  for_each = var.repositories

  name        = format("%s-%s", each.key, "tags")
  repository  = github_repository.this[each.key].name
  target      = "tag"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["~ALL"]
      exclude = []
    }
  }

  rules {
    tag_name_pattern {
      operator = "starts_with"
      pattern  = "^v?\\d+(?:\\.\\d+){2,}[a-z]*$"
      name     = "SemVer Tagging"
    }
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
