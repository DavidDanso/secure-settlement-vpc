# ==============================================================================
# Security Module - Input Variables
# ==============================================================================

variable "vpc_id" {
  description = "The ID of the VPC."
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block of the VPC (used for restricting DNS queries to the internal resolver)."
  type        = string
}

variable "vpc_name" {
  description = "Name prefix for resource tagging."
  type        = string
}

