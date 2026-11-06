# ==============================================================================
# Monitoring Module - Input Variables
# ==============================================================================

variable "vpc_id" {
  description = "The ID of the VPC."
  type        = string
}

variable "vpc_name" {
  description = "Name prefix for resource tagging."
  type        = string
}

variable "nat_gateway_ids" {
  description = "List of NAT Gateway IDs to attach CloudWatch alarms to."
  type        = list(string)
}

variable "availability_zones" {
  description = "List of Availability Zones corresponding to the NAT Gateways."
  type        = list(string)
}

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs publishing to CloudWatch Logs."
  type        = bool
  default     = true
}

variable "flow_logs_retention_days" {
  description = "Number of days to retain VPC Flow Logs."
  type        = number
  default     = 30
}

