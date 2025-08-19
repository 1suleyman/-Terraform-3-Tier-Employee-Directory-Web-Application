# 🧑‍💻 Terraform 3-Tier Employee Directory Web Application

Welcome to my personal Terraform lab project! This repository documents my step-by-step journey building a **3-Tier Employee Directory Web Application on AWS** — this time fully provisioned with **Infrastructure as Code (IaC)** using Terraform.

---

## 📌 Project Overview

The goal of this project is to gain **hands-on experience designing, provisioning, and scaling** a production-style web application using Terraform to automate AWS infrastructure builds.

Instead of manually creating resources in the AWS Console, Terraform manages everything — from **VPC networking** to **EC2 instances**, **S3 storage**, and **DynamoDB tables**.

---

## 🎯 Objective

Build a **secure, scalable, and highly available** Employee Directory web application in AWS — with every resource defined in Terraform `.tf` configuration files for **repeatable, version-controlled deployments**.

---

## 🛠️ Infrastructure Stack (Provisioned by Terraform)

* **Amazon EC2** – Compute for Flask web server
* **Amazon S3** – Stores employee profile photos
* **Amazon DynamoDB** – Stores employee data
* **IAM** – Roles, policies, and least-privilege access
* **Amazon VPC** – Custom networking and subnet design
* **Elastic Load Balancer** – Distributes traffic across AZs
* **EC2 Auto Scaling** – Automatic instance scaling based on load
* \[Planned] **API Gateway + AWS Lambda** – Serverless contact form feature

---

## 🗂️ Project Documentation

This repo combines **plan + execution** logs into one source of truth. Each module is a mini case study: **the plan, the pivot, the execution, and what I learned**.

* 📘🛠️ [Planned + Executed Steps](Content/planned+executed.md) – Terraform module breakdowns, configuration structure, and IaC design decisions + Terraform code examples, plan/apply logs, screenshots, and testing notes

---

### 🌱 Module 0 — Manual Bootstrap for Remote State

* **S3 bucket** (`tf-state-employee-directory`) with versioning for `.tfstate`
* **DynamoDB table** (`tf-state-locks`) for state locking
* Backend configured in `backend.hcl` and verified with `terraform init`

💡 Lessons: Always enable versioning, backend must exist before init, DynamoDB locking prevents race conditions.

---

### 🌍 Module 1 — IAM Setup + Global Project Configuration

* Created IAM users (AdminUser, DevUser), group (EC2Admins), and role (EmployeeWebAppRole).
* Applied **provider-level tags** and **workspaces** for `dev` and `prod`.
* Created instance profile for EC2.

💡 Lessons: Workspaces allow fast environment switching, tagging at provider level reduces repetition.

---

### 🚀 Module 2 — EC2 Deployment

* Selected latest Amazon Linux 2023 AMI dynamically with `data "aws_ami"`.
* Created EC2 instance (`t2.micro`) with IAM role, SG (HTTP/HTTPS only), and User Data.
* **Issues hit**: missing subnet links, blackholed route tables, public IP not auto-assigned, and User Data failures.
* Debugged by switching to a **minimal Apache test page** → proved networking was fine.

💡 Lessons: Test with simple user\_data first, always confirm subnet routing to IGW, set `associate_public_ip_address = true`.

---

### 🏗️ Module 3 — VPC & Networking

* Created custom VPC (`10.1.0.0/16`), public/private subnets in 2 AZs.
* Added Internet Gateway + route tables, validated connectivity with EC2 test.

💡 Lessons: Tag subnets as `public`/`private`, always test connectivity early.

---

### 💾 Module 4 — Storage (S3 Integration) \[In Progress]

* Created S3 bucket `employee-photo-bucket-456s` in `eu-west-2`.
* Applied bucket policy to allow access from EC2 via IAM Role.
* Updated User Data to set `PHOTOS_BUCKET` env variable.
* Ran into **Flask app bootstrap issues** with Skill Builder script (ordering, yum vs dnf, binding to port 80).

⚠️ **Where I Paused**: Troubleshooting this became a rabbit hole. Sometimes the best move is to pause and pivot — I decided to continue with other modules and revisit this later with a cleaner approach.

---

## 🧠 What I Learned

✅ **Terraform Core Concepts** – modules, variables, outputs, remote state, tagging.
✅ **IAM** – users, roles, instance profiles, least-privilege policies.
✅ **Networking** – custom VPC, subnets, IGW, security groups.
✅ **Compute** – EC2 provisioning, User Data debugging, AMI selection.
✅ **Storage** – S3 buckets, bucket policies, IAM integration.
✅ **Resilience** – validated that not every step goes perfectly; documenting pivots is part of real DevOps work.

---

## 🧩 Why Terraform?

* Every AWS service is declared in code.
* Changes are tracked in Git.
* Environments (`dev`, `prod`) are reproducible via workspaces.
* Infra can be destroyed and rebuilt in minutes.
* Mirrors real-world **DevOps workflows** and maps directly to Terraform Associate exam concepts.

---

## 📊 Architecture Diagram

![Screenshot 2025-07-08 at 10 41 47](https://github.com/user-attachments/assets/0e6db769-0053-41a3-a6cf-d135515adbff)

---

## 📮 Feedback

Have ideas, questions, or want to collaborate on Terraform + AWS projects? Feel free to reach out or open an issue in the repo 🚀
