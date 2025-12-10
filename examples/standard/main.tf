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
    }
  }
}
