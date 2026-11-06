# ==============================================================================
# Environment: Production - Remote State Configuration
# ==============================================================================
# Production Best Practice:
# In real-world enterprise deployments, Terraform state is stored securely in an
# S3 bucket with server-side encryption and versioning, with state locking handled
# by DynamoDB to prevent concurrent modifications.
#
# To enable S3 remote state:
# 1. Ensure the S3 bucket and DynamoDB table exist in eu-west-1.
# 2. Uncomment the backend block below.
# 3. Run: terraform init -reconfigure

# terraform {
#   backend "s3" {
#     bucket         = "payflow-terraform-state-prod-eu-west-1"
#     key            = "networking/vpc-payflow-prod/terraform.tfstate"
#     region         = "eu-west-1"
#     encrypt        = true
#     dynamodb_table = "payflow-terraform-locks-prod"
#   }
# }

