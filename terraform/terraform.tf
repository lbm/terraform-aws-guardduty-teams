# AWS provider settings are in `terraform-local.tf.example`.
# Copy that file to `terraform-local.tf` and edit as necessary.

terraform {
  required_version = ">= 0.14"

  required_providers {
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.26.0"
    }
  }
}

provider "aws" {
  profile = var.profile
  region  = var.region
}
