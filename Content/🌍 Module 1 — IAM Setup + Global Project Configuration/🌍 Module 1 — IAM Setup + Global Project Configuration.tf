########################################
# Provider + defaults
########################################
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.tags
  }
}

########################################
# Locals
########################################
# Why locals?
# To avoid repeating the same user names in multiple places, we define them once here.
locals {
  users = [
    var.admin_user_name,
    var.dev_user_name,
  ]
}

########################################
# IAM Users
########################################
# Provides IAM users for admin and dev
resource "aws_iam_user" "users" {
  for_each = toset(local.users)
  name     = each.key
}

# Optional: Console passwords (login profiles)
# this creates login profiles for the users, allowing them to log in to the AWS console.
resource "aws_iam_user_login_profile" "users" {
# the for each loop iterates over the users created above and says if create_login_profiles is true, then create a login profile for each user.
  for_each                = var.create_login_profiles ? aws_iam_user.users : {}
#   the user attribute specifies which user the login profile belongs to.
  user                    = each.value.name
  password_reset_required = false
}

# Optional: Programmatic access (access keys)
# NOTE: Access key IDs and SECRETS are stored in state. Rotate/delete after use.
# this creates access keys for the users, allowing them to interact with AWS services programmatically.
resource "aws_iam_access_key" "users" {
    # the for each loop iterates over the users created above and says if create_access_keys is true, then create an access key for each user.
  for_each = var.create_access_keys ? aws_iam_user.users : {}
#   the user attribute specifies which user the access key belongs to.
  user     = each.value.name
}

########################################
# Group + policy attachments + membership
########################################
# Provides an IAM group for EC2 admins
resource "aws_iam_group" "ec2_admins" {
  name = var.iam_group_name
}
# this attaches managed policies to the group, allowing it to have EC2 admin permissions.
resource "aws_iam_group_policy_attachment" "group_policies" {
  for_each   = toset(var.group_policy_arns)
  group      = aws_iam_group.ec2_admins.name
  policy_arn = each.key
}

# Put both users into the group
resource "aws_iam_user_group_membership" "membership" {
  for_each = aws_iam_user.users

  user = each.value.name
  groups = [
    aws_iam_group.ec2_admins.name
  ]
}

########################################
# EC2 Role + Instance Profile
########################################

# Trust policy: allow EC2 to assume this role
data "aws_iam_policy_document" "ec2_trust" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2_role" {
  name               = var.ec2_role_name
  assume_role_policy = data.aws_iam_policy_document.ec2_trust.json
}

# Attach managed policies (S3 + DynamoDB by default)
resource "aws_iam_role_policy_attachment" "role_policies" {
  for_each   = toset(var.role_policy_arns)
  role       = aws_iam_role.ec2_role.name
  policy_arn = each.key
}

# Instance profile to attach to EC2 instances
resource "aws_iam_instance_profile" "ec2_profile" {
  name = var.ec2_instance_profile_name
  role = aws_iam_role.ec2_role.name
}

########################################
# Helpful Outputs (optional)
########################################
output "iam_user_arns" {
  description = "ARNs of created IAM users"
  value       = { for k, u in aws_iam_user.users : k => u.arn }
}

output "iam_group_name" {
  description = "IAM group name"
  value       = aws_iam_group.ec2_admins.name
}

output "ec2_role_arn" {
  description = "ARN of the EC2 role"
  value       = aws_iam_role.ec2_role.arn
}

output "ec2_instance_profile_name" {
  description = "EC2 instance profile name"
  value       = aws_iam_instance_profile.ec2_profile.name
}

# this output provides the console passwords for the users if create_login_profiles is true.
output "console_passwords" {
  description = "console passwords"
  value       = var.create_login_profiles ? { for k, lp in aws_iam_user_login_profile.users : k => lp.encrypted_password } : {}
  sensitive   = true
}

# this output provides the access keys for the users if create_access_keys is true.
output "access_keys" {
  description = "Access keys (DO NOT COMMIT; rotate quickly)."
  value       = var.create_access_keys ? { for k, ak in aws_iam_access_key.users : k => { id = ak.id, secret = ak.secret } } : {}
  sensitive   = true
}
