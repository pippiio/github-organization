resource "github_actions_runner_group" "this" {
  for_each = var.hosted_runner_groups

  name                    = each.key
  visibility              = each.value.allow_all_repositories ? "all" : "selected"
  selected_repository_ids = [for repo_name in each.value.repositories : github_repository.this[repo_name].repo_id]
}

data "github_actions_organization_registration_token" "this" {
}

