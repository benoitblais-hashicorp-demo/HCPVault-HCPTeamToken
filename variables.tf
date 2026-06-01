variable "github_repository" {
  type        = string
  description = "(Required) The name of the GitHub repository. Used to name the TFE team, Vault role, and lookup the TFE workspace."
}

variable "github_repository_owner" {
  type        = string
  description = "(Required) The owner (user or organization) of the GitHub repository (e.g. benoitblais-hashicorp-demo)."
}

variable "tfe_organization" {
  type        = string
  description = "(Required) The HCP Terraform organization name."
}

variable "tfe_token" {
  type        = string
  description = "(Required) The HCP Terraform / TFE API token used to configure the secrets engine."
  sensitive   = true
}

variable "jwt_backend_path" {
  type        = string
  description = "(Optional) The path where the JWT auth backend will be mounted."
  default     = "jwt"
}

variable "namespace_path" {
  type        = string
  description = "(Optional) The path of the Vault namespace to create for the demo."
  default     = "tfe_demo"
}

variable "tfe_backend_path" {
  type        = string
  description = "(Optional) The path where the Terraform Cloud secrets engine will be mounted."
  default     = "terraform"
}
