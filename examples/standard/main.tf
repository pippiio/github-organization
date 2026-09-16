module "github" {
  source = "github.com/pippiio/github-organization?ref=HEAD"

  organization = {
    billing_email = "hello@pippi.io"
    public_email  = "hello@pippi.io"
    name          = "pippiio"
    display_name  = "Pippi io"
    description   = "Battle tested Terraform modules"
    location      = "Denmark"
    website       = "https://pippi.io"
    twitter       = null
    members       = {}
  }

  teams = {
    pippiio = {
      description = "Maintainers of the pippiio organization"
      members     = {}
    }
  }

  repositories = {
    "github_organization" = {
      description     = "Terraform module for managing a GitHub organization"
      team_permission = { pippiio = "read_write" }
      rules = {
        # Repository admins are always included for default-branch, tag-creation, and .github bypass.
        # Admins respect rule_bypass_mode on the default branch; role lists cannot remove them.
        create_tag_teams        = ["pippiio"]
        dot_github_bypass_teams = ["pippiio"]
        default_branch = {
          rule_bypass_teams = ["pippiio"]
          rule_bypass_mode  = "pull_request"
        }
      }
    }
  }
}
