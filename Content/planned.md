# 📋 Planned Terraform 3-Tier Employee Directory Web Application

This document is my **blueprint** for building a **Terraform-powered AWS 3-Tier Employee Directory Application**.
It contains:

1. **Architecture & decisions** – what I want to build and why.
2. **Variables to define** – so configs are reusable.
3. **Terraform Registry research targets** – to understand the syntax.
4. **AI Prompt Templates** – so I can quickly generate boilerplate Terraform code, then fill in my specific variables.

---

## 🌍 Global Project Setup

**Decisions**

* Naming convention: `employee-<env>-<component>`
* Environments: `dev`, `prod` (workspaces or folders)
* Remote state: S3 backend + DynamoDB locking
* Tagging standard: `Project`, `Environment`, `Owner`, `CostCenter`

**Variables**

* `aws_region`
* `project_name`
* `environment`
* `tags` (map)

**Docs to Read**

* `aws provider`
* `terraform backend s3`
* `terraform state locking dynamodb`
* `terraform workspaces`
* `terraform variables`, `outputs`, `locals`

**AI Prompt Template**

> Generate Terraform configuration to set up the AWS provider in region `${var.aws_region}`, with default tags `${var.tags}`, and configure a remote S3 backend with DynamoDB state locking. Include variables for `project_name`, `environment`, and `aws_region`.

---

## 🔐 Module 1 — IAM

**Decisions**

* Users: `AdminUser`, `DevUser`
* Group: `EC2Admins`
* EC2 Role: `EmployeeWebAppRole`
* Policies: Start with AWS managed S3 + DynamoDB access

**Variables**

* `admin_user_name`
* `dev_user_name`
* `iam_group_name`
* `ec2_role_name`
* `managed_policy_arns` (list)

**Docs to Read**

* `aws_iam_user`
* `aws_iam_group`
* `aws_iam_group_policy_attachment`
* `aws_iam_role` (assume role policy)
* `aws_iam_instance_profile`

**AI Prompt Template**

> Generate Terraform AWS IAM configuration that creates:
>
> * Users `${var.admin_user_name}` and `${var.dev_user_name}`
> * Group `${var.iam_group_name}` with `${var.managed_policy_arns}` attached
> * Role `${var.ec2_role_name}` with trust for EC2 and the same managed policies
> * Instance profile bound to that role
>   Use variables and tagging from my global setup.

---

## 🌐 Module 2 — EC2

**Decisions**

* AMI: Amazon Linux 2023
* Instance type: `t2.micro`
* Security group: HTTP/HTTPS only
* Attach IAM instance profile from Module 1

**Variables**

* `instance_name`
* `instance_type`
* `ami_id` or `data aws_ami` lookup
* `user_data_path`
* `web_ingress_cidrs` (list)
* `vpc_id`, `subnet_id`

**Docs to Read**

* `aws_instance`
* `aws_security_group`
* `data aws_ami`
* `user_data vs user_data_replace_on_change`

**AI Prompt Template**

> Generate Terraform AWS EC2 configuration that launches:
>
> * An instance `${var.instance_name}` in `${var.subnet_id}` with `${var.instance_type}`
> * Using AMI from data source for Amazon Linux 2023
> * With security group allowing HTTP/HTTPS from `${var.web_ingress_cidrs}`
> * Attaching IAM instance profile `${var.ec2_instance_profile}`
> * Running `user_data` script from `${var.user_data_path}`
>   Output the instance public IP.

---

## 🏗️ Module 3 — VPC & Networking

**Decisions**

* CIDR: `10.1.0.0/16`
* 2 AZs (`eu-west-2a`, `eu-west-2b`)
* Public/Private subnets
* Internet Gateway + public route table

**Variables**

* `vpc_cidr`
* `azs` (list)
* `public_subnet_cidrs`
* `private_subnet_cidrs`
* `enable_nat_gateway`

**Docs to Read**

* `aws_vpc`
* `aws_subnet`
* `aws_internet_gateway`
* `aws_route_table`
* `aws_route_table_association`

