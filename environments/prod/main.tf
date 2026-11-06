# ==============================================================================
# Environment: Production - Infrastructure Orchestration
# ==============================================================================
# Composes the four core infrastructure modules:
# 1. module.vpc        - Network backbone, subnets, IGW, and S3 Gateway Endpoint
# 2. module.nat        - EIPs, multi-AZ NAT Gateways, Zone A dual-EIP for 80k conns
# 3. module.security   - Strict security groups for ALB and checkout app servers
# 4. module.monitoring - CloudWatch alarms (SNAT exhaustion, packet drops) & Flow Logs

# ------------------------------------------------------------------------------
# 1. VPC Module
# ------------------------------------------------------------------------------
module "vpc" {
  source = "../../modules/vpc"

  vpc_name             = var.vpc_name
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  aws_region           = var.aws_region
}

# ------------------------------------------------------------------------------
# 2. NAT Module (High Availability & SNAT Concurrency)
# ------------------------------------------------------------------------------
module "nat" {
  source = "../../modules/nat"

  vpc_name                = var.vpc_name
  availability_zones      = var.availability_zones
  public_subnet_ids       = module.vpc.public_subnet_ids
  private_route_table_ids = module.vpc.private_route_table_ids
}

# ------------------------------------------------------------------------------
# 3. Security Module (Least-Privilege Firewalls)
# ------------------------------------------------------------------------------
module "security" {
  source = "../../modules/security"

  vpc_name = var.vpc_name
  vpc_id   = module.vpc.vpc_id
  vpc_cidr = module.vpc.vpc_cidr
}

