# ==============================================================================
# Environment: Production - Variable Definitions
# ==============================================================================

aws_region  = "eu-west-1"
environment = "prod"
vpc_name    = "settlement-vpc"
vpc_cidr    = "10.50.0.0/16"

availability_zones = [
  "eu-west-1a",
  "eu-west-1b"
]

public_subnet_cidrs = [
  "10.50.0.0/26",
  "10.50.0.64/26"
]

private_subnet_cidrs = [
  "10.50.10.0/23",
  "10.50.12.0/23"
]

project_tag = "vpc-lab"
owner_tag   = "david"

enable_flow_logs         = true
flow_logs_retention_days = 30

