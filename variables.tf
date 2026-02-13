variable "organization" {
  type = object({
    billing_email   = string
    name            = string
    display_name    = string
    description     = string
    public_email    = string
    location        = string
    website         = string
    enable_scanning = optional(bool, false)
    enable_pages    = optional(bool, false)
    members         = map(string)
  })
  description = <<-EOL
    GitHub organization configuration:

    billing_email   : The billing email address for the organization
    name            : The GitHub name for the organization
    display_name    : Organization display name
    description     : An organization description
    public_email    : Organization e-mail (will be public)
    location        : The organization location or country
    website         : The company website
    enable_scanning : Enable GitHub managed code security scanning
    enable_pages    : Wether to enable GitHub pages on organization level
    members         : A list of GitHub usernames to join organization as members
  EOL
}

variable "teams" {
  type = map(object({
    description        = string
    code_review_count  = optional(number, 1)
    code_review_notify = optional(bool, true)
    members            = map(string)
  }))
  description = <<-EOL
    A map of GitHub team configuration to be added to the organization:

    Key   : Name of team
    Value :
      description        : Team description
      code_review_count  : The number of team members to assign to a pull request
      code_review_notify : Whether to notify the entire team when at least one member is also assigned to the pull request
      members            : A map of members to join the team
        Key   : member's GitHub username
        Value : member role in team
  EOL
}

variable "repositories" {
  type = map(object({
    description             = string
    visibility              = optional(string, "private")
    homepage                = optional(string)
    enable_projects         = optional(bool, false)
    enable_wiki             = optional(bool, false)
    enable_issues           = optional(bool, false)
    enable_discussions      = optional(bool, false)
    allow_merge_commit      = optional(bool, false)
    allow_squash_merge      = optional(bool, true)
    allow_rebase_merge      = optional(bool, false)
    delete_branch_on_merge  = optional(bool, true)
    team_permission         = map(string)
    collaborator_permission = optional(map(bool), {})
    template_repository     = optional(string)
    is_template             = optional(bool, false)
    topics                  = optional(list(string), [])
    environments = optional(map(map(object({
      description = string
      value       = string
      sensitive   = bool
    }))), {})
    rules = optional(object({
      default_branch = optional(object({
        required_approvals        = optional(number, 1)
        require_code_owner_review = optional(bool, false)
        required_status_checks    = optional(set(string), [])
        rule_bypass_actors        = optional(map(string), {})
      }), {})
      sign_all_branches            = optional(bool, true)
      conventional_branch_names    = optional(bool, true)
      allowed_branch_name_patterns = optional(set(string), [])
      imutable_tags                = optional(bool, true)
      sem_ver_tags                 = optional(bool, true)
      allowed_tag_patterns         = optional(set(string), [])
      create_tag_actors            = optional(map(string), {})
    }), {})
  }))
  description = <<-EOL
    A map of GitHub repositories in the organization.

    Key   : The name of the repository
    Value :
      description                : A description of the repository
      visibility                 : Can be `public` or `private`. Defaults to private
      homepage                   : URL of a page describing the project
      enable_projects            : Set to true to enable the GitHub Projects features on the repository
      enable_wiki                : Set to true to enable the GitHub Wiki features on the repository
      enable_issues              : Set to true to enable the GitHub Issues features on the repository
      enable_discussions         : Set to true to enable the GitHub Discussions features on the repository
      allow_merge_commit         : Set to true to enable merge commits on the repository
      allow_squash_merge         : Set to false to disable squash merges on the repository
      allow_rebase_merge         : Set to true to enable rebase merges on the repository
      delete_branch_on_merge     : Set to false to disable automatically deletion of head branch after a pull request is merged
      team_permission            : A map of GitHub organization teams to grant access
        Key   : The name of GitHub them team
        Value : Set to 'read_write' to grant write access and 'read' to grant read-only access
      collaborator_permission    : A map of GitHub collaborators to grant access
        Key   : The collaborator's GitHub username
        Value : Set to true to grant write access and false to grant read-only access
      template_repository        : The name of the template repository. This must be loctaed within the same organization.
      is_template                : Wether the repository is enabled as template repository.
      topics                     : The list of topics of the repository.
      environments               : A map of actions environments
        Key   : The name of the actions environment   
        Value : A map of env vars and secrets within the action environment
          Key   : The name of the env var or secret
          Value :
            description : A description of the env var
            value       : The value of the env var or secret
            sensitive   : Wether the value if sensitive and should be treated as a secret
      rules                          : Configuration of repository rulesets
        default_branch : Ruleset protecting default branch
          required_approvals        : Required number of approvals to satisfy default branch protection requirements
          require_code_owner_review : Require an approved review in pull requests including files with a designated code owner
          required_status_checks    : The list of status checks to require in order to merge into main branch
          rule_bypass_actors.       : A map of actors that may bypass default branch rulesets on pull requests. Key is actor id, Value actor type.
        sign_all_branches            : Set to true to require signed commits on all branches
        conventional_branch_names    : Set to true to allow conventional commits branch naming
        allowed_branch_name_patterns : A set of string patterns defining allowed branch naming
        imutable_tags                : Set to true to deny changing tags
        sem_ver_tags                 : Set to true to allow semantic version tags
        allowed_tag_patterns         : A set of string patterns defining allowed tag naming
        create_tag_actors            : A map of actors that may create tags. Key is actor id, Value actor type.
  EOL
}

variable "hosted_runner_groups" {
  type = map(object({
    repositories           = optional(set(string), [])
    allow_all_repositories = bool
  }))
  default     = {}
  description = <<-EOL
    A map of GitHub hosted runner groups to be added to the organization:

    Key   : Name of runner group
    Value :
      description  : Runner group description
      repositories : An optional set of repository names to limit the runner group access. If not provided, the runner group will have access to all repositories in the organization.
  EOL
}
