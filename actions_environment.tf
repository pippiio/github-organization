locals {
  repo_env = { for entry in flatten([
    for name, repository in var.repositories : [
      for environment in repository.environments : [
        for key, variable in var.environments[environment].variables : {
          key         = key
          value       = variable.value
          sensitive   = variable.sensitive
          repository  = name
          environment = try(var.environments[environment].name, environment)
  }]]]) : "${entry.repository}/${entry.environment}/${entry.key}" => entry }
}

resource "github_repository_environment" "this" {
  for_each = { for entry in flatten([for name, repository in var.repositories : [
    for environment in repository.environments : {
      repository  = name
      environment = try(var.environments[environment].name, environment)
  }]]) : "${entry.repository}/${entry.environment}" => entry }

  environment = each.value.environment
  repository  = github_repository.this[each.value.repository].name
}

resource "github_actions_environment_secret" "this" {
  for_each = { for key, envvar in local.repo_env : key => envvar if envvar.sensitive }

  depends_on = [
    github_repository_environment.this
  ]

  repository      = github_repository.this[each.value.repository].name
  environment     = each.value.environment
  secret_name     = each.value.key
  plaintext_value = each.value.value
}

resource "github_actions_environment_variable" "this" {
  for_each = { for key, envvar in local.repo_env : key => envvar if envvar.sensitive == false }

  depends_on = [
    github_repository_environment.this
  ]

  repository    = github_repository.this[each.value.repository].name
  environment   = each.value.environment
  variable_name = each.value.key
  value         = each.value.value
}
