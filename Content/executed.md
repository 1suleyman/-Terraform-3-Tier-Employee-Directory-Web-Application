# 🛠️ Project Execution: Terraform 3-Tier Employee Directory Application

Welcome to the **hands-on execution log** of my Terraform 3-Tier Employee Directory Web Application project.

This file documents **what I actually did** — from Module 0 (state setup) through Module 7 (ALB + Auto Scaling) — including:

✅ **Terraform commands run** (`init`, `plan`, `apply`)
📜 **Snippets of `.tf` code** for each AWS resource
🖼️ **Screenshots** from AWS Console for visual proof
🧪 **Tests and validations** of deployed infrastructure
💡 **Lessons learned** and troubleshooting notes
📦 **Cleanup** steps after each module to save costs

---

## 📋 Execution Modules

* **Module 0** – Local & Remote State Setup (S3 + DynamoDB)
* **Module 1** – Global Project Setup (Provider, Tags, Variables)
* **Module 2** – IAM (Users, Groups, Roles, Policies)
* **Module 3** – EC2 (Web Server Deployment)
* **Module 4** – VPC & Networking
* **Module 5** – S3 (Profile Photo Storage)
* **Module 6** – DynamoDB (Employee Records)
* **Module 7** – ALB + Auto Scaling

---

## 🛠️ Module 0 — Local & Remote State Setup

**🎯 Goal**
Set up Terraform’s “memory” (state) to live in S3, with a DynamoDB lock to prevent multiple applies at once — all provisioned **with Terraform itself** in a bootstrap phase.

---

### **Terraform Steps Taken**

**📂 Phase A – Bootstrap (Local State)**

* Created **`variables.tf`** defining:

  * `state_bucket_name` — name for S3 bucket
  * `state_dynamodb_table` — name for DynamoDB lock table
  * `aws_region` — AWS region
  * `tags` — default project tags

* Wrote **`main.tf`** to:

  * Create an **S3 bucket** with:

    * `Versioning: Enabled` ✅ (undo button)
    * `force_destroy = false` (safe default for now)
  * Create a **DynamoDB table** with:

    * Primary key: `LockID` (String) ✅ (do not disturb sign)

* Ran:

  ```bash
  terraform init   # local state
  terraform apply
  ```

* Verified in AWS Console:

  * S3 bucket exists in `${var.aws_region}`
  * DynamoDB table exists with correct schema

---

**📂 Phase B – Switch to Remote State**

* Added **`backend "s3"`** block in `main.tf` pointing to:

  * `bucket = "<${var.state_bucket_name}>"`
  * `key    = "envs/dev/terraform.tfstate"`
  * `region = "${var.aws_region}"`
  * `dynamodb_table = "<${var.state_dynamodb_table}>"`
* Created `backend.hcl` file with these values (because variables can’t be used inside backend).
* Ran:

  ```bash
  terraform init -backend-config=backend.hcl -reconfigure
  ```
* Migrated local state to S3 successfully.

---

### **✅ Validation Checklist**

* [ ] S3 bucket created in correct region
* [ ] Versioning **enabled**
* [ ] DynamoDB table has **PK: LockID (String)**
* [ ] Terraform backend points to S3 + DynamoDB without errors
* [ ] Lock record appears in DynamoDB during `terraform apply`

---

### **📚 Lessons Learned**

* **Backend vars limitation:** Terraform doesn’t allow variables in the backend block — solved with `backend.hcl`.
* **Bucket naming:** S3 bucket names are **global** — had to make name unique.
* **Deletion caution:** For cleanup later, will need `force_destroy = true` or empty the bucket first.
* **Versioning is priceless:** Already saw how it could save the state file if something goes wrong.

---

## 🌍 Module 1 — Global Project Setup

**Goal:**
Configure AWS provider, default tags, and global variables.

**Terraform Steps Taken:**

1. Defined variables in `variables.tf`:

   * `aws_region`
   * `project_name`
   * `environment`
   * `tags`
2. Configured AWS provider block with default tags.
3. Tested provider connection:

   ```bash
   terraform plan
   ```

**Validation Checklist:**

* [ ] Provider loads correct region
* [ ] Tags applied to all resources

**Lessons Learned:**
*(Write after running)*

---

## 🔐 Module 2 — IAM

**Goal:**
Create IAM users, group, EC2 role, and attach policies.

**Terraform Steps Taken:**

* Created `iam.tf` to define:

  * Users `${var.admin_user_name}` & `${var.dev_user_name}`
  * Group `${var.iam_group_name}`
  * Role `${var.ec2_role_name}` with EC2 trust
  * Managed policies from variables
  * Instance profile

**Validation Checklist:**

* [ ] Users visible in AWS IAM
* [ ] Group with correct policies exists
* [ ] Role attached to EC2 instance profile

---

## 🌐 Module 3 — EC2

**Goal:**
Launch EC2 instance for the Flask app with IAM role and security group.

**Terraform Steps Taken:**

* Used `data "aws_ami"` to find Amazon Linux 2023.
* Created `aws_instance` with:

  * `user_data` from `scripts/user_data.sh`
  * IAM instance profile from Module 2
* Allowed HTTP/HTTPS inbound from `${var.web_ingress_cidrs}`

**Validation Checklist:**

* [ ] EC2 launches without errors
* [ ] App accessible via public IP
* [ ] IAM role attached correctly

---

## 🏗️ Module 4 — VPC & Networking

**Goal:**
Deploy custom VPC with public/private subnets, IGW, and route tables.

**Terraform Steps Taken:**

* Created `vpc.tf` for:

  * VPC with CIDR `${var.vpc_cidr}`
  * Public/private subnets
  * Internet Gateway
  * Public route table associations

**Validation Checklist:**

* [ ] Subnets correctly tagged as public/private
* [ ] Public subnet has internet access

---

## 🪣 Module 5 — S3

**Goal:**
Set up S3 bucket for employee profile photos, restricted to EC2 role.

**Terraform Steps Taken:**

* Created `s3.tf`:

  * S3 bucket `${var.photos_bucket_name}`
  * Public access blocked
  * Bucket policy allowing only `${var.ec2_role_name}` to Put/Get

**Validation Checklist:**

* [ ] Bucket exists and blocks public access
* [ ] EC2 can upload & retrieve photos

---

## 📄 Module 6 — DynamoDB

**Goal:**
Store employee records in DynamoDB table with PAY\_PER\_REQUEST billing.

**Terraform Steps Taken:**

* Created `dynamodb.tf`:

  * Table `${var.ddb_table_name}` with key `${var.ddb_hash_key}`
  * IAM policy for EC2 CRUD access

**Validation Checklist:**

* [ ] Table exists in AWS
* [ ] App can read/write records

---

## ⚖️ Module 7 — ALB + Auto Scaling

**Goal:**
Add load balancer and scale EC2 instances automatically.

**Terraform Steps Taken:**

* Created `alb.tf` and `asg.tf`:

  * ALB in public subnets
  * Target group for app
  * Launch template for EC2
  * Auto Scaling Group with CPU target policy

**Validation Checklist:**

* [ ] ALB distributes traffic evenly
* [ ] Auto scaling triggers on CPU load

---

## 🔍 Why Document Execution?

Writing this log was part of my **learn-by-building** approach.
I didn’t just read Terraform docs — I **coded, deployed, tested, broke things, fixed them**, and learned why each resource mattered.

If you’re learning Terraform, prepping for the **Terraform Associate** exam, or building similar AWS stacks — this execution log is for you.

