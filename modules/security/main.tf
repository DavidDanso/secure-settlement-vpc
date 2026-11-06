# ==============================================================================
# Security Module - Least-Privilege Network Access Controls
# ==============================================================================
# Implements:
# - ALB Security Group: Ingress 80/443 from internet; egress 8080 to App SG
# - App Server Security Group:
#   * Ingress: Port 8080 ONLY from ALB SG
#   * Egress: Port 443 (HTTPS) ONLY to internet (processor API & package mirrors)
#   * Egress: Port 53 (UDP/TCP) to VPC CIDR (AmazonProvidedDNS resolution)
# - No inline rules used: Standalone rules prevent circular dependency deadlocks.

# ------------------------------------------------------------------------------
# 1. Load Balancer Security Group (Interface for Ticket CLOUD-232)
# ------------------------------------------------------------------------------
resource "aws_security_group" "alb" {
  name        = "${var.vpc_name}-alb-sg"
  description = "Security group for customer-facing Application Load Balancer"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.vpc_name}-alb-sg"
    Role = "load-balancer"
  }
}

resource "aws_security_group_rule" "alb_ingress_https" {
  type              = "ingress"
  description       = "Allow inbound HTTPS from internet"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "alb_ingress_http" {
  type              = "ingress"
  description       = "Allow inbound HTTP from internet for HTTPS redirects"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "alb_egress_to_app" {
  type                     = "egress"
  description              = "Forward traffic exclusively to app servers on port 8080"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.app.id
  security_group_id        = aws_security_group.alb.id
}

# ------------------------------------------------------------------------------
# 2. Application Servers Security Group
# ------------------------------------------------------------------------------
resource "aws_security_group" "app" {
  name        = "${var.vpc_name}-app-sg"
  description = "Strict security group for PayFlow private checkout app servers"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.vpc_name}-app-sg"
    Role = "application"
  }
}

resource "aws_security_group_rule" "app_ingress_from_alb" {
  type                     = "ingress"
  description              = "Allow traffic only from ALB on port 8080"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  security_group_id        = aws_security_group.app.id
}

resource "aws_security_group_rule" "app_egress_https" {
  type              = "egress"
  description       = "Allow outbound HTTPS only (payment processor API & package mirrors)"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.app.id
}

resource "aws_security_group_rule" "app_egress_dns_udp" {
  type              = "egress"
  description       = "Allow outbound DNS queries (UDP) to VPC AmazonProvidedDNS"
  from_port         = 53
  to_port           = 53
  protocol          = "udp"
  cidr_blocks       = [var.vpc_cidr]
  security_group_id = aws_security_group.app.id
}

resource "aws_security_group_rule" "app_egress_dns_tcp" {
  type              = "egress"
  description       = "Allow outbound DNS queries (TCP) to VPC AmazonProvidedDNS"
  from_port         = 53
  to_port           = 53
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr]
  security_group_id = aws_security_group.app.id
}

