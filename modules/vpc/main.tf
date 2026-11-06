# ==============================================================================
# VPC Module - Core Network Infrastructure
# ==============================================================================
# Implements:
# - VPC with DNS hostnames and DNS support enabled
# - Internet Gateway for public subnet egress/ingress
# - 3 Public Subnets (/26 = 59 usable IPs) for NAT GWs, ALBs, and growth
# - 3 Private Subnets (/23 = 507 usable IPs) strictly isolated (no public IPs)
# - Public Route Table routing 0.0.0.0/0 to the Internet Gateway
# - 3 Private Route Tables (one per AZ) for independent fault-tolerant routing
# - S3 Gateway VPC Endpoint providing free, direct routing to S3 (cost optimization)

# ------------------------------------------------------------------------------
# 1. Virtual Private Cloud
# ------------------------------------------------------------------------------
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = var.vpc_name
  }
}

# ------------------------------------------------------------------------------
# 2. Internet Gateway
# ------------------------------------------------------------------------------
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

# ------------------------------------------------------------------------------
# 3. Public Subnets (1 per AZ)
# ------------------------------------------------------------------------------
resource "aws_subnet" "public" {
  count                   = length(var.availability_zones)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.vpc_name}-public-${substr(var.availability_zones[count.index], -1, 1)}"
    Tier = "public"
    Purpose = "NAT Only"
  }
}

# ------------------------------------------------------------------------------
# 4. Private Subnets (1 per AZ)
# ------------------------------------------------------------------------------
resource "aws_subnet" "private" {
  count                   = length(var.availability_zones)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.private_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.vpc_name}-private-${substr(var.availability_zones[count.index], -1, 1)}"
    Tier = "private"
  }
}

# ------------------------------------------------------------------------------
# 5. Public Route Table & Associations
# ------------------------------------------------------------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "${var.vpc_name}-rt-public"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# ------------------------------------------------------------------------------
# 6. Private Route Tables (1 per AZ) & Associations
# Dedicated per AZ so NAT routes remain completely independent.
# ------------------------------------------------------------------------------
resource "aws_route_table" "private" {
  count  = length(var.availability_zones)
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.vpc_name}-rt-private-${substr(var.availability_zones[count.index], -1, 1)}"
    AZ   = var.availability_zones[count.index]
  }
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# ------------------------------------------------------------------------------
# 7. S3 Gateway VPC Endpoint (Cost Reduction)
# ------------------------------------------------------------------------------
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"

  # Associate with both public and all private route tables
  route_table_ids = concat(
    [aws_route_table.public.id],
    aws_route_table.private[*].id
  )

  tags = {
    Name    = "${var.vpc_name}-vpce-s3"
    Service = "s3"
    Type    = "gateway"
    Purpose = "cost-optimization"
  }
}

