##############################################
# Terraform + AWS provider - be.tf           #
##############################################

terraform {
  required_version = ">= 1.1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  # Local state for now (S3 backend can be enabled later)
  # backend "s3" {}
}

# Use fixed region and profile as requested
provider "aws" {
  region  = var.aws_region       # e.g., ap-northeast-1
  profile = "AnhKT4"            # AWS profile configured locally
}
