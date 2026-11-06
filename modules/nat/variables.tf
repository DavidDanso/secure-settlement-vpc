# ==============================================================================
# NAT Module - Input Variables
# ==============================================================================

variable "vpc_name" {
  description = "Name prefix for resource tagging."
  type        = string
}

variable "availability_zones" {
  description = "List of Availability Zones."
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs where NAT Gateways will be deployed."
  type        = list(string)
}

variable "private_route_table_ids" {
  description = "List of private route table IDs to receive default routes to the NAT Gateways."
  type        = list(string)
}

