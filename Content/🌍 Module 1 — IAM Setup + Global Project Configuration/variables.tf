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
