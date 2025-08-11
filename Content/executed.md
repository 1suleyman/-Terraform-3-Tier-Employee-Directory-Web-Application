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

**Screenshots to Capture:**

* [ ] S3 bucket details page (showing versioning enabled)
* [ ] DynamoDB table details (showing primary key)

**Tests & Verification:**

* [ ] Confirmed S3 bucket exists in AWS Console.
* [ ] Confirmed DynamoDB table exists with correct key schema.

**Cleanup Steps:**

* [ ] Delete bucket and table if project is destroyed.

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

**Screenshots to Capture:**

* [ ] `terraform init` output showing backend connected.
* [ ] Workspace list showing `dev` and `prod`.

**Tests & Verification:**

* [ ] Ran `terraform init` and confirmed backend connected.
* [ ] Verified workspaces for `dev` and `prod`.

**Cleanup Steps:**

* [ ] None needed — provider and backend stay in place.

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

**Screenshots to Capture:**

* [ ] IAM Users list.
* [ ] IAM Group details (policies attached).
* [ ] IAM Role trust policy.

**Tests & Verification:**

* [ ] Checked IAM Console for users, group, and role.
* [ ] Confirmed EC2 role has correct permissions.

**Cleanup Steps:**

* [ ] Remove users/roles/groups after project.

---

## 🌐 Module 3 — EC2

**Goal:** Launch EC2 instance with Amazon Linux 2023, HTTP/HTTPS SG, and IAM profile.

**Steps Taken:**

* [ ] Created security group allowing HTTP/HTTPS.
* [ ] Used `data aws_ami` to fetch Amazon Linux 2023 AMI.
* [ ] Attached IAM instance profile from Module 2.
* [ ] Applied user\_data script.

**Terraform Snippets:**

```hcl
# Paste relevant snippet here
```

**Screenshots to Capture:**

* [ ] EC2 instance list showing correct tags.
* [ ] Security group inbound rules.
* [ ] User Data script in Launch Template (if applicable).

**Tests & Verification:**

* [ ] Accessed EC2 public IP in browser and saw Flask app.
* [ ] SSH/EC2 Connect into instance to verify packages.

**Cleanup Steps:**

* [ ] Terminate instances after testing.

---

## 🏗️ Module 4 — VPC & Networking

**Goal:** Create custom VPC with public/private subnets, IGW, and route tables.

**Steps Taken:**

* [ ] Created VPC with CIDR `10.1.0.0/16`.
* [ ] Added 2 AZs with public/private subnets.
* [ ] Attached IGW and updated route tables.

**Terraform Snippets:**

```hcl
# Paste relevant snippet here
```

**Screenshots to Capture:**

* [ ] VPC overview in AWS Console.
* [ ] Subnets list (public/private tags).
* [ ] Route tables with correct associations.

**Tests & Verification:**

* [ ] Confirmed public subnets have internet access.
* [ ] Confirmed private subnets route internally.

**Cleanup Steps:**

* [ ] Remove VPC and networking resources after project.

---

## 🪣 Module 5 — S3

**Goal:** Create S3 bucket for profile photos with restricted access.

**Steps Taken:**

* [ ] Created bucket with public access blocked.
* [ ] Added bucket policy for EC2 role only.

**Terraform Snippets:**

```hcl
# Paste relevant snippet here
```

**Screenshots to Capture:**

* [ ] S3 bucket policy page.
* [ ] Public access block settings.

**Tests & Verification:**

* [ ] Upload test file via EC2.
* [ ] Verify only EC2 role can access.

**Cleanup Steps:**

* [ ] Delete bucket and objects after testing.

---

## 📄 Module 6 — DynamoDB

**Goal:** Create DynamoDB table for employee records.

**Steps Taken:**

* [ ] Created `Employees` table with `id` as PK.

**Terraform Snippets:**

```hcl
# Paste relevant snippet here
```

**Screenshots to Capture:**

* [ ] DynamoDB table overview.
* [ ] Item view showing sample data.

**Tests & Verification:**

* [ ] Insert and read record via app.

**Cleanup Steps:**

* [ ] Delete table after project.

---

## ⚖️ Module 7 — ALB + Auto Scaling

**Goal:** Add load balancing and auto scaling for high availability.

**Steps Taken:**

* [ ] Created ALB across 2 public subnets.
* [ ] Created target group and health checks.
* [ ] Created launch template for EC2.
* [ ] Created ASG with target tracking policy.

**Terraform Snippets:**

```hcl
# Paste relevant snippet here
```

**Screenshots to Capture:**

* [ ] ALB DNS in AWS Console.
* [ ] Target group health status.
* [ ] ASG scaling activity.

**Tests & Verification:**

* [ ] Stress test to trigger scaling.
* [ ] Verify load balancer distributes traffic.

**Cleanup Steps:**

* [ ] Delete ALB, ASG, and launch template after project.

---

## 🔍 Why Document Execution?

Writing this log was part of my **learn-by-building** approach.
I didn’t just read Terraform docs — I **coded, deployed, tested, broke things, fixed them**, and learned why each resource mattered.

If you’re learning Terraform, prepping for the **Terraform Associate** exam, or building similar AWS stacks — this execution log is for you.

