# 🛠️ Executed — Terraform 3-Tier Employee Directory Web Application

This is my **hands-on execution log** for building the Terraform-powered AWS 3-Tier Employee Directory App.
It mirrors my `PLANNED.md` file so I can track:

* ✅ What I actually built
* 📜 Snippets of `.tf` code used
* 🖼️ AWS Console screenshots
* 🧪 Test results
* 🔧 Fixes applied when something didn’t work
* 📦 Cleanup steps after each module

---

## 🛠️ Module 0 — Local Prerequisites

**Goal:** Create S3 bucket for remote state and DynamoDB table for state locking.

**Steps Taken:**

* [ ] Created S3 bucket: `tf-state-employee-directory` in `${aws_region}` with versioning enabled.
* [ ] Created DynamoDB table: `tf-state-locks` with `LockID` as primary key.

**Terraform/CLI Snippets:**

```hcl
# Paste relevant snippet here after execution
```

**Tests & Verification:**

* [ ] Confirmed S3 bucket exists in AWS Console.
* [ ] Confirmed DynamoDB table exists with correct key schema.

**Notes / Issues:**

* Add troubleshooting notes here.

---

## 🌍 Module 1 — Global Project Setup

**Goal:** Configure AWS provider, default tags, and remote S3 backend with DynamoDB locking.

**Steps Taken:**

* [ ] Created `provider.tf` with AWS provider in `${var.aws_region}`.
* [ ] Configured backend to use S3 + DynamoDB locking.
* [ ] Defined global variables (`aws_region`, `project_name`, `environment`, `tags`).

**Terraform/CLI Snippets:**

```hcl
# Paste relevant snippet here after execution
```

**Tests & Verification:**

* [ ] Ran `terraform init` and confirmed backend connected.
* [ ] Verified workspaces for `dev` and `prod`.

**Notes / Issues:**

---

## 🔐 Module 2 — IAM

**Goal:** Create IAM users, group, EC2 role, and instance profile.

**Steps Taken:**

* [ ] Created `AdminUser` and `DevUser`.
* [ ] Created `EC2Admins` group and attached policies.
* [ ] Created `EmployeeWebAppRole` for EC2.
* [ ] Attached role to instance profile.

**Terraform Snippets:**

```hcl
# Paste relevant snippet here
```

**Tests & Verification:**

* [ ] Checked IAM Console for users, group, and role.

**Notes / Issues:**

---

## 🌐 Module 3 — EC2

**Goal:** Launch EC2 instance with Amazon Linux 2023, HTTP/HTTPS SG, and IAM profile.

**Steps Taken:**

* [ ] Created security group allowing HTTP/HTTPS.
* [ ] Used `data aws_ami` to fetch Amazon Linux 2023 AMI.
* [ ] Attached IAM instance profile from Module 2.
* [ ] Applied user\_data script.

**Terraform Snippets:**

**Tests & Verification:**

* [ ] Accessed EC2 public IP in browser and saw Flask app.

**Notes / Issues:**

---

## 🏗️ Module 4 — VPC & Networking

**Goal:** Create custom VPC with public/private subnets, IGW, and route tables.

**Steps Taken:**

**Terraform Snippets:**

**Tests & Verification:**

**Notes / Issues:**

---

## 🪣 Module 5 — S3

**Goal:** Create S3 bucket for profile photos with restricted access.

**Steps Taken:**

**Terraform Snippets:**

**Tests & Verification:**

**Notes / Issues:**

---

## 📄 Module 6 — DynamoDB

**Goal:** Create DynamoDB table for employee records.

**Steps Taken:**

**Terraform Snippets:**

**Tests & Verification:**

**Notes / Issues:**

---

## ⚖️ Module 7 — ALB + Auto Scaling

**Goal:** Add load balancing and auto scaling for high availability.

**Steps Taken:**

**Terraform Snippets:**

**Tests & Verification:**

**Notes / Issues:**

---

## 🔍 Why Document Execution?

Writing this log was part of my **learn-by-building** approach.
I didn’t just read Terraform docs — I **coded, deployed, tested, broke things, fixed them**, and learned why each resource mattered.

If you’re learning Terraform, prepping for the **Terraform Associate** exam, or building similar AWS stacks — this execution log is for you.

