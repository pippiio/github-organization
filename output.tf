output "members" {
  description = "A map of GitHub organization members."
  value       = { for membership in values(github_membership.this) : membership.username => membership.role }
}

output "teams" {
  description = "A map of GitHub organization teams including memberpriviledges."
  value = { for name, team in github_team.this : name => {
    members = { for membership in values(github_team_membership.this) : membership.username => membership.role if membership.team_id == team.id }
  } }
}

output "repositories" {
  description = "A map of organization repositories"
  value = { for repo in values(github_repository.this) : repo.name => {
    name          = repo.name
    description   = repo.description
    visibility    = repo.visibility
    clone_url     = repo.ssh_clone_url
    teams         = { for team in values(github_team_repository.this) : one([for entry in values(github_team.this) : entry.name if entry.id == team.team_id]) => team.permission if team.repository == repo.name }
    collaborators = { for collaborator in values(github_repository_collaborator.this) : collaborator.username => collaborator.permission if collaborator.repository == repo.name }
  } }
}

output "github_actions_organization_registration_token" {
  description = "A GitHub Actions runner registration token for the organization."
  value       = data.github_actions_organization_registration_token.this.token
  sensitive   = true
}

output "github_actions_organization_registration_token_expiration" {
  description = "The expiration date of the GitHub Actions organization registration token."
  value       = data.github_actions_organization_registration_token.this.expires_at
}

output "github_actions_runner_group" {
  description = "A map of GitHub Actions runner groups in the organization."
  value       = { for group in github_actions_runner_group.this : group.name => group.id }
}
