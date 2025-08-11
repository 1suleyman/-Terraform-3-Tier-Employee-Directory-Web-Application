# 🧑‍💻 Terraform 3-Tier Employee Directory Web Application

Welcome to my **Terraform-powered AWS lab project**!
This repository documents my **step-by-step journey** building a **3-Tier Employee Directory Web Application** on AWS — with every resource fully provisioned using Infrastructure as Code.

---

## 📌 Project Overview

The goal of this project is to **design, provision, and scale** a production-style cloud application using **Terraform** to automate every part of the build.

Instead of manually clicking through the AWS Console, this project uses **`.tf` configuration files** and the Terraform CLI to:

* Deploy
* Test
* Tear down
* Re-deploy

…in a **repeatable** and **version-controlled** way.

---

## 🎯 Objective

Build a **secure**, **scalable**, and **highly available** Employee Directory web application — fully managed by Terraform.

---

## 🛠️ Infrastructure Stack (Provisioned via Terraform)

* **Amazon EC2** – Compute for Flask web server
* **Amazon S3** – Stores employee profile photos
* **Amazon DynamoDB** – NoSQL database for employee data
* **IAM** – Roles, policies, and least-privilege access
* **Amazon VPC** – Custom networking with public/private subnets
* **Elastic Load Balancer** – Distributes traffic across multiple AZs
* **EC2 Auto Scaling** – Automatically scales based on demand
* **\[Planned] API Gateway + Lambda** – Serverless contact form feature

---

## 🗂️ Module Overview

This Terraform project is divided into **6 modules**, each mapped to a core AWS concept:

1. **IAM** — Users, groups, roles, MFA
2. **EC2** — Hosting the application on a virtual server
3. **VPC** — Custom networking with public/private subnets
4. **S3** — Storing profile images with restricted access
5. **DynamoDB** — Persistent data storage for the app
6. **Monitoring & Scaling** — Load balancing and auto scaling

Each module includes:

* `main.tf` – Core resource definitions
* `variables.tf` – Configurable inputs
* `outputs.tf` – Key resource outputs
* Documentation notes + CLI commands

---

# 📋 Portfolio Build Checklist

This checklist blends **technical decisions**, **variables to define**, and **Terraform Registry research targets**.
Use it as a **scavenger hunt**:

1. Create the variables
2. Search the AWS provider docs for the resource/data source
3. Implement in Terraform
4. Validate via AWS CLI/Console

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

**Docs to read**

* `aws provider`
* `terraform backend s3`
* `terraform state locking dynamodb`
* `terraform workspaces`
* `terraform input variables / outputs / locals`

**Validate**

* `terraform init` with backend works; state file in S3; lock table in DynamoDB.

---

## 🔐 Module 1 — IAM

**Decisions**

* Users: `AdminUser`, `DevUser`
* Group: `EC2Admins` (start broad, later least-privilege)
* EC2 role: `EmployeeWebAppRole`
* Start with AWS managed policies for S3 + DynamoDB

**Variables**

* `admin_user_name`
* `dev_user_name`
* `iam_group_name`
* `ec2_role_name`
* `managed_policy_arns` (list, optional)

**Docs to read**

* `aws_iam_user`
* `aws_iam_group`
* `aws_iam_group_policy_attachment`
* `aws_iam_role` (assume role policy)
* `aws_iam_instance_profile`

**Validate**

* `aws iam list-users`
* `aws iam list-roles`
* Role trust principal = `ec2.amazonaws.com`.

---

## 🌐 Module 2 — EC2

**Decisions**

* AMI (Amazon Linux 2023)
* Instance type (`t2.micro`)
* User data script path
* Security group: HTTP/HTTPS only
* Attach instance profile from IAM module

**Variables**

* `instance_name`
* `instance_type`
* `ami_id` or `data aws_ami` lookup
* `user_data_path`
* `web_ingress_cidrs` (list)
* `vpc_id`, `subnet_id`

