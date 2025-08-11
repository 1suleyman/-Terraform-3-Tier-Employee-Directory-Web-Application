# Project Execution: Terraform 3-Tier Employee Directory Application

Welcome to the **hands-on execution log** of my **Terraform 3-Tier Employee Directory Web Application** project.
This file documents the exact steps I took — from **IAM setup to Auto Scaling** — to bring this application to life on AWS entirely using **Terraform**.

Think of this as a **behind-the-scenes build journal** that tracks not just what I *planned* to do — but what I actually **coded**, **applied**, **validated**, and **learned**.

---

## 🧠 What You’ll Find Here

* ✅ Completed modules with **verified Terraform deployments**
* 📜 **Snippets of `.tf` code** for each AWS resource
* 🖼️ **Screenshots** from AWS Console for visual proof
* 🧪 **Tests and validations** of deployed infrastructure
* 📦 **Cleanup and cost-saving** steps after each module

---

## 📋 Execution Modules

* 🚀 [**Module 1:** IAM Setup (Users, Groups, Roles, Policies, MFA)](#module-1-iam-setup) – [Planned.md → IAM Section](Planned.md#-module-1--iam)
* 🚀 [**Module 2:** Launching the App on EC2 (Networking, User Data, Web Server)](#module-2-launching-the-app-on-ec2) – [Planned.md → EC2 Section](Planned.md#-module-2--ec2)
* 🌐 [**Module 3:** Custom VPC with Subnets, Route Tables, and Re-deployment](#module-3-custom-vpc--re-deployment) – [Planned.md → VPC Section](Planned.md#-module-3--vpc--networking)
* 💾 [**Module 4:** S3 Bucket for Profile Photos + IAM Policy Integration](#module-4-s3-integration) – [Planned.md → S3 Section](Planned.md#-module-4--s3)
* 🗄️ [**Module 5:** DynamoDB Table Setup + Full CRUD Test via App UI](#module-5-dynamodb-integration) – [Planned.md → DynamoDB Section](Planned.md#-module-5--dynamodb)
* 📈 [**Module 6:** Load Balancing and EC2 Auto Scaling Configuration + Stress Test](#module-6-load-balancer--auto-scaling) – [Planned.md → ALB + Auto Scaling Section](Planned.md#-module-6--alb--auto-scaling)

---

## 🚀 Module 1: IAM Setup

[**Planned.md Reference → IAM Section**](Planned.md#-module-1--iam)

**Goal:** Create IAM roles, users, and groups entirely via Terraform.

**AI Prompt Used:**

```
[Paste your exact AI prompt here]
```

**Code Implemented (.tf snippet):**

```hcl
# Paste final Terraform snippet here
```

**terraform plan → apply output:**

```bash
# Paste relevant output
```

**AWS Console Screenshot:**
`[Insert screenshot]`

**Validation Steps:**

* [ ] `aws iam list-users` shows `AdminUser`, `DevUser`
* [ ] `aws iam list-roles` shows `EmployeeWebAppRole`
* [ ] Trust policy principal = `ec2.amazonaws.com`

**Issues & Fixes:**

* *Example:* Updated assume role policy JSON to match AWS policy syntax.

---

## 🚀 Module 2: Launching the App on EC2

[**Planned.md Reference → EC2 Section**](Planned.md#-module-2--ec2)

**Goal:** Deploy EC2 instance with user data to run Flask app.

**AI Prompt Used:**

```
[Paste your exact AI prompt here]
```

**Code Implemented (.tf snippet):**

```hcl
# Paste final Terraform snippet here
```

**terraform plan → apply output:**

```bash
# Paste relevant output
```

**AWS Console Screenshot:**
`[Insert screenshot]`

**Validation Steps:**

* [ ] `terraform output ec2_public_ip` returns live IP
* [ ] `curl http://<PUBLIC_IP>` loads app

**Issues & Fixes:**

* *Example:* Added `yum update -y` to user\_data to fix dependency errors.

---

## 🌐 Module 3: Custom VPC & Re-deployment

[**Planned.md Reference → VPC Section**](Planned.md#-module-3--vpc--networking)

**Goal:** Move infrastructure into a custom VPC with public/private subnets.

**AI Prompt Used:**

```
[Paste your exact AI prompt here]
```

**Code Implemented (.tf snippet):**

```hcl
# Paste VPC, subnets, route tables here
```

**Validation Steps:**

* [ ] `aws ec2 describe-vpcs` shows correct CIDR
* [ ] Public subnets have `map_public_ip_on_launch = true`

**Issues & Fixes:**

* *Example:* Forgot to associate route table with public subnets initially.

---

## 💾 Module 4: S3 Integration

[**Planned.md Reference → S3 Section**](Planned.md#-module-4--s3)

**Goal:** Create private S3 bucket and grant EC2 role access.

**AI Prompt Used:**

```
[Paste your exact AI prompt here]
```

**Code Implemented (.tf snippet):**

```hcl
# Paste bucket + policy code here
```

**Validation Steps:**

* [ ] Upload from app works
* [ ] Bucket private in AWS Console

**Issues & Fixes:**

* *Example:* Adjusted policy Principal ARN for correct role reference.

---

## 🗄️ Module 5: DynamoDB Integration

[**Planned.md Reference → DynamoDB Section**](Planned.md#-module-5--dynamodb)

**Goal:** Store employee records in DynamoDB.

**AI Prompt Used:**

```
[Paste your exact AI prompt here]
```

**Code Implemented (.tf snippet):**

```hcl
# Paste DynamoDB + permissions here
```

**Validation Steps:**

* [ ] App UI adds record to DynamoDB
* [ ] S3 + DynamoDB integration works end-to-end

**Issues & Fixes:**

* *Example:* Needed to update EC2 environment variables for table name.

---

## 📈 Module 6: Load Balancer & Auto Scaling

[**Planned.md Reference → ALB + Auto Scaling Section**](Planned.md#-module-6--alb--auto-scaling)

**Goal:** Add high availability and scaling.

**AI Prompt Used:**

```
[Paste your exact AI prompt here]
```

**Code Implemented (.tf snippet):**

```hcl
# Paste ALB + ASG code here
```

**Validation Steps:**

* [ ] ALB DNS routes traffic to healthy targets
* [ ] ASG scales up under load

**Issues & Fixes:**

* *Example:* Corrected scaling policy to target right group ARN.

---

## 🔍 Why Document Execution?

By linking each **Executed.md** section to its **Planned.md** counterpart, this repo shows the **full cycle**:

* 📄 Plan & AI prompt (design decisions + variable structure)
* 💻 Terraform code (customized from AI boilerplate)
* 🧪 Deployment & validation (CLI + console proof)
* 🛠️ Fixes (what went wrong and how I solved it)

