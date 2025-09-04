locals {
  tags = {
    Project     = var.name_prefix
    Environment = var.name_prefix
    ManagedBy   = "Terraform"
  }
}

