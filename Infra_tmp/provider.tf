terraform {
  required_version = ">= 1.1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }


}

# Use fixed region and profile as requested
provider "aws" {
  region  = var.aws_region      
  profile = "AnhKT4"            # AWS profile configured locally
}
