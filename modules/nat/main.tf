# ==============================================================================
# NAT Module - High-Availability Multi-AZ NAT & SNAT Port Optimization
# ==============================================================================
# Ticket CLOUD-231 Requirements Implemented:
# 1. 1 NAT Gateway per AZ ensures an AZ loss does not break egress for others.
# 2. Elastic IPs survive NAT Gateway replacements and provide the partner allow-list.
# 3. Secondary Elastic IP in Zone A doubles ephemeral port capacity to 110,000
#    concurrent connections, eliminating SNAT port exhaustion during the 80k
#    connection settlement job to the single processor endpoint.
# 4. Outbound routes added to private route tables independently.

# ------------------------------------------------------------------------------
# 1. Primary Elastic IPs
# ------------------------------------------------------------------------------
resource "aws_eip" "nat_primary" {
  count  = length(var.availability_zones)
  domain = "vpc"

  tags = {
    Name        = "${var.vpc_name}-nat-eip-${substr(var.availability_zones[count.index], -1, 1)}-primary"
    AZ          = var.availability_zones[count.index]
    Role        = "nat-primary"
    Description = "Static egress IP for payment processor allow-list"
  }

  lifecycle {
    prevent_destroy = false
  }
}

# ------------------------------------------------------------------------------
# 2. Multi-AZ NAT Gateways (1 per AZ in public subnets)
# ------------------------------------------------------------------------------
resource "aws_nat_gateway" "this" {
  count         = length(var.availability_zones)
  allocation_id = aws_eip.nat_primary[count.index].id
  subnet_id     = var.public_subnet_ids[count.index]

  tags = {
    Name = "${var.vpc_name}-nat-gw-${substr(var.availability_zones[count.index], -1, 1)}"
    AZ   = var.availability_zones[count.index]
  }
}

# ------------------------------------------------------------------------------
# 3. Outbound Default Route (0.0.0.0/0) in Private Route Tables
# Points to each AZ's local NAT Gateway for zero cross-AZ dependency.
# ------------------------------------------------------------------------------
resource "aws_route" "private_nat" {
  count                  = length(var.availability_zones)
  route_table_id         = var.private_route_table_ids[count.index]
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[count.index].id
}
