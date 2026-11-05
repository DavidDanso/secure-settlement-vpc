# ==============================================================================
# Environment: Production - Input Variables
# ==============================================================================

variable "aws_region" {
  description = "Target AWS region for PayFlow production infrastructure."
  type        = string
  default     = "eu-west-1"
}

variable "environment" {
  description = "Deployment environment identifier."
  type        = string
  default     = "prod"
}

variable "vpc_name" {
  description = "Name for the VPC and prefix for child networking resources."
  type        = string
  default     = "settlement-vpc"
}

variable "vpc_cidr" {
  description = "VPC CIDR block. Chosen to avoid clashing with corporate and dev networks."
  type        = string
  default     = "10.50.0.0/16"

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "The vpc_cidr value must be a valid CIDR block."
  }
}

variable "availability_zones" {
  description = "List of 2 Availability Zones in eu-west-1 for high availability."
  type        = list(string)
  default     = ["eu-west-1a", "eu-west-1b"]

  validation {
    condition     = length(var.availability_zones) == 2
    error_message = "Settlement vpc requires exactly 2 Availability Zones."
  }
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs"
  type        = list(string)
  default = [
    "10.50.0.0/26",
    "10.50.0.64/26"
  ]

  validation {
    condition     = length(var.public_subnet_cidrs) == 2
    error_message = "Exactly 2 public subnet CIDRs are required."
  }
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs"
  type        = list(string)
  default = [
    "10.50.10.0/23",
    "10.50.12.0/23"
  ]

  validation {
    condition     = length(var.private_subnet_cidrs) == 2
    error_message = "Exactly 2 private subnet CIDRs are required."
  }
}

variable "project_tag" {
  description = "Mandatory Project tag value specified in Ticket CLOUD-231."
  type        = string
  default     = "settlement-vpc"
}

variable "owner_tag" {
  description = "Mandatory Owner tag value specified in Ticket CLOUD-231."
  type        = string
  default     = "david"
}

variable "enable_flow_logs" {
  description = "Enable centralized VPC Flow Logs in CloudWatch."
  type        = bool
  default     = true
}

variable "flow_logs_retention_days" {
  description = "Days of retention for VPC Flow Logs in CloudWatch."
  type        = number
  default     = 30
}

