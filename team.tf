resource "github_team" "this" {
  for_each = var.teams
  provider = github

  name        = each.key
  description = each.value.description
  privacy     = "closed"
}

resource "github_team_settings" "this" {
  for_each = var.teams

  team_id = github_team.this[each.key].id
  review_request_delegation {
    algorithm    = "ROUND_ROBIN"
    member_count = each.value.code_review_count
    notify       = each.value.code_review_notify
  }
}

resource "github_team_membership" "this" {
  for_each = { for entry in flatten([
    for team_key, team in var.teams : [
      for member, role in team.members : {
        key    = "${team_key}/${member}"
        team   = team_key
        member = member
        role   = role
  }]]) : entry.key => entry }

  team_id  = github_team.this[each.value.team].id
  username = each.value.member
  role     = each.value.role
}
