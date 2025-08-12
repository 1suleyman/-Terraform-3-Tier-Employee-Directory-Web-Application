# 📋 Planned Terraform 3-Tier Employee Directory Web Application

This is my **blueprint** for building a Terraform-powered AWS 3-Tier Employee Directory Application.
It includes:

* **Architecture & decisions** – what I want to build and why.
* **Variables to define** – so configs are reusable.
* **Terraform Registry research targets** – to understand the syntax.
* **AI Prompt Templates** – so I can quickly generate boilerplate Terraform code, then fill in my specific variables.

---

## 🛠️ Module 0 — Local & Remote State Setup (Terraform-First, Two-Phase)

### What & Why (in plain English)

* **Terraform needs a memory.** That “memory” is the **state file**.
* We’ll store that memory in **S3** (safe, shareable) and prevent collisions with a **DynamoDB lock** (like a “Room in Use” sign).
* To avoid a chicken-and-egg problem, we’ll **create the S3 bucket and DynamoDB table with Terraform using local state first**, then **switch** Terraform to use them.

### Two-Phase Plan

* **Phase A – Bootstrap (local state):**
  Use Terraform to **create** the S3 bucket (with versioning) and the DynamoDB lock table. Terraform state is still local on your machine.
* **Phase B – Migrate (remote state):**
  Point your main Terraform project to the **S3 bucket + DynamoDB table** and **migrate state**. From now on, Terraform uses remote state.

---

### Decisions

* **S3 bucket for state** (e.g., `tf-state-employee-directory`)
  *Why:* Think of it as a **shared notebook** where Terraform writes what exists.
* **Versioning enabled**
  *Why:* It’s your **undo button** if the notebook gets corrupted.
* **DynamoDB table for locking** (e.g., `tf-state-locks`, PK: `LockID`)
  *Why:* A **“Do Not Disturb”** sign so two applies can’t collide.
* **Naming uses project + env**
  *Why:* Like labels on moving boxes — instantly recognizable.

---

### Variables

* `state_bucket_name` — S3 bucket for Terraform state
* `state_dynamodb_table` — DynamoDB table for locking
* `aws_region` — Region for both resources
* `tags` — Default tags to apply

---

### Docs to Read (Why)

* **`aws_s3_bucket`** – Create the state bucket (the notebook)
* **`aws_s3_bucket_versioning`** – Turn on the undo button
* **`aws_dynamodb_table`** – Create the lock table (the sign)
* **`terraform backend s3`** – How Terraform uses S3 + DynamoDB for state & locks

---

### AI Prompt Templates

**Phase A – Bootstrap resources (local state):**

> Generate Terraform configuration that creates:
>
> 1. An S3 bucket `${var.state_bucket_name}` in `${var.aws_region}` with versioning enabled and public access blocked, tagged with `${var.tags}`.
> 2. A DynamoDB table `${var.state_dynamodb_table}` with primary key `LockID` (string) for state locking, tagged with `${var.tags}`.
>    Use variables for names, region, and tags. Do **not** configure a remote backend in this bootstrap — it should run with local state.

**Phase B – Switch Terraform to remote state:**

> Generate Terraform configuration (or init command guidance) to configure the `backend "s3"` to use:
>
> * `bucket = "<same as ${var.state_bucket_name}>"`
> * `key = "envs/dev/terraform.tfstate"`
> * `region = "${var.aws_region}"`
> * `dynamodb_table = "<same as ${var.state_dynamodb_table}>"`
>   Explain that variables cannot be used inside the backend block; provide a `backend.hcl` example and the `terraform init -backend-config=backend.hcl -reconfigure` command.

---

### Definition of Done (checklist)

* [ ] **Phase A applied:** S3 bucket exists and shows **Versioning: Enabled**
* [ ] **Phase A applied:** DynamoDB table exists with **PK: LockID (String)**
* [ ] **Phase B migrated:** `terraform init` connects to S3 backend & DynamoDB locks
* [ ] **State lives in S3:** State object appears at `envs/dev/terraform.tfstate`
* [ ] **Locking works:** A `terraform apply` briefly creates a lock item in DynamoDB

---

### Common Pitfalls (and fixes)

* **Bucket name already taken:** S3 names are global → choose a more specific name.
* **Trying to use variables inside backend:** Not supported → use `backend.hcl` and `-backend-config`.
* **Destroying versioned bucket later:** Empty or lifecycle-clean first, or `force_destroy` if appropriate.
* **Wrong region mismatch:** Bucket’s region must match the backend `region` you configure.

