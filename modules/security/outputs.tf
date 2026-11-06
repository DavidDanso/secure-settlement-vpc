# ==============================================================================
# Security Module - Outputs
# ==============================================================================

output "alb_security_group_id" {
  description = "Security Group ID for the ALB (to be referenced in Ticket CLOUD-232)."
  value       = aws_security_group.alb.id
}

output "app_security_group_id" {
  description = "Security Group ID for PayFlow app servers."
  value       = aws_security_group.app.id
}

