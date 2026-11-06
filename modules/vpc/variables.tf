# ==============================================================================
# VPC Module - Input Variables
# ==============================================================================

variable "vpc_name" {
  description = "Name prefix for the VPC and related networking resources."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC. Chosen to avoid existing network clashes."
  type        = string

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "vpc_cidr must be a valid CIDR block."
  }
}

variable "availability_zones" {
  description = "List of Availability Zones to deploy subnets across."
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (1 per AZ, sized as /26 for ~50 IPs)."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (1 per AZ, sized as /23 for ~300 app servers)."
  type        = list(string)
}

variable "aws_region" {
  description = "AWS region for regional resources like the S3 Gateway endpoint."
  type        = string
}

