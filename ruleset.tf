locals {
  allowed        = false
  disallowed     = true
  all_branches   = "~ALL"
  all_tags       = "~ALL"
  default_branch = "~DEFAULT_BRANCH"
  conventional_branch_patterns = [
    "refs/heads/feat/*",
    "refs/heads/fix/*",
    "refs/heads/build/*",
    "refs/heads/chore/*",
    "refs/heads/ci/*",
    "refs/heads/docs/*",
    "refs/heads/style/*",
    "refs/heads/refactor/*",
    "refs/heads/perf/*",
    "refs/heads/test/*",
  ]
  sem_ver_tag_patterns = [
    "refs/tags/v[0-9]*.[0-9]*.[0-9]*",
    "refs/tags/v[0-9]*.[0-9]*",
    "refs/tags/v[0-9]*",
  ]
}

resource "github_repository_ruleset" "protect_default_branch" {
  for_each = var.repositories

  name        = "Protect default branch"
  repository  = github_repository.this[each.key].name
  target      = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      include = [local.default_branch]
      exclude = []
    }
  }

  rules {
    creation         = local.disallowed # Restrict creations
    update           = local.disallowed
    deletion         = local.disallowed # Restrict deletions
    non_fast_forward = true             # Block force pushes

    pull_request {
      required_approving_review_count   = each.value.rules.default_branch.required_approvals
      require_code_owner_review         = each.value.rules.default_branch.require_code_owner_review
      dismiss_stale_reviews_on_push     = true                                                   # Dismiss stale pull request approvals when new commits are pushed
      require_last_push_approval        = each.value.rules.default_branch.required_approvals > 0 # Require approval of the most recent reviewable push
      required_review_thread_resolution = true                                                   # Require conversation resolution before merging
    }

    dynamic "required_status_checks" {
      for_each = length(each.value.rules.default_branch.required_status_checks) > 0 ? [1] : []

      content {
        strict_required_status_checks_policy = true # Require branches to be up to date before merging

        dynamic "required_check" {
          for_each = each.value.rules.default_branch.required_status_checks

          content {
            context = required_check.key
          }
        }
      }
    }
  }

  dynamic "bypass_actors" {
    for_each = each.value.rules.default_branch.rule_bypass_actors

    content {
      actor_id    = bypass_actors.key
      actor_type  = bypass_actors.value
      bypass_mode = "pull_request"
    }
  }
}

resource "github_repository_ruleset" "sign_all_branches" {
  for_each = { for _name, _repo in var.repositories : _name => _repo if _repo.rules.sign_all_branches }

  name        = "Signed commits on all branches"
  repository  = github_repository.this[each.key].name
  target      = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      include = [local.all_branches]
      exclude = []
    }
  }

  rules {
    creation            = local.allowed
    update              = local.allowed
    deletion            = local.allowed
    required_signatures = true
    non_fast_forward    = false
  }
}

resource "github_repository_ruleset" "enforce_branches_naming" {
  for_each = { for _name, _repo in var.repositories : _name => _repo if _repo.rules.conventional_branch_names || length(_repo.rules.allowed_branch_name_patterns) > 0 }

  name        = "Enforce branch naming"
  repository  = github_repository.this[each.key].name
  target      = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["~ALL"]
      exclude = setunion(
        each.value.rules.conventional_branch_names ? local.conventional_branch_patterns : [],
        each.value.rules.allowed_branch_name_patterns,
      )
    }
  }

  rules {
    creation = local.disallowed
  }
}

resource "github_repository_ruleset" "immutable_tags" {
  for_each = var.repositories

  name        = "Immutable tags"
  repository  = github_repository.this[each.key].name
  target      = "tag"
  enforcement = "active"

  conditions {
    ref_name {
      include = [local.all_tags]
      exclude = []
    }
  }

  rules {
    deletion = local.disallowed
    update   = local.disallowed
  }
}

resource "github_repository_ruleset" "enforce_tag_naming" {
  for_each = { for _name, _repo in var.repositories : _name => _repo if _repo.rules.sem_ver_tags || length(_repo.rules.allowed_tag_patterns) > 0 }

  name        = "Enforce tag naming"
  repository  = github_repository.this[each.key].name
  target      = "tag"
  enforcement = "active"

  conditions {
    ref_name {
      include = [local.all_tags]
      exclude = setunion(
        each.value.rules.sem_ver_tags ? local.sem_ver_tag_patterns : [],
        each.value.rules.allowed_tag_patterns,
      )
    }
  }

  rules {
    creation = local.disallowed
  }
}

resource "github_repository_ruleset" "tag_actors" {
  for_each = { for _name, _repo in var.repositories : _name => _repo if length(_repo.rules.create_tag_actors) > 0 }

  name        = "Create tag actors"
  repository  = github_repository.this[each.key].name
  target      = "tag"
  enforcement = "active"

  conditions {
    ref_name {
      include = setunion(
        each.value.rules.sem_ver_tags ? local.sem_ver_tag_patterns : [],
        each.value.rules.allowed_tag_patterns,
      )
      exclude = []
    }
  }

  rules {
    creation = local.disallowed
  }

  dynamic "bypass_actors" {
    for_each = each.value.rules.create_tag_actors

    content {
      actor_id    = bypass_actors.key
      actor_type  = bypass_actors.value
      bypass_mode = "pull_request"
    }
  }
}