---

## 🌍 Module 1 — Global Project Setup

**Decisions**

* **Naming convention:** `employee-<env>-<component>`
  *Why:* Keeps things organised — like putting labels on storage boxes.

* **Environments:** dev, prod (via workspaces or folders)
  *Why:* Test safely before touching production — like practising on a spare car before driving your main one.

* **Remote state:** S3 backend + DynamoDB locking (from Module 0)
  *Why:* Shared, safe Terraform state.

* **Tagging standard:** Project, Environment, Owner, CostCenter
  *Why:* Tags are AWS’s sticky notes — helps with cost tracking and clean-up.

**Variables**

* `aws_region`
* `project_name`
* `environment`
* `tags` (map)

**Docs to Read (Why)**

* **aws provider** – Terraform needs to know which cloud/region to talk to.
* **terraform workspaces** – Manage dev/prod in one codebase.
* **terraform variables, outputs, locals** – Keep configs flexible and reusable.

**AI Prompt Template**

> Generate Terraform configuration to set up the AWS provider in region `${var.aws_region}`, with default tags `${var.tags}`, and configure a remote S3 backend with DynamoDB state locking. Include variables for `project_name`, `environment`, and `aws_region`.

---

## 🔐 Module 2 — IAM

**Decisions**

* **Users:** AdminUser, DevUser
  *Why:* Separate accounts = better security, like separate keys for each housemate.

* **Group:** EC2Admins
  *Why:* Easier to give/revoke permissions for a team.

* **EC2 Role:** EmployeeWebAppRole
  *Why:* Lets EC2 talk to S3 & DynamoDB without storing credentials.

* **Policies:** Start with AWS managed S3 + DynamoDB access
  *Why:* Managed policies are pre-made “permission sets” — start simple.

**Variables**

* `admin_user_name`
* `dev_user_name`
* `iam_group_name`
* `ec2_role_name`
* `managed_policy_arns` (list)

**Docs to Read (Why)**

* **aws\_iam\_user** – Create IAM users.
* **aws\_iam\_group** – Group users for shared permissions.
* **aws\_iam\_role** – Create roles for services like EC2.
* **aws\_iam\_instance\_profile** – Attach a role to an EC2 instance.

**AI Prompt Template**

> Generate Terraform AWS IAM configuration that creates:
>
> * Users `${var.admin_user_name}` and `${var.dev_user_name}`
> * Group `${var.iam_group_name}` with `${var.managed_policy_arns}` attached
> * Role `${var.ec2_role_name}` with EC2 trust and same policies
> * Instance profile bound to that role
>   Use variables and tagging from my global setup.

---

## 🌐 Module 3 — EC2

**Decisions**

* **AMI:** Amazon Linux 2023
  *Why:* Stable, lightweight, AWS-optimised.

* **Instance type:** t2.micro
  *Why:* Fits free tier & testing needs.

* **Security group:** Allow HTTP/HTTPS only
  *Why:* Minimal access = better security.

* **Attach IAM instance profile:** From Module 2
  *Why:* Lets app access AWS services securely.

**Variables**

* `instance_name`
* `instance_type`
* `ami_id` or `data aws_ami` lookup
* `user_data_path`
* `web_ingress_cidrs` (list)
* `vpc_id`, `subnet_id`

**Docs to Read (Why)**

* **aws\_instance** – Launch EC2 instances.
* **aws\_security\_group** – Control traffic in/out.
* **data aws\_ami** – Look up latest Amazon Linux image.

**AI Prompt Template**

> Generate Terraform AWS EC2 configuration that launches:
>
> * An instance `${var.instance_name}` in `${var.subnet_id}` with `${var.instance_type}`
> * Using AMI from data source for Amazon Linux 2023
> * With SG allowing HTTP/HTTPS from `${var.web_ingress_cidrs}`
> * Attaching IAM profile `${var.ec2_instance_profile}`
> * Running user\_data script from `${var.user_data_path}`
>   Output the instance public IP.

---

## 🏗️ Module 4 — VPC & Networking

**Decisions**

* **CIDR:** 10.1.0.0/16
  *Why:* Gives plenty of private IPs.

* **2 AZs:** eu-west-2a, eu-west-2b
  *Why:* High availability if one AZ fails.

