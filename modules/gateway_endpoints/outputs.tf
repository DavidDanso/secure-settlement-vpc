# ==============================================================================
# Monitoring Module - Outputs
# ==============================================================================

output "flow_logs_log_group_arn" {
  description = "ARN of the CloudWatch Log Group for VPC Flow Logs."
  value       = var.enable_flow_logs ? aws_cloudwatch_log_group.flow_logs[0].arn : null
}

output "nat_error_port_allocation_alarm_arns" {
  description = "ARNs of the P1 Critical NAT ErrorPortAllocation alarms."
  value       = aws_cloudwatch_metric_alarm.nat_error_port_allocation[*].arn
}

output "nat_packet_drop_alarm_arns" {
  description = "ARNs of the P2 High NAT PacketsDropCount alarms."
  value       = aws_cloudwatch_metric_alarm.nat_packet_drop_count[*].arn
}

output "nat_a_high_connections_alarm_arn" {
  description = "ARN of the P3 Warning alarm for Zone A high active connection count."
  value       = aws_cloudwatch_metric_alarm.nat_a_high_active_connections.arn
}

