terraform {
  backend "s3" {
    bucket         = "anhkt-terraform-state"
    key            = "terraform.tfstate"   
    region         = "ap-northeast-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true

    workspace_key_prefix = "infra"         
  }
}