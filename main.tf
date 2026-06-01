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
  namespace   = vault_namespace.demo.path_fq
  backend     = var.tfe_backend_path
  description = "TFE secrets engine to manage HCP Terraform Team tokens dynamically"
  token       = var.tfe_token
}

# ------------------------------------------------------------------------------
# HCP Terraform Team & Workspace Access
# ------------------------------------------------------------------------------

resource "tfe_team" "workflow" {
  name         = var.github_repository
  organization = var.tfe_organization
  visibility   = "secret"
}

data "tfe_workspace" "target" {
  name         = var.github_repository
  organization = var.tfe_organization
}

resource "tfe_team_access" "workflow" {
  team_id      = tfe_team.workflow.id
  workspace_id = data.tfe_workspace.target.id
  access       = "write"
}

# ------------------------------------------------------------------------------
# Terraform Cloud / Enterprise Secret Role
# ------------------------------------------------------------------------------

resource "vault_terraform_cloud_secret_role" "team_token" {
  namespace    = vault_namespace.demo.path_fq
  backend      = vault_terraform_cloud_secret_backend.tfe.backend
  name         = var.github_repository
  organization = var.tfe_organization
  team_id      = tfe_team.workflow.id
}

# ------------------------------------------------------------------------------
# Vault Policy for GitHub Actions
# ------------------------------------------------------------------------------

resource "vault_policy" "github_actions" {
  namespace = vault_namespace.demo.path_fq
  name      = "github-actions-${var.github_repository}"
  policy    = <<EOT
path "${vault_terraform_cloud_secret_backend.tfe.backend}/creds/${vault_terraform_cloud_secret_role.team_token.name}" {
  capabilities = ["read"]
}
EOT
}

# ------------------------------------------------------------------------------
# JWT Auth Backend & Role
# ------------------------------------------------------------------------------

resource "vault_jwt_auth_backend" "github" {
  namespace          = vault_namespace.demo.path_fq
  path               = var.jwt_backend_path
  type               = "jwt"
  oidc_discovery_url = "https://token.actions.githubusercontent.com"
  bound_issuer       = "https://token.actions.githubusercontent.com"
}

resource "vault_jwt_auth_backend_role" "github_actions" {
  namespace      = vault_namespace.demo.path_fq
  backend        = vault_jwt_auth_backend.github.path
  role_name      = var.github_repository
  role_type      = "jwt"
  token_policies = [vault_policy.github_actions.name]

  bound_claims = {
    repository = "${var.github_repository_owner}/${var.github_repository}"
  }

  user_claim = "repository"
}
