# 📋 Planned Terraform 3-Tier Employee Directory Web Application

This is my **blueprint** for building a Terraform-powered AWS 3-Tier Employee Directory Application.

It contains:

1. **Architecture & Decisions** – What I want to build and *why it matters*.
2. **Variables to Define** – So configs are reusable.
3. **Docs to Read** – Where to find syntax and best practices.
4. **AI Prompt Templates** – To quickly generate boilerplate code and focus on customizing.

---

## 🌍 Global Project Setup

**Decisions**

* **Naming convention:** `employee-<env>-<component>`
  *Why:* Keeps resources clearly grouped. Like labeling all moving boxes so you know exactly where they go.
* **Environments:** `dev`, `prod` (via workspaces or separate folders)
  *Why:* Safe testing before production. Like practicing on a spare car before driving your main one.
* **Remote state:** S3 backend + DynamoDB locking
  *Why:* Shared state prevents conflicts. DynamoDB lock is the “Do Not Disturb” sign for Terraform.
* **Tagging standard:** `Project`, `Environment`, `Owner`, `CostCenter`
  *Why:* Easier cost tracking, searches, and cleanup. Tags are AWS’s sticky notes.

**Variables**

* aws_region
* project_name
* environment
* tags (map)

**Docs to Read (Why)**

* **aws provider** – Terraform needs to know which cloud and region to talk to.
* **terraform backend s3** – Save Terraform state in S3.
* **terraform state locking dynamodb** – Avoids overwriting state in team setups.
* **terraform workspaces** – Multiple environments from one codebase.
* **terraform variables, outputs, locals** – Flexible and reusable configs.

**AI Prompt Template**

> Generate Terraform configuration to set up the AWS provider in region ${var.aws_region}, 
  with default tags ${var.tags}, and configure a remote S3 backend with DynamoDB state locking. 
  Include variables for project_name, environment, and aws_region.

---

## 🔐 Module 1 — IAM

**Decisions**

* **Users:** `AdminUser`, `DevUser`
  *Why:* Separate identities for different roles. Like having a master key and a guest key.
* **Group:** `EC2Admins`
  *Why:* Assign permissions once to the group instead of each user.
* **EC2 Role:** `EmployeeWebAppRole`
  *Why:* Secure app access to AWS without storing credentials inside the server.
* **Policies:** AWS-managed S3 + DynamoDB access to start
  *Why:* Ready-made and tested — like using a meal kit instead of cooking from scratch.

**Variables**

* admin_user_name
* dev_user_name
* iam_group_name
* ec2_role_name
* managed_policy_arns (list)

**Docs to Read (Why)**

* **aws\_iam\_user** – Creates AWS login identities.
* **aws\_iam\_group** – A bucket to organize users.
* **aws\_iam\_group\_policy\_attachment** – Attaches permissions to a group.
* **aws\_iam\_role** – The "identity" for AWS services.
* **aws\_iam\_instance\_profile** – Connects an IAM role to EC2.

**AI Prompt Template**

> Generate Terraform AWS IAM configuration that creates:
  Users ${var.admin_user_name} and ${var.dev_user_name}
  Group ${var.iam_group_name} with ${var.managed_policy_arns} attached
  Role ${var.ec2_role_name} with trust for EC2 and the same managed policies
  Instance profile bound to that role
  Use variables and tagging from my global setup.

---

## 🌐 Module 2 — EC2

**Decisions**

* **AMI:** Amazon Linux 2023
  *Why:* Lightweight, secure, AWS-optimized OS.
* **Instance type:** `t2.micro`
  *Why:* Cheap/free-tier for testing.
* **Security group:** HTTP/HTTPS only
  *Why:* Minimize open ports — lock all but necessary doors.
* **Attach IAM instance profile from Module 1**
  *Why:* Allows EC2 to securely talk to AWS services.

**Variables**

* instance_name
* instance_type
* ami_id or data aws_ami lookup
* user_data_path
* web_ingress_cidrs (list)
* vpc_id
* subnet_id

**Docs to Read (Why)**

* **aws\_instance** – Defines the server.
* **aws\_security\_group** – Sets network rules.
* **data aws\_ami** – Finds the latest OS image.
* **user\_data** – Script to auto-configure the instance.

**AI Prompt Template**

> Generate Terraform AWS EC2 configuration that launches:
  An instance ${var.instance_name} in ${var.subnet_id} with ${var.instance_type}
  Using AMI from data source for Amazon Linux 2023
  With security group allowing HTTP/HTTPS from ${var.web_ingress_cidrs}
  Attaching IAM instance profile ${var.ec2_instance_profile}
  Running user_data script from ${var.user_data_path}
  Output the instance public IP.

