terraform {

  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 5.9.0"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.64.0"
    }
  }

  required_version = ">= 1.13.0"

}
