# ------------------------------------------------------------------------------
# Child Namespace
# ------------------------------------------------------------------------------

resource "vault_namespace" "demo" {
  path = var.namespace_path
}

# ------------------------------------------------------------------------------
# Terraform Cloud / Enterprise Secrets Engine
# ------------------------------------------------------------------------------

resource "vault_terraform_cloud_secret_backend" "tfe" {
  count       = var.tfe_token != "" ? 1 : 0
  namespace   = vault_namespace.demo.path_fq
  backend     = var.tfe_backend_path
  description = "TFE secrets engine to manage HCP Terraform Team tokens dynamically"
  token       = var.tfe_token
}

# ------------------------------------------------------------------------------
# HCP Terraform Team & Workspace Access
# ------------------------------------------------------------------------------

resource "tfe_team" "workflow" {
  count        = var.github_repository != "" && var.tfe_organization != "" ? 1 : 0
  name         = var.github_repository
  organization = var.tfe_organization
  visibility   = "secret"
}

data "tfe_workspace" "target" {
  count        = var.github_repository != "" && var.tfe_organization != "" ? 1 : 0
  name         = var.github_repository
  organization = var.tfe_organization
}

resource "tfe_team_access" "workflow" {
  count        = var.github_repository != "" && var.tfe_organization != "" ? 1 : 0
  team_id      = tfe_team.workflow[0].id
  workspace_id = data.tfe_workspace.target[0].id
  access       = "write"
}

# ------------------------------------------------------------------------------
# Terraform Cloud / Enterprise Secret Role
# ------------------------------------------------------------------------------

resource "vault_terraform_cloud_secret_role" "team_token" {
  count        = var.tfe_token != "" && var.github_repository != "" && var.tfe_organization != "" ? 1 : 0
  namespace    = vault_namespace.demo.path_fq
  backend      = vault_terraform_cloud_secret_backend.tfe[0].backend
  name         = lower(var.github_repository)
  organization = var.tfe_organization
  team_id      = tfe_team.workflow[0].id
}

# ------------------------------------------------------------------------------
# Vault Policy for GitHub Actions
# ------------------------------------------------------------------------------

resource "vault_policy" "github_actions" {
  count     = var.github_repository != "" && var.tfe_token != "" && var.tfe_organization != "" ? 1 : 0
  namespace = vault_namespace.demo.path_fq
  name      = "github-actions-${lower(var.github_repository)}"
  policy    = <<EOTT
path "${vault_terraform_cloud_secret_backend.tfe[0].backend}/creds/${vault_terraform_cloud_secret_role.team_token[0].name}" {
  capabilities = ["read"]
}
EOTT
}

# ------------------------------------------------------------------------------
# JWT Auth Backend & Role
# ------------------------------------------------------------------------------

resource "vault_jwt_auth_backend" "github" {
  count              = var.github_repository_owner != "" ? 1 : 0
  namespace          = vault_namespace.demo.path_fq
  path               = var.jwt_backend_path
  type               = "jwt"
  oidc_discovery_url = "https://token.actions.githubusercontent.com"
  bound_issuer       = "https://token.actions.githubusercontent.com"
}

resource "vault_jwt_auth_backend_role" "github_actions" {
  count           = var.github_repository != "" && var.github_repository_owner != "" && var.tfe_token != "" && var.tfe_organization != "" ? 1 : 0
  namespace       = vault_namespace.demo.path_fq
  backend         = vault_jwt_auth_backend.github[0].path
  role_name       = lower(var.github_repository)
  role_type       = "jwt"
  bound_audiences = ["vault.workload.identity"]
  token_policies  = [vault_policy.github_actions[0].name]

  bound_claims = {
    repository = "${var.github_repository_owner}/${var.github_repository}"
  }

  user_claim = "repository"
}
