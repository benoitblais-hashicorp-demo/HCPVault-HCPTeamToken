output "jwt_backend_path" {
  description = "The mount path of the JWT auth backend."
  value       = vault_jwt_auth_backend.github.path
}

output "jwt_role_name" {
  description = "The role name for GitHub Actions to authenticate against."
  value       = vault_jwt_auth_backend_role.github_actions.role_name
}

output "namespace_path" {
  description = "The path of the newly created Vault namespace."
  value       = vault_namespace.demo.path
}

output "namespace_path_fq" {
  description = "The fully qualified path of the newly created Vault namespace."
  value       = vault_namespace.demo.path_fq
}

output "tfe_backend_path" {
  description = "The mount path of the TFE secrets engine."
  value       = vault_terraform_cloud_secret_backend.tfe.backend
}

output "tfe_role_name" {
  description = "The name of the Vault role used to fetch dynamic HCP Terraform Team tokens."
  value       = vault_terraform_cloud_secret_role.team_token.name
}

output "tfe_team_id" {
  description = "The ID of the generated TFE Team."
  value       = tfe_team.workflow.id
}