**AI Prompt Template**

> Generate Terraform AWS VPC configuration for:
>
> * CIDR `${var.vpc_cidr}`
> * Public subnets `${var.public_subnet_cidrs}` and private subnets `${var.private_subnet_cidrs}`
> * Internet gateway and public route table associated with public subnets
>   Include variable inputs and tags from my global setup.

---

## 🪣 Module 4 — S3

**Decisions**

* Unique bucket name
* Block public access
* Allow only EC2 role to Put/Get

**Variables**

* `photos_bucket_name`
* `bucket_force_destroy`

**Docs to Read**

* `aws_s3_bucket`
* `aws_s3_bucket_policy`
* `aws_s3_bucket_public_access_block`

**AI Prompt Template**

> Generate Terraform AWS S3 configuration for:
>
> * Bucket `${var.photos_bucket_name}` with public access blocked
> * Bucket policy allowing only IAM role `${var.ec2_role_name}` to Put/Get objects
> * `force_destroy` set to `${var.bucket_force_destroy}`

---

## 📄 Module 5 — DynamoDB

**Decisions**

* Table: `Employees`
* Partition key: `id` (String)
* Billing mode: `PAY_PER_REQUEST`

**Variables**

* `ddb_table_name`
* `ddb_hash_key`
* `ddb_billing_mode`

**Docs to Read**

* `aws_dynamodb_table`
* `aws_iam_policy` (least-privilege CRUD)

**AI Prompt Template**

> Generate Terraform AWS DynamoDB configuration for:
>
> * Table `${var.ddb_table_name}` with hash key `${var.ddb_hash_key}` (String)
> * Billing mode `${var.ddb_billing_mode}`
> * Tagged with my global tags

---

## ⚖️ Module 6 — ALB + Auto Scaling

**Decisions**

* ALB: internet-facing, 2 subnets
* Target group: HTTP on `/`
* Launch template for EC2
* ASG: desired/min/max = `2/2/4`
* Scaling policy: target CPU 60%

**Variables**

* `alb_name`
* `target_group_name`
* `health_check_path`
* `launch_template_name`
* `asg_desired`, `asg_min`, `asg_max`
* `cpu_target_utilization`

**Docs to Read**

* `aws_lb`
* `aws_lb_target_group`
* `aws_launch_template`
* `aws_autoscaling_group`
* `aws_autoscaling_policy`

**AI Prompt Template**

> Generate Terraform AWS ALB + Auto Scaling configuration for:
>
> * ALB `${var.alb_name}` across `${var.public_subnet_ids}`
> * Target group `${var.target_group_name}` with health check path `${var.health_check_path}`
> * Launch template `${var.launch_template_name}`
> * ASG desired/min/max = `${var.asg_desired}`, `${var.asg_min}`, `${var.asg_max}`
> * Target tracking scaling policy for `${var.cpu_target_utilization}`% CPU

---

## 📦 App Config (User Data / Env)

**Decisions**

* Env vars: `PHOTOS_BUCKET`, `AWS_DEFAULT_REGION`, `DYNAMO_MODE`
* Script stored in `/scripts/user_data.sh`

**Variables**

* `app_env` (map)
* `user_data_path`

**Docs to Read**

* `terraform templatefile`
* `aws_instance user_data`
* `aws_launch_template user_data`

**AI Prompt Template**

> Generate Terraform EC2 user\_data configuration that:
>
> * Sets environment variables from `${var.app_env}`
> * Runs Flask app installation commands
> * Uses `templatefile` to render `${var.user_data_path}`

---

## 🏷️ Tagging & Naming

**Decisions**

* Use `default_tags` provider block
* Name prefix pattern: `${var.project_name}-${var.environment}`

**Variables**

* `name_prefix`
* `default_tags` (map)

**Docs to Read**

* `provider "aws" default_tags`
* `terraform locals`

**AI Prompt Template**

> Generate Terraform provider block with `default_tags` set to `${var.default_tags}`, and ensure all resources include a `Name` tag prefixed with `${var.name_prefix}`.