---

## 🏗️ Module 3 — VPC & Networking

**Decisions**

* **CIDR:** `10.1.0.0/16`
  *Why:* Gives enough IPs for scaling without overlap.
* **2 AZs:** (e.g., eu-west-2a, eu-west-2b)
  *Why:* Higher availability and fault tolerance.
* **Public/Private subnets**
  *Why:* Public for web traffic, private for backend security.
* **Internet Gateway + Public Route Table**
  *Why:* Needed for public subnet access to the internet.

**Variables**

* vpc_cidr
* azs (list)
* public_subnet_cidrs
* private_subnet_cidrs
* enable_nat_gateway

**Docs to Read (Why)**

* **aws\_vpc** – Your private network in AWS.
* **aws\_subnet** – Smaller chunks of your VPC.
* **aws\_internet\_gateway** – The bridge to the internet.
* **aws\_route\_table** – The GPS routes for network traffic.

**AI Prompt Template**

> Generate Terraform AWS VPC configuration for:
  CIDR ${var.vpc_cidr}
  Public subnets ${var.public_subnet_cidrs} and private subnets ${var.private_subnet_cidrs}
  Internet gateway and public route table associated with public subnets
  Include variable inputs and tags from my global setup.

---

## 🪣 Module 4 — S3

**Decisions**

* **Unique bucket name**
  *Why:* S3 bucket names are global — like unique usernames.
* **Block public access**
  *Why:* Prevents accidental data leaks.
* **Allow only EC2 role to Put/Get**
  *Why:* Restricts access to just the app.

**Variables**

* photos_bucket_name
* bucket_force_destroy

**Docs to Read (Why)**

* **aws\_s3\_bucket** – Creates storage buckets.
* **aws\_s3\_bucket\_policy** – Defines who can access it.
* **aws\_s3\_bucket\_public\_access\_block** – Stops public exposure.

**AI Prompt Template**

> Generate Terraform AWS S3 configuration for:
  Bucket ${var.photos_bucket_name} with public access blocked
  Bucket policy allowing only IAM role ${var.ec2_role_name} to Put/Get objects
  force_destroy set to ${var.bucket_force_destroy}

---

## 📄 Module 5 — DynamoDB

**Decisions**

* **Table:** `Employees`
  *Why:* Stores employee data for the app.
* **Partition key:** `id` (String)
  *Why:* Uniquely identifies each record.
* **Billing mode:** `PAY_PER_REQUEST`
  *Why:* Only pay for what’s used — good for dev/testing.

**Variables**

* ddb_table_name
* ddb_hash_key
* ddb_billing_mode


**Docs to Read (Why)**

* **aws\_dynamodb\_table** – Creates NoSQL database tables.
* **aws\_iam\_policy** – Least-privilege CRUD permissions.

**AI Prompt Template**

> Generate Terraform AWS DynamoDB configuration for:
  Table ${var.ddb_table_name} with hash key ${var.ddb_hash_key} (String)
  Billing mode ${var.ddb_billing_mode}
  Tagged with my global tags


---

## ⚖️ Module 6 — ALB + Auto Scaling

**Decisions**

* **ALB:** Internet-facing, 2 subnets
  *Why:* Distributes traffic across instances for reliability.
* **Target group:** HTTP on `/`
  *Why:* ALB needs a health check route.
* **Launch template:** For EC2 configs
  *Why:* Standardizes instance creation.
* **ASG:** `desired/min/max = 2/2/4`
  *Why:* Keeps enough servers running, scales during load.
* **Scaling policy:** Target CPU 60%
  *Why:* Add/remove instances automatically.

**Variables**

* alb_name
* target_group_name
* health_check_path
* launch_template_name
* asg_desired
* asg_min
* asg_max
* cpu_target_utilization


**Docs to Read (Why)**

* **aws\_lb** – Load balancer resource.
* **aws\_lb\_target\_group** – Directs traffic to registered targets.
* **aws\_launch\_template** – Blueprint for EC2 instances.
* **aws\_autoscaling\_group** – Scales instances automatically.
* **aws\_autoscaling\_policy** – Rules for scaling up/down.

**AI Prompt Template**

> Generate Terraform AWS ALB + Auto Scaling configuration for:
  ALB ${var.alb_name} across ${var.public_subnet_ids}
  Target group ${var.target_group_name} with health check path ${var.health_check_path}
  Launch template ${var.launch_template_name}
  ASG desired/min/max = ${var.asg_desired}, ${var.asg_min}, ${var.asg_max}
  Target tracking scaling policy for ${var.cpu_target_utilization}% CPU

