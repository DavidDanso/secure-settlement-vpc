# ==============================================================================
# NAT Module - Outputs
# ==============================================================================

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs across all 3 AZs."
  value       = aws_nat_gateway.this[*].id
}

output "payment_processor_allowlist_ips" {
  description = "Complete list of static public IPs to deliver to the payment processor partner."
  value = concat(
    aws_eip.nat_primary[*].public_ip,
    [aws_eip.nat_a_secondary.public_ip]
  )
}

output "zone_a_public_ips" {
  description = "Public IPs assigned to NAT Gateway A (primary + secondary) supporting 80,000 conns."
  value = [
    aws_eip.nat_primary[0].public_ip,
    aws_eip.nat_a_secondary.public_ip
  ]
}

output "primary_eips" {
  description = "Primary Elastic IPs allocated to the 3 NAT Gateways."
  value       = aws_eip.nat_primary[*].public_ip
}

output "secondary_eip_zone_a" {
  description = "Secondary Elastic IP allocated to Zone A."
  value       = aws_eip.nat_a_secondary.public_ip
}

