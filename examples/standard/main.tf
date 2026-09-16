module "github" {
  source = "github.com/pippiio/github-organization?ref=HEAD"

  organization = {
    billing_email = "hello@pippi.io"
    public_email  = "pippi@techchapter.com"
    name          = "pippiio"
    display_name  = "Pippi io"
    description   = "Battle tested Terraform modules"
    location      = "Denmark"
    website       = "https://pippi.io"
    twitter       = null
    members       = {}
  }

  teams = {
    techchapter = {
      description = "Maintainers of pippiio organization from TechChapter"
      members     = {}
    }
  }

  repositories = {
    "github_organization" = {
      description     = "Terraform module for managing a GitHub organization"
      team_permission = { techchapter = "read_write" }
      rules = {
        # Repository admins are always included for default-branch, tag-creation, and .github bypass.
        # Admins respect rule_bypass_mode on the default branch; role lists cannot remove them.
        create_tag_teams        = ["techchapter"]
        dot_github_bypass_teams = ["techchapter"]
        default_branch = {
          rule_bypass_teams = ["techchapter"]
          rule_bypass_mode  = "pull_request"
        }
      }
    }
  }
}
