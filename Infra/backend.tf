# terraform {
#   backend "s3" {
#     bucket         = "my-terraform-states"
#     key            = "ecs-fargate/dev/terraform.tfstate"
#     region         = "ap-southeast-1"
#     dynamodb_table = "terraform-locks"
#   }
# }
