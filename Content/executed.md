Got it ✅
Here’s the **Terraform Executed Steps** version, same style as your AWS one, but ready for you to fill in as you progress.
I’ve kept the module headers, space for code snippets, and validation notes — so you can document both your Terraform commands and AWS results.

---

# Project Execution: Terraform 3-Tier Employee Directory Application

Welcome to the **hands-on execution log** of my **Terraform 3-Tier Employee Directory Web Application** project.
This file documents the exact steps I took — from **IAM setup to Auto Scaling** — to bring this application to life on AWS **entirely using Terraform**.

Think of this as a **behind-the-scenes build journal** that tracks not just what I planned to do — but what I actually **coded, applied, validated, and learned**.

---

## 🧠 What You’ll Find Here

✅ Completed modules with **verified Terraform deployments**
📜 Snippets of `.tf` code for each AWS resource
🖼️ Screenshots from AWS Console for visual proof
🧪 Tests and validations of deployed infrastructure
📦 Cleanup and cost-saving steps after each module

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



---

## 🚀 Module 2: Launching the App on EC2

**Goal:** Deploy EC2 instance with user data to run Flask app.



---

## 🌐 Module 3: Custom VPC & Re-deployment

**Goal:** Move infrastructure into a custom VPC with public/private subnets.



---

## 💾 Module 4: S3 Integration

**Goal:** Create private S3 bucket and grant EC2 role access.



---

## 🗄️ Module 5: DynamoDB Integration

**Goal:** Store employee records in DynamoDB.



---

## 📈 Module 6: Load Balancer & Auto Scaling

**Goal:** Add high availability and scaling.



---

## 🔍 Why Document Execution?

Writing this log was part of my **learn-by-building** approach.
I didn’t just read Terraform docs — I **coded, deployed, tested, broke things, fixed them**, and learned why each resource mattered.

If you’re learning Terraform, prepping for the **Terraform Associate** exam, or building similar AWS stacks — this execution log is for you.
