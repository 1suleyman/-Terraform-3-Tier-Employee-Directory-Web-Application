########################################
# Networking — VPC, Subnets, IGW, Routes
########################################

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, {
    Name = "proj-main-vpc"
  })
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "proj-igw"
  })
}

# Build maps AZ -> CIDR for public/private
locals {
  public_az_cidrs  = { for i, az in var.azs : az => var.public_subnet_cidrs[i] }
  private_az_cidrs = { for i, az in var.azs : az => var.private_subnet_cidrs[i] }
}

# Public subnets (auto-assign public IPs)
resource "aws_subnet" "public" {
  for_each                = local.public_az_cidrs
  vpc_id                  = aws_vpc.main.id
  availability_zone       = each.key
  cidr_block              = each.value
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "proj-public-${each.key}"
    Tier = "public"
  })
}

# Private subnets (isolated; no NAT here)
resource "aws_subnet" "private" {
  for_each          = local.private_az_cidrs
  vpc_id            = aws_vpc.main.id
  availability_zone = each.key
  cidr_block        = each.value

  tags = merge(var.tags, {
    Name = "proj-private-${each.key}"
    Tier = "private"
  })
}

# Public route table with default route to the internet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(var.tags, {
    Name = "proj-public-rt"
  })
}

# Associate public subnets to the public route table
resource "aws_route_table_association" "public_assoc" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

########################################
# Helpful outputs
########################################
output "vpc_id" {
  value       = aws_vpc.main.id
  description = "VPC ID"
}

output "public_subnet_ids" {
  value       = [for s in aws_subnet.public  : s.id]
  description = "Public subnet IDs (one per AZ)"
}

output "private_subnet_ids" {
  value       = [for s in aws_subnet.private : s.id]
  description = "Private subnet IDs (one per AZ)"
}
