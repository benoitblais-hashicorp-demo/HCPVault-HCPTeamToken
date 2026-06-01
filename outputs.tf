output "jwt_backend_path" {
  description = "The mount path of the JWT auth backend."
  value       = var.github_repository_owner != "" ? vault_jwt_auth_backend.github[0].path : ""
}

output "jwt_role_name" {
  description = "The role name for GitHub Actions to authenticate against."
  value       = var.github_repository != "" && var.github_repository_owner != "" && var.tfe_token != "" && var.tfe_organization != "" ? vault_jwt_auth_backend_role.github_actions[0].role_name : ""
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
  value       = var.tfe_token != "" ? vault_terraform_cloud_secret_backend.tfe[0].backend : ""
}

output "tfe_role_name" {
  description = "The name of the Vault role used to fetch dynamic HCP Terraform Team tokens."
  value       = var.tfe_token != "" && var.github_repository != "" && var.tfe_organization != "" ? vault_terraform_cloud_secret_role.team_token[0].name : ""
}

output "tfe_team_id" {
  description = "The ID of the generated TFE Team."
  value       = var.github_repository != "" && var.tfe_organization != "" ? tfe_team.workflow[0].id : ""
}
