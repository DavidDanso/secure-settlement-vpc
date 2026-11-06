# ==============================================================================
# Environment: Production - Outputs
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. Partner Deliverables: Payment Processor Allow-list
# Must contain all 4 static public IPs (Zone A primary + secondary, Zone B, Zone C)
# ------------------------------------------------------------------------------
output "payment_processor_allowlist_ips" {
  description = "Complete list of static public IPs to deliver to the payment processor partner."
  value       = module.nat.payment_processor_allowlist_ips
}

output "nat_gateway_zone_a_ips" {
  description = "Public IPs assigned to NAT Gateway in Zone A (handling the 80k connection settlement job)."
  value       = module.nat.zone_a_public_ips
}

# ------------------------------------------------------------------------------
# 2. Core VPC & Subnet Identifiers
# ------------------------------------------------------------------------------
output "vpc_id" {
  description = "VPC ID of payflow-prod."
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "CIDR block allocated to the VPC."
  value       = module.vpc.vpc_cidr
}

output "public_subnet_ids" {
  description = "List of public subnet IDs (for the ALB and NAT Gateways)."
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs (where the ~300 app servers per AZ reside)."
  value       = module.vpc.private_subnet_ids
}

# ------------------------------------------------------------------------------
# 3. Security Groups
# ------------------------------------------------------------------------------
output "app_security_group_id" {
  description = "Security Group ID for PayFlow checkout app servers."
  value       = module.security.app_security_group_id
}

output "alb_security_group_id" {
  description = "Security Group ID for the ALB (to be referenced in Ticket CLOUD-232)."
  value       = module.security.alb_security_group_id
}

# ------------------------------------------------------------------------------
# 4. Gateways & Endpoints
# ------------------------------------------------------------------------------
output "nat_gateway_ids" {
  description = "IDs of the deployed NAT Gateways across all 3 AZs."
  value       = module.nat.nat_gateway_ids
}

output "s3_vpc_endpoint_id" {
  description = "ID of the S3 Gateway VPC Endpoint providing free private S3 data transfer."
  value       = module.vpc.s3_endpoint_id
}

# ------------------------------------------------------------------------------
# 5. Monitoring & Observability
# ------------------------------------------------------------------------------
output "flow_logs_log_group_arn" {
  description = "ARN of the CloudWatch Log Group for VPC Flow Logs."
  value       = module.monitoring.flow_logs_log_group_arn
}

output "nat_error_port_allocation_alarm_arns" {
  description = "ARNs of the P1 Critical SNAT Port Allocation alarms."
  value       = module.monitoring.nat_error_port_allocation_alarm_arns
}

