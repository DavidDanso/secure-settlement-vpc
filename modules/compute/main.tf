# ==============================================================================
# Monitoring Module - Observability & Early Warning Alarms
# ==============================================================================
# Ticket CLOUD-231 Requirements Implemented:
# Operations wants to hear about problems before customers do.
#
# Key Components:
# 1. Centralized VPC Flow Logs in CloudWatch Logs for audit and REJECT tracking.
# 2. P1 Critical Alarm: NAT Gateway ErrorPortAllocation (SNAT exhaustion).
# 3. P2 High Alarm: NAT Gateway PacketsDropCount.
# 4. P3 Warning Alarm: Zone A High Active Connections (>90,000 conns).

# ------------------------------------------------------------------------------
# 1. CloudWatch Log Group for VPC Flow Logs
# ------------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "flow_logs" {
  count             = var.enable_flow_logs ? 1 : 0
  name              = "/aws/vpc-flow-logs/${var.vpc_name}"
  retention_in_days = var.flow_logs_retention_days

  tags = {
    Name    = "${var.vpc_name}-flow-logs"
    Service = "observability"
  }
}

# ------------------------------------------------------------------------------
# 2. IAM Role & Policy for VPC Flow Logs
# ------------------------------------------------------------------------------
resource "aws_iam_role" "flow_logs" {
  count = var.enable_flow_logs ? 1 : 0
  name  = "${var.vpc_name}-vpc-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.vpc_name}-vpc-flow-logs-role"
  }
}

resource "aws_iam_policy" "flow_logs" {
  count       = var.enable_flow_logs ? 1 : 0
  name        = "${var.vpc_name}-vpc-flow-logs-policy"
  description = "IAM policy for publishing PayFlow VPC flow logs to CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Effect   = "Allow"
        Resource = "${aws_cloudwatch_log_group.flow_logs[0].arn}:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "flow_logs" {
  count      = var.enable_flow_logs ? 1 : 0
  role       = aws_iam_role.flow_logs[0].name
  policy_arn = aws_iam_policy.flow_logs[0].arn
}

# ------------------------------------------------------------------------------
# 3. VPC Flow Logs
# ------------------------------------------------------------------------------
resource "aws_flow_log" "this" {
  count           = var.enable_flow_logs ? 1 : 0
  iam_role_arn    = aws_iam_role.flow_logs[0].arn
  log_destination = aws_cloudwatch_log_group.flow_logs[0].arn
  traffic_type    = "ALL"
  vpc_id          = var.vpc_id

  tags = {
    Name = "${var.vpc_name}-flow-log"
  }
}

# ------------------------------------------------------------------------------
# 4. CloudWatch Alarm: NAT Gateway ErrorPortAllocation (P1 Critical)
# Fires if any NAT Gateway runs out of ephemeral source ports.
# ------------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "nat_error_port_allocation" {
  count               = length(var.nat_gateway_ids)
  alarm_name          = "${var.vpc_name}-alarm-nat-${substr(var.availability_zones[count.index], -1, 1)}-port-allocation-error"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "ErrorPortAllocation"
  namespace           = "AWS/NATGateway"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "CRITICAL: NAT Gateway in ${var.availability_zones[count.index]} is experiencing SNAT port allocation errors (exhaustion). Connections are failing."
  treat_missing_data  = "notBreaching"

  dimensions = {
    NatGatewayId = var.nat_gateway_ids[count.index]
  }

  tags = {
    Severity = "critical"
    AZ       = var.availability_zones[count.index]
  }
}

# ------------------------------------------------------------------------------
# 5. CloudWatch Alarm: NAT Gateway PacketsDropCount (P2 High)
# ------------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "nat_packet_drop_count" {
  count               = length(var.nat_gateway_ids)
  alarm_name          = "${var.vpc_name}-alarm-nat-${substr(var.availability_zones[count.index], -1, 1)}-packet-drops"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "PacketsDropCount"
  namespace           = "AWS/NATGateway"
  period              = 300
  statistic           = "Sum"
  threshold           = 10
  alarm_description   = "WARNING: NAT Gateway in ${var.availability_zones[count.index]} dropped packets. Investigate bandwidth spikes or target issues."
  treat_missing_data  = "notBreaching"

  dimensions = {
    NatGatewayId = var.nat_gateway_ids[count.index]
  }

  tags = {
    Severity = "high"
    AZ       = var.availability_zones[count.index]
  }
}

# ------------------------------------------------------------------------------
# 6. CloudWatch Alarm: Zone A High Active Connections (P3 Early Warning)
# ------------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "nat_a_high_active_connections" {
  alarm_name          = "${var.vpc_name}-alarm-nat-a-high-active-connections"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ActiveConnectionCount"
  namespace           = "AWS/NATGateway"
  period              = 300
  statistic           = "Maximum"
  threshold           = 90000
  alarm_description   = "WARNING: NAT Gateway A active connections exceeded 90,000 (>80% of dual-EIP 110,000 capacity). Review settlement batch traffic."
  treat_missing_data  = "notBreaching"

  dimensions = {
    NatGatewayId = var.nat_gateway_ids[0]
  }

  tags = {
    Severity = "warning"
    AZ       = var.availability_zones[0]
  }
}

