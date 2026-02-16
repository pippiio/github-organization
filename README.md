<!-- BEGIN_TF_DOCS -->
# github\_organization
The _github-organization_ is a generic [Terraform](https://www.terraform.io/) module within the [pippi.io](https://pippi.io) family, maintained by [Tech Chapter](https://techchapter.com/). The pippi.io modules are build to support common use cases often seen at Tech Chapters clients. They are created with best practices in mind and battle tested at scale. All modules are free and open-source under the Apache License 2.0.

The github-organization module is made to provision and manage a [GitHub](https://www.github.com/) organization in common scenarious often seen at Tech Chapters clients. This includes, creating repositories, secrets, and more.

# Examples

```hcl
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
```

## Requirements

| Name | Version |
|------|---------|
| terraform | ~>1.14 |
| github | ~>6.9 |

## Providers

| Name | Version |
|------|---------|
| github | ~>6.9 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| organization | GitHub organization configuration:<br/><br/>billing\_email   : The billing email address for the organization<br/>name            : The GitHub name for the organization<br/>display\_name    : Organization display name<br/>description     : An organization description<br/>public\_email    : Organization e-mail (will be public)<br/>location        : The organization location or country<br/>website         : The company website<br/>enable\_scanning : Enable GitHub managed code security scanning<br/>enable\_pages    : Wether to enable GitHub pages on organization level<br/>members         : A list of GitHub usernames to join organization as members | <pre>object({<br/>    billing_email   = string<br/>    name            = string<br/>    display_name    = string<br/>    description     = string<br/>    public_email    = string<br/>    location        = string<br/>    website         = string<br/>    enable_scanning = optional(bool, false)<br/>    enable_pages    = optional(bool, false)<br/>    members         = map(string)<br/>  })</pre> | n/a | yes |
| repositories | A map of GitHub repositories in the organization.<br/><br/>Key   : The name of the repository<br/>Value :<br/>  description                : A description of the repository<br/>  visibility                 : Can be `public` or `private`. Defaults to private<br/>  homepage                   : URL of a page describing the project<br/>  enable\_projects            : Set to true to enable the GitHub Projects features on the repository<br/>  enable\_wiki                : Set to true to enable the GitHub Wiki features on the repository<br/>  enable\_issues              : Set to true to enable the GitHub Issues features on the repository<br/>  enable\_discussions         : Set to true to enable the GitHub Discussions features on the repository<br/>  allow\_merge\_commit         : Set to true to enable merge commits on the repository<br/>  allow\_squash\_merge         : Set to false to disable squash merges on the repository<br/>  allow\_rebase\_merge         : Set to true to enable rebase merges on the repository<br/>  delete\_branch\_on\_merge     : Set to false to disable automatically deletion of head branch after a pull request is merged<br/>  team\_permission            : A map of GitHub organization teams to grant access<br/>    Key   : The name of GitHub them team<br/>    Value : Set to 'read\_write' to grant write access and 'read' to grant read-only access<br/>  collaborator\_permission    : A map of GitHub collaborators to grant access<br/>    Key   : The collaborator's GitHub username<br/>    Value : Set to true to grant write access and false to grant read-only access<br/>  template\_repository        : The name of the template repository. This must be loctaed within the same organization.<br/>  is\_template                : Wether the repository is enabled as template repository.<br/>  topics                     : The list of topics of the repository.<br/>  environments               : A map of actions environments<br/>    Key   : The name of the actions environment <br/>    Value : A map of env vars and secrets within the action environment<br/>      Key   : The name of the env var or secret<br/>      Value :<br/>        description : A description of the env var<br/>        value       : The value of the env var or secret<br/>        sensitive   : Wether the value if sensitive and should be treated as a secret<br/>  rules                          : Configuration of repository rulesets<br/>    default\_branch : Ruleset protecting default branch<br/>      required\_approvals        : Required number of approvals to satisfy default branch protection requirements<br/>      require\_code\_owner\_review : Require an approved review in pull requests including files with a designated code owner<br/>      required\_status\_checks    : The list of status checks to require in order to merge into main branch<br/>      rule\_bypass\_actors.       : A map of actors that may bypass default branch rulesets on pull requests. Key is actor id, Value actor type.<br/>    sign\_all\_branches            : Set to true to require signed commits on all branches<br/>    conventional\_branch\_names    : Set to true to allow conventional commits branch naming<br/>    allowed\_branch\_name\_patterns : A set of string patterns defining allowed branch naming<br/>    imutable\_tags                : Set to true to deny changing tags<br/>    sem\_ver\_tags                 : Set to true to allow semantic version tags<br/>    allowed\_tag\_patterns         : A set of string patterns defining allowed tag naming<br/>    create\_tag\_actors            : A map of actors that may create tags. Key is actor id, Value actor type.<br/>    dot\_github\_actors            : A map of actors that may push to .github folder. | <pre>map(object({<br/>    description             = string<br/>    visibility              = optional(string, "private")<br/>    homepage                = optional(string)<br/>    enable_projects         = optional(bool, false)<br/>    enable_wiki             = optional(bool, false)<br/>    enable_issues           = optional(bool, false)<br/>    enable_discussions      = optional(bool, false)<br/>    allow_merge_commit      = optional(bool, false)<br/>    allow_squash_merge      = optional(bool, true)<br/>    allow_rebase_merge      = optional(bool, false)<br/>    delete_branch_on_merge  = optional(bool, true)<br/>    team_permission         = map(string)<br/>    collaborator_permission = optional(map(bool), {})<br/>    template_repository     = optional(string)<br/>    is_template             = optional(bool, false)<br/>    topics                  = optional(list(string), [])<br/>    environments = optional(map(map(object({<br/>      description = string<br/>      value       = string<br/>      sensitive   = bool<br/>    }))), {})<br/>    rules = optional(object({<br/>      default_branch = optional(object({<br/>        required_approvals        = optional(number, 1)<br/>        require_code_owner_review = optional(bool, false)<br/>        required_status_checks    = optional(set(string), [])<br/>        rule_bypass_actors        = optional(map(string), {})<br/>      }), {})<br/>      sign_all_branches            = optional(bool, true)<br/>      conventional_branch_names    = optional(bool, true)<br/>      allowed_branch_name_patterns = optional(set(string), [])<br/>      imutable_tags                = optional(bool, true)<br/>      sem_ver_tags                 = optional(bool, true)<br/>      allowed_tag_patterns         = optional(set(string), [])<br/>      create_tag_actors            = optional(map(string), {})<br/>      dot_github_actors            = optional(map(string), {})<br/>    }), {})<br/>  }))</pre> | n/a | yes |
| teams | A map of GitHub team configuration to be added to the organization:<br/><br/>Key   : Name of team<br/>Value :<br/>  description        : Team description<br/>  code\_review\_count  : The number of team members to assign to a pull request<br/>  code\_review\_notify : Whether to notify the entire team when at least one member is also assigned to the pull request<br/>  members            : A map of members to join the team<br/>    Key   : member's GitHub username<br/>    Value : member role in team | <pre>map(object({<br/>    description        = string<br/>    code_review_count  = optional(number, 1)<br/>    code_review_notify = optional(bool, true)<br/>    members            = map(string)<br/>  }))</pre> | n/a | yes |
| hosted\_runner\_groups | A map of GitHub hosted runner groups to be added to the organization:<br/><br/>Key   : Name of runner group<br/>Value :<br/>  description  : Runner group description<br/>  repositories : An optional set of repository names to limit the runner group access. If not provided, the runner group will have access to all repositories in the organization. | <pre>map(object({<br/>    repositories           = optional(set(string), [])<br/>    allow_all_repositories = bool<br/>  }))</pre> | `{}` | no |



## Resources

| Name | Type |
|------|------|
| [github_actions_environment_secret.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_environment_secret) | resource |
| [github_actions_environment_variable.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_environment_variable) | resource |
| [github_actions_runner_group.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_runner_group) | resource |
| [github_membership.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/membership) | resource |
| [github_organization_settings.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/organization_settings) | resource |
| [github_repository.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository) | resource |
| [github_repository_collaborator.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_collaborator) | resource |
| [github_repository_environment.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_environment) | resource |
| [github_repository_ruleset.enforce_branches_naming](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_ruleset) | resource |
| [github_repository_ruleset.enforce_tag_naming](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_ruleset) | resource |
| [github_repository_ruleset.immutable_tags](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_ruleset) | resource |
| [github_repository_ruleset.protect_default_branch](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_ruleset) | resource |
| [github_repository_ruleset.protect_dot_github](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_ruleset) | resource |
| [github_repository_ruleset.sensitive_files](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_ruleset) | resource |
| [github_repository_ruleset.sign_all_branches](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_ruleset) | resource |
| [github_repository_ruleset.tag_actors](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_ruleset) | resource |
| [github_team.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/team) | resource |
| [github_team_membership.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/team_membership) | resource |
| [github_team_repository.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/team_repository) | resource |
| [github_team_settings.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/team_settings) | resource |
| [github_actions_organization_registration_token.this](https://registry.terraform.io/providers/integrations/github/latest/docs/data-sources/actions_organization_registration_token) | data source |

## Outputs

| Name | Description |
|------|-------------|
| github\_actions\_organization\_registration\_token | A GitHub Actions runner registration token for the organization. |
| github\_actions\_organization\_registration\_token\_expiration | The expiration date of the GitHub Actions organization registration token. |
| github\_actions\_runner\_group | A map of GitHub Actions runner groups in the organization. |
| members | A map of GitHub organization members. |
| repositories | A map of organization repositories |
| teams | A map of GitHub organization teams including memberpriviledges. |

<!-- END_TF_DOCS -->