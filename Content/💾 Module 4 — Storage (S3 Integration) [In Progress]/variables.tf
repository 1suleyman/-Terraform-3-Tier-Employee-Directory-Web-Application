# ---------- Global ----------
variable "aws_region" {
  description = "AWS region (e.g., eu-west-2)"
  type        = string
  default     = "eu-west-2"
}

variable "tags" {
  description = "Default tags applied to all resources"
  type        = map(string)
  default     = {
    "Environment" = "Development"
    "Project"     = "EmployeeDirectory"
    "ManagedBy"   = "Terraform"
  }
}

# ---------- IAM naming ----------
# Provides an IAM user.
variable "admin_user_name" {
  description = "Name for the Admin IAM user"
  type        = string
  default     = "AdminUser"
}

# Provides an IAM user.
variable "dev_user_name" {
  description = "Name for the Dev IAM user"
  type        = string
  default     = "DevUser"
}

# Provides an IAM group.
variable "iam_group_name" {
  description = "Name for the IAM group to attach EC2 admin permissions"
  type        = string
  default     = "EC2Admins"
}

# Provides an IAM role.
variable "ec2_role_name" {
  description = "Name for the IAM role assumed by EC2"
  type        = string
  default     = "EmployeeWebAppRole"
}

# Provides an IAM instance profile.
variable "ec2_instance_profile_name" {
  description = "Name for the IAM instance profile to attach to EC2"
  type        = string
  default     = "EmployeeWebAppInstanceProfile"
}

# ---------- Managed policy ARNs (override if you want tighter scopes later) ----------

# Provides an IAM policy attached to a group.
variable "group_policy_arns" {
  description = "Managed policy ARNs to attach to the IAM group (EC2 admin by default)"
  type        = list(string)
  default     = [
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
  ]
}

# Provides an IAM role inline policy.
variable "role_policy_arns" {
  description = "Managed policy ARNs to attach to the EC2 role (S3 + DynamoDB by default)"
  type        = list(string)
  default     = [
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
  ]
}

# ---------- Console + CLI access toggles ----------
variable "create_login_profiles" {
  description = "Whether to create console passwords for the users (login profiles). Use with a PGP key if possible."
  type        = bool
  default     = true
}

variable "create_access_keys" {
  description = "Whether to create programmatic access keys for the users (CLI access)."
  type        = bool
  default     = true
}

# ---------- AMI selection (no hardcoding) ----------
# Choose which base image to use without touching ec2.tf
# Allowed: "al2023", "ubuntu_jammy", "al2"
variable "base_image" {
  description = "Base image preset to use for EC2"
  type        = string
  default     = "al2023"
}

# These control generic filters and can be overridden if needed.
variable "ami_architecture" {
  description = "CPU architecture to filter AMIs"
  type        = string
  default     = "x86_64"
}

variable "ami_virtualization_type" {
  description = "Virtualization type to filter AMIs"
  type        = string
  default     = "hvm"
}

variable "ami_root_device_type" {
  description = "Root device type to filter AMIs"
  type        = string
  default     = "ebs"
}

# ---- SSH from my IP only variable ----
# Your public IP address for SSH access
# ⚠️ IMPORTANT: Do NOT hardcode your real IP here if pushing to a public repo.
# Instead, pass it at runtime:
# terraform apply -var="admin_ip=$(curl -s https://checkip.amazonaws.com)/32"
variable "admin_ip" {
  description = "Public IPv4 address allowed to SSH into EC2 (format: X.X.X.X/32)"
  type        = string
  default     = "0.0.0.0/32" # Placeholder — blocked by default until overridden
}

########################################
# Networking variables
########################################

# VPC CIDR
variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.1.0.0/16"
}

# Exactly 2 AZs for HA (adjust for your region)
variable "azs" {
  description = "Availability Zones to use (2 AZs)"
  type        = list(string)
  default     = ["eu-west-2a", "eu-west-2b"]
}

# Public subnets (one CIDR per AZ in same order as var.azs)
variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs (match order of var.azs)"
  type        = list(string)
  default     = ["10.1.0.0/24", "10.1.1.0/24"]
}

# Private subnets (one CIDR per AZ in same order as var.azs)
variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs (match order of var.azs)"
  type        = list(string)
  default     = ["10.1.10.0/24", "10.1.11.0/24"]
}

########################################
# Module 4 — S3 variables
########################################

variable "s3_bucket_name" {
  description = "S3 bucket for employee photos"
  type        = string
  default     = "employee-photo-bucket-456s"
}

# Optional: local path to an image to upload as a quick test (leave empty to skip)
variable "test_object_source" {
  description = "Local path to a test image to upload to S3 (e.g., ./employee2.jpg). Leave empty to skip."
  type        = string
  default     = "./testimg.png"
}

variable "test_object_key" {
  description = "S3 key (object name) for the test upload"
  type        = string
  default     = "./testimg.png"
}
