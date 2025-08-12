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

## 🛠️ Module 0 — Local & Remote State Setup

### **📂 Phase A – Bootstrap (Local State)**

**Goal:** Provision the Terraform remote state infrastructure (S3 + DynamoDB) using **local state first**.

**Steps Taken:**

* Created **`variables.tf`** defining:

  * `state_bucket_name` → name for S3 bucket
  * `state_dynamodb_table` → name for DynamoDB lock table
  * `aws_region` → AWS region
  * `tags` → default project tags

* Wrote **`main.tf`** to:

  * Create an **S3 bucket** with:

    * Versioning **Enabled** ✅ (undo button for deleted/overwritten state)
    * `force_destroy = false` (safe default)
    * Public access blocked
  * Create a **DynamoDB table** with:

    * Primary key: `LockID` (String) ✅ (acts as a "Do Not Disturb" sign during applies)

* Ran:

  ```bash
  terraform init   # using local state
  terraform apply
  ```

* Verified in AWS Console:

  * S3 bucket exists in `${var.aws_region}`
  * DynamoDB table exists with correct schema

---

### **📂 Phase B – Switch to Remote State**

**Goal:** Migrate Terraform to use S3 for state storage + DynamoDB for state locking.

**Steps Taken:**

* In **Phase\_B** folder, created `versions.tf`:

  ```hcl
  terraform {
    backend "s3" {}
  }
  ```

  *(Values supplied at init time via `-backend-config`)*

* Created **`backend.hcl`**:

  ```hcl
  bucket         = "tf-state-employee-directory"
  key            = "envs/dev/terraform.tfstate"
  region         = "eu-west-2"
  dynamodb_table = "tf-state-locks"
  encrypt        = true
  ```

* Ran migration:

  ```bash
  terraform init -backend-config=backend.hcl -reconfigure
  ```

* Confirmed state successfully moved to S3 bucket.

---

### **✅ Validation Checklist**

* [x] S3 bucket created in correct region

<img width="614" height="183" alt="Screenshot 2025-08-12 at 09 59 46" src="https://github.com/user-attachments/assets/4e044115-8c79-4fee-befd-ca24abf0283b" />

* [x] Versioning **enabled**

<img width="954" height="157" alt="Screenshot 2025-08-12 at 10 00 50" src="https://github.com/user-attachments/assets/27c1153c-21f2-43f5-8ce9-849775493749" />

* [x] DynamoDB table **LockID (String)** schema 

<img width="414" height="179" alt="Screenshot 2025-08-12 at 10 01 55" src="https://github.com/user-attachments/assets/e11e3565-bde7-4474-ba6f-ad52fad63f24" />

* [x] Terraform applies lock when concurrent changes are attempted

<img width="276" height="39" alt="Screenshot 2025-08-12 at 10 41 40" src="https://github.com/user-attachments/assets/0c319463-999e-4f0a-b5db-352b3d7b73d6" />

---

### **💡 Lessons Learned**

1. **Backend vars can’t use `${var.*}`** — must pass via `-backend-config` or `.hcl` file.
2. DynamoDB locking is still valid (not deprecated), but S3 alone works if you don’t need locking.
3. Always bootstrap S3/DynamoDB with **local state** to avoid chicken-and-egg issues.
4. Versioning in S3 is essential for recovering broken state files.
5. `-migrate-state` cleanly moves state between local and remote without manual file copying.
Alright — here’s the **reverse migration process** (Remote → Local) in the same style, so your executed.md for **Module 0** will have **both directions** documented.

---

## Bonus 🔄 Phase B → Phase A — Switching Back to Local State

**Goal:** Detach Terraform from the remote backend (S3 + DynamoDB) and revert to using a **local state file**.
This is useful for:

* Testing changes without touching shared state
* Cleaning up or deleting the S3/DynamoDB infrastructure without breaking Terraform

---

### **Steps Taken**

1. **Removed backend block** from config in Phase\_A:

   ```hcl
   # Removed backend "s3" block so Terraform defaults to local backend
   ```

2. **Re-initialized with migration to local:**

   ```bash
   terraform init -migrate-state
   ```

   * Terraform detected the **S3 backend** was being unset.
   * Chose `yes` when prompted to copy state from remote to local.

3. **Validation:**

   ```bash
   terraform state list
   ```

   Output still showed existing resources:

   ```
   aws_dynamodb_table.terraform_locks
   aws_s3_bucket.terraform_state
   aws_s3_bucket_public_access_block.terraform_state
   aws_s3_bucket_versioning.terraform_state
   ```

   ✅ Confirms state was copied locally — no dependency on remote bucket.

4. **Checked S3 bucket in AWS Console** — state file was still present (important: migration does not delete the remote copy automatically).

---

### **✅ Validation Checklist**

* [x] `terraform plan` works locally without backend errors
* [x] Local `terraform.tfstate` file created in project directory
* [x] Remote state file in S3 remains intact (manual deletion if needed)

---

### **💡 Lessons Learned**

1. **Remote → Local doesn’t delete S3 state file** — clean it up manually if needed.
2. Use `-migrate-state` when moving **from** a backend; use `-reconfigure` when changing backend settings without copying state.
3. Keep a backup of the `.tfstate` file before migrations, just in case.
4. You can confirm which backend is active by checking `.terraform/terraform.tfstate` metadata.

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