* **Public/Private subnets:** Separation = security.

* **Internet Gateway + Public Route Table**
  *Why:* Lets public subnets talk to the internet.

**Variables**

* `vpc_cidr`
* `azs` (list)
* `public_subnet_cidrs` (list)
* `private_subnet_cidrs` (list)
* `enable_nat_gateway`

**Docs to Read (Why)**

* **aws\_vpc** – Create isolated network.
* **aws\_subnet** – Divide VPC into sections.
* **aws\_internet\_gateway** – Allow internet access.
* **aws\_route\_table** – Control routing rules.

**AI Prompt Template**

> Generate Terraform AWS VPC configuration for:
>
> * CIDR `${var.vpc_cidr}`
> * Public subnets `${var.public_subnet_cidrs}` & private subnets `${var.private_subnet_cidrs}`
> * Internet gateway & public route table associated with public subnets
>   Include variable inputs and tags from my global setup.

---

## 🪣 Module 5 — S3

**Decisions**

* **Unique bucket name**
  *Why:* S3 bucket names are global — like email addresses.

* **Block public access**
  *Why:* Avoid leaking data to the internet.

* **Allow only EC2 role to Put/Get**
  *Why:* Enforces least-privilege access.

**Variables**

* `photos_bucket_name`
* `bucket_force_destroy`

**Docs to Read (Why)**

* **aws\_s3\_bucket** – Create bucket for photo storage.
* **aws\_s3\_bucket\_policy** – Limit access to EC2 role.
* **aws\_s3\_bucket\_public\_access\_block** – Block public access.

**AI Prompt Template**

> Generate Terraform AWS S3 configuration for:
>
> * Bucket `${var.photos_bucket_name}` with public access blocked
> * Bucket policy allowing only IAM role `${var.ec2_role_name}` to Put/Get objects
> * force\_destroy set to `${var.bucket_force_destroy}`

---

## 📄 Module 6 — DynamoDB

**Decisions**

* **Table:** Employees
  *Why:* Stores employee data in NoSQL format.

* **Partition key:** id (String)
  *Why:* Simple, unique identifier.

* **Billing mode:** PAY\_PER\_REQUEST
  *Why:* Only pay when you use it.

**Variables**

* `ddb_table_name`
* `ddb_hash_key`
* `ddb_billing_mode`

**Docs to Read (Why)**

* **aws\_dynamodb\_table** – Create database table.
* **aws\_iam\_policy** – Give EC2 CRUD access to table.

**AI Prompt Template**

> Generate Terraform AWS DynamoDB configuration for:
>
> * Table `${var.ddb_table_name}` with hash key `${var.ddb_hash_key}` (String)
> * Billing mode `${var.ddb_billing_mode}`
> * Tagged with my global tags

---

## ⚖️ Module 7 — ALB + Auto Scaling

**Decisions**

* **ALB:** Internet-facing, 2 subnets
  *Why:* Spreads traffic for reliability.

* **Target group:** HTTP on /
  *Why:* Routes traffic to web app.

* **Launch template:** For EC2 app instances
  *Why:* Standardised instance config.

* **ASG:** desired/min/max = 2/2/4
  *Why:* Always have redundancy, scale on demand.

* **Scaling policy:** Target CPU 60%
  *Why:* Keeps servers busy but not overloaded.

**Variables**

* `alb_name`
* `target_group_name`
* `health_check_path`
* `launch_template_name`
* `asg_desired`, `asg_min`, `asg_max`
* `cpu_target_utilization`

**Docs to Read (Why)**

* **aws\_lb** – Create load balancer.
* **aws\_lb\_target\_group** – Group backend instances.
* **aws\_launch\_template** – Define EC2 config for ASG.
* **aws\_autoscaling\_group** – Manage group of instances.
* **aws\_autoscaling\_policy** – Set scaling rules.

**AI Prompt Template**

> Generate Terraform AWS ALB + Auto Scaling configuration for:
>
> * ALB `${var.alb_name}` across `${var.public_subnet_ids}`
> * Target group `${var.target_group_name}` with health check path `${var.health_check_path}`
> * Launch template `${var.launch_template_name}`
> * ASG desired/min/max = `${var.asg_desired}`, `${var.asg_min}`, `${var.asg_max}`
> * Target tracking scaling policy for `${var.cpu_target_utilization}`% CPU

