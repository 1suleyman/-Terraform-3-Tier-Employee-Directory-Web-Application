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

* 🚀 **Module 1:** IAM Setup (Users, Groups, Roles, Policies, MFA)
* 🚀 **Module 2:** Launching the App on EC2 (Networking, User Data, Web Server)
* 🌐 **Module 3:** Custom VPC with Subnets, Route Tables, and Re-deployment
* 💾 **Module 4:** S3 Bucket for Profile Photos + IAM Policy Integration
* 🗄️ **Module 5:** DynamoDB Table Setup + Full CRUD Test via App UI
* 📈 **Module 6:** Load Balancing and EC2 Auto Scaling Configuration + Stress Test

---

## 🚀 Module 1: IAM Setup

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
# Paste the relevant part of Terraform plan/apply here
```

**AWS Console Screenshot:**
`[Insert screenshot of IAM roles/users/groups]`

**Validation Steps:**

* [ ] `aws iam list-users` shows `AdminUser`, `DevUser`
* [ ] `aws iam list-roles` shows `EmployeeWebAppRole`
* [ ] Trust policy principal = `ec2.amazonaws.com`

**Issues & Fixes:**

* *Example:* Had to update `assume_role_policy` JSON to match AWS policy syntax.

---

## 🚀 Module 2: Launching the App on EC2

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
# Paste relevant CLI output here
```

**AWS Console Screenshot:**
`[Insert screenshot of EC2 instance detail page]`

**Validation Steps:**

* [ ] `terraform output ec2_public_ip` returns live IP
* [ ] `curl http://<PUBLIC_IP>` loads the app

**Issues & Fixes:**

* *Example:* Initial user data failed due to missing `yum update -y` in script.

---

## 🌐 Module 3: Custom VPC & Re-deployment

**Goal:** Move infrastructure into a custom VPC with public/private subnets.

**AI Prompt Used:**

```
[Paste your exact AI prompt here]
```

**Code Implemented (.tf snippet):**

```hcl
# Paste VPC + subnet + route table code here
```

**Validation Steps:**

* [ ] `aws ec2 describe-vpcs` shows VPC `app-vpc` with correct CIDR
* [ ] Public subnets have `map_public_ip_on_launch = true`

**Issues & Fixes:**

* *Example:* Forgot to associate route table with public subnets.

---

## 💾 Module 4: S3 Integration

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

* [ ] Upload works from app → image stored in S3
* [ ] Bucket is private in AWS Console

**Issues & Fixes:**

* *Example:* Had to fix bucket policy principal ARN.

---

## 🗄️ Module 5: DynamoDB Integration

**Goal:** Store employee records in DynamoDB.

**AI Prompt Used:**

```
[Paste your exact AI prompt here]
```

**Code Implemented (.tf snippet):**

```hcl
# Paste DynamoDB + permissions code here
```

**Validation Steps:**

* [ ] Adding employee in UI stores record in DynamoDB
* [ ] S3 + DynamoDB integration works end-to-end

**Issues & Fixes:**

* *Example:* Needed to re-run EC2 with updated environment variables.

---

## 📈 Module 6: Load Balancer & Auto Scaling

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
* [ ] ASG scales up under load test

**Issues & Fixes:**

* *Example:* Scaling policy initially used wrong target group ARN.

---

## 🔍 Why Document Execution?

Writing this log was part of my **learn-by-building** approach.
I didn’t just read Terraform docs — I **coded, deployed, tested, broke things, fixed them**, and learned why each resource mattered.

If you’re learning Terraform, prepping for the **Terraform Associate** exam, or building similar AWS stacks — this execution log is for you.

