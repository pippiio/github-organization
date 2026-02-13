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

output "runner_groups" {
  description = "Runner group object with token, expiration and group ids."
  value = {
    token = sensitive(data.github_actions_organization_registration_token.this.token)
    expiration = formatdate(
      "YYYY-MM-DD'T'hh:mm:ssZ",
      timeadd("1970-01-01T00:00:00Z", "${data.github_actions_organization_registration_token.this.expires_at}s")
    )
    groups = { for group in github_actions_runner_group.this : group.name => group.id }
  }
}
