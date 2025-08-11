# 🧑‍💻 Terraform 3-Tier Employee Directory Web Application

Welcome to my personal **Terraform lab project**!
This repository documents my **step-by-step journey** building a **3-Tier Employee Directory Web Application** on AWS — this time **fully provisioned with Infrastructure as Code (IaC) using Terraform**.

---

## 📌 Project Overview

The goal of this project is to gain **hands-on experience** designing, provisioning, and scaling a **production-style web application** using Terraform to automate AWS infrastructure builds.

Instead of manually creating resources in the AWS Console, **Terraform manages everything** — from VPC networking to EC2 instances, S3 storage, and DynamoDB tables.

---

## 🎯 Objective

**Build a secure, scalable, and highly available Employee Directory web application** in AWS — with every resource defined in Terraform `.tf` configuration files for repeatable, version-controlled deployments.

---

## 🛠️ Infrastructure Stack (Provisioned by Terraform)

* **Amazon EC2** – Compute for Flask web server
* **Amazon S3** – Stores employee profile photos
* **Amazon DynamoDB** – Stores employee data
* **IAM** – Roles, policies, and least-privilege access
* **Amazon VPC** – Custom networking and subnet design
* **Elastic Load Balancer** – Distributes traffic across AZs
* **EC2 Auto Scaling** – Automatic instance scaling based on load
* **\[Planned] API Gateway + AWS Lambda** – Serverless contact form feature

---

## 🗂️ Project Documentation

Quick links to the main learning artifacts in this repo:

* 📘 [Planned Steps](Content/planned.md) – Terraform module breakdowns, configuration structure, and IaC design decisions
* 🛠️ *[Executed Walkthrough](Content/executed.md) – Terraform code examples, plan/apply logs, screenshots, and testing notes

---

## 📊 Architecture Diagram

![Screenshot 2025-07-08 at 10 41 47](https://github.com/user-attachments/assets/0e6db769-0053-41a3-a6cf-d135515adbff)

---

## 🧠 What I Learned

This project documents my **end-to-end AWS deployment** of a real-world, scalable web application — **built entirely with Terraform**.

Here’s what I practiced and learned:

### ✅ **Terraform Core Concepts**

* Structured `.tf` files into logical modules (`networking`, `compute`, `storage`, etc.)
* Used `terraform init`, `plan`, `apply`, and `destroy` for full lifecycle management
* Applied **variables**, **outputs**, and **locals** to make configurations reusable
* Implemented **remote state** with an S3 backend and DynamoDB state locking
* Tagged all resources for better cost tracking and compliance

### ✅ **Identity & Access Management (IAM)**

* Defined IAM users, groups, and roles **in code**
* Attached least-privilege policies to roles for EC2 access to S3 & DynamoDB
* Managed environment-specific roles using **Terraform workspaces**

### ✅ **Networking (Amazon VPC)**

* Created a **custom VPC** (CIDR: 10.1.0.0/16) with Terraform
* Automated creation of public/private subnets across multiple AZs
* Attached and routed through an Internet Gateway for public access
* Configured security groups with only the necessary inbound/outbound rules

### ✅ **Compute (Amazon EC2)**

* Used Terraform to launch EC2 instances from Amazon Linux 2023 AMIs
* Passed in User Data scripts to install Flask and dependencies
* Assigned IAM roles and security groups via Terraform
* Managed instance counts dynamically via Auto Scaling groups

### ✅ **Storage (Amazon S3)**

* Created an S3 bucket for photo uploads
* Applied **bucket policies** and IAM role permissions in code
* Tested end-to-end uploads from app → S3

### ✅ **Database (Amazon DynamoDB)**

* Created the `Employees` table with partition key `id`
* Integrated environment variables for app connectivity
* Verified full-stack flow: Upload to S3, write to DynamoDB, return data to UI

### ✅ **Load Balancing & Auto Scaling**

* Defined **Application Load Balancer** and target groups in Terraform
* Linked Auto Scaling groups to ALB target tracking
* Simulated high CPU load to trigger scaling events
* Verified healthy instance registration and traffic routing

---

## 🧩 Why Terraform?

Instead of manually creating resources:

* Every AWS service is **declared in code**
* Changes are **tracked in Git**
* Infrastructure can be **destroyed and rebuilt in minutes**
* **Identical environments** can be created for dev, test, and prod using workspaces

This approach matches **real-world DevOps workflows** and prepares for **Terraform Associate** exam concepts.

---

## 📮 Feedback

Have ideas, questions, or want to collaborate on **Terraform + AWS** projects?
Feel free to reach out or open an issue in the repo 🚀
