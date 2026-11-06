# ==============================================================================
# Environment: Production - AWS Provider & Global Resource Attribution Tags
# ==============================================================================
# Ticket CLOUD-231 Requirements:
# Everything created must be tagged Project = vpc-lab and Owner = david.
# This provider block enforces these tags globally across all AWS resources.

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_tag
      Owner       = var.owner_tag
      Environment = var.environment
      ManagedBy   = "terraform"
      Repository  = "PayFlow"
    }
  }
}