**Docs to read**

* `aws_instance`
* `aws_security_group`
* `data aws_ami`
* `user_data vs user_data_replace_on_change`

**Validate**

* `terraform output ec2_public_ip`
* `curl http://<public-ip>` loads app.

---

## 🏗️ Module 3 — VPC & Networking

**Decisions**

* VPC CIDR: `10.1.0.0/16`
* 2 AZs (`eu-west-2a`, `eu-west-2b`)
* Public subnets: `10.1.1.0/24`, `10.1.3.0/24`
* Private subnets: `10.1.2.0/24`, `10.1.4.0/24`

**Variables**

* `vpc_cidr`
* `azs` (list)
* `public_subnet_cidrs`
* `private_subnet_cidrs`
* `enable_nat_gateway` (optional)

**Docs to read**

* `aws_vpc`
* `aws_subnet`
* `aws_internet_gateway`
* `aws_route_table` / `aws_route_table_association`

**Validate**

* Public subnets map public IPs; internet access works.

---

## 🪣 Module 4 — S3

**Decisions**

* Unique bucket name
* Block public access
* Bucket policy: allow only EC2 role to Put/Get

**Variables**

* `photos_bucket_name`
* `bucket_force_destroy`

**Docs to read**

* `aws_s3_bucket`
* `aws_s3_bucket_policy`
* `aws_s3_bucket_public_access_block`

**Validate**

* App upload works; bucket private.

---

## 📄 Module 5 — DynamoDB

**Decisions**

* Table name: `Employees`
* Partition key: `id` (String)
* Billing mode: `PAY_PER_REQUEST`

**Variables**

* `ddb_table_name`
* `ddb_hash_key`
* `ddb_billing_mode`

**Docs to read**

* `aws_dynamodb_table`
* `aws_iam_policy` (least-privilege CRUD)

**Validate**

* Employee added → record in DynamoDB.

---

## ⚖️ Module 6 — ALB + Auto Scaling

**Decisions**

* ALB: internet-facing, 2 subnets
* Target group: HTTP, health check `/`
* Launch template for EC2
* ASG desired/min/max: `2/2/4`
* Scaling policy: target CPU 60%

**Variables**

* `alb_name`
* `target_group_name`
* `health_check_path`
* `launch_template_name`
* `asg_desired`, `asg_min`, `asg_max`
* `cpu_target_utilization`

**Docs to read**

* `aws_lb`
* `aws_lb_target_group`
* `aws_launch_template`
* `aws_autoscaling_group`
* `aws_autoscaling_policy`

**Validate**

* ALB DNS works; ASG scales under load.

---

## 📦 App Config (User Data / Env)

**Decisions**

* Env vars: `PHOTOS_BUCKET`, `AWS_DEFAULT_REGION`, `DYNAMO_MODE`
* Store script in `scripts/` folder

**Variables**

* `app_env` (map)
* `user_data_path`

**Docs to read**

* `terraform templatefile`
* `aws_instance user_data`
* `aws_launch_template user_data`

**Validate**

* `printenv` shows expected vars in instance.

---

## 🧠 State, Environments, Quality

**Decisions**

* State bucket/key per env
* Lock table name
* Workspaces vs per-env folders
* Formatting & validation before apply

**Variables**

* `state_bucket`, `state_key`, `state_dynamodb_table`
* `owner`, `cost_center`

**Docs to read**

* `backend "s3"`
* `terraform workspaces`
* `terraform fmt` / `terraform validate`

**Validate**

* Separate state for dev/prod; fmt/validate pass.

---

## 🏷️ Tagging & Naming

**Decisions**

* Consistent `default_tags`
* Name prefix pattern

**Variables**

* `name_prefix`
* `default_tags` (map)

**Docs to read**

* `provider "aws" default_tags`
* `terraform locals`

**Validate**

* All resources tagged consistently.
