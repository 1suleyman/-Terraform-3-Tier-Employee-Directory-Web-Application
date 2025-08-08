# 🧑‍💻 Terraform 3-Tier Employee Directory Web Application

Welcome to my **Terraform-powered AWS lab project**!
This repository documents my **step-by-step journey** building a **3-Tier Employee Directory Web Application** on AWS — with every resource fully **provisioned using Infrastructure as Code**.

---

## 📌 Project Overview

The goal of this project is to **design, provision, and scale** a production-style cloud application using **Terraform** to automate every part of the build.

Instead of manually clicking through the AWS Console, this project uses **`.tf` configuration files** and the Terraform CLI to:

* Deploy
* Test
* Tear down
* Re-deploy
  …in a **repeatable and version-controlled** way.

---

## 🎯 Objective

**Build a secure, scalable, and highly available Employee Directory web application** — fully managed by Terraform.

---

## 🛠️ Infrastructure Stack (Provisioned via Terraform)

* **Amazon EC2** – Compute for Flask web server
* **Amazon S3** – Stores employee profile photos
* **Amazon DynamoDB** – NoSQL database for employee data
* **IAM** – Roles, policies, and least-privilege access
* **Amazon VPC** – Custom networking with public/private subnets
* **Elastic Load Balancer** – Distributes traffic across multiple AZs
* **EC2 Auto Scaling** – Automatically scales based on demand
* **\[Planned] API Gateway + Lambda** – Serverless contact form feature

---

## 🗂️ Module Overview

This Terraform project is divided into **6 modules**, each one mapped to a core AWS concept:

1. **IAM** — Users, groups, roles, MFA
2. **EC2** — Hosting the application on a virtual server
3. **VPC** — Custom networking with public/private subnets
4. **S3** — Storing profile images with restricted access
5. **DynamoDB** — Persistent data storage for the app
6. **Monitoring & Scaling** — Load balancing and auto scaling

Each module has:

* `main.tf` – Core resource definitions
* `variables.tf` – Configurable inputs
* `outputs.tf` – Key resource outputs
* Documentation notes + CLI commands

---

## 🚀 Module 1: IAM Setup in Terraform

**Goals:**

* Enable secure account access
* Manage permissions through code

**Terraform Tasks:**

* Define IAM users (`aws_iam_user`)
* Define IAM groups and attach managed policies (`aws_iam_group` + `aws_iam_group_policy_attachment`)
* Create IAM roles (`aws_iam_role`) for EC2 with S3 + DynamoDB access
* Use `aws_iam_instance_profile` to attach roles to EC2

**Verification:**

```bash
terraform apply
aws iam list-users
aws iam list-roles
```

---

## 🚀 Module 2: EC2 Deployment via Terraform

**Goals:**

* Launch the Employee Directory app on EC2 with IAM role and security groups

**Terraform Tasks:**

* Define security group (`aws_security_group`) allowing HTTP/HTTPS
* Provision EC2 instance (`aws_instance`) with `user_data` startup script
* Attach IAM instance profile for app to use S3/DynamoDB
* Output public IP from Terraform

**Verification:**

```bash
terraform output ec2_public_ip
curl http://<PUBLIC_IP>
```

---

## 🌐 Module 3: VPC & Networking via Terraform

**Goals:**

* Create custom network layout with public and private subnets

**Terraform Tasks:**

* Create custom VPC (`aws_vpc`)
* Create public and private subnets (`aws_subnet`)
* Attach Internet Gateway (`aws_internet_gateway`)
* Create route tables and associations (`aws_route_table`, `aws_route_table_association`)

**Verification:**

```bash
aws ec2 describe-vpcs
aws ec2 describe-subnets
```

---

## 💾 Module 4: S3 Storage via Terraform

**Goals:**

* Store profile photos in a secure S3 bucket

**Terraform Tasks:**

* Create private S3 bucket (`aws_s3_bucket`)
* Add bucket policy (`aws_s3_bucket_policy`) to allow access only via IAM role
* Set bucket name in `user_data` environment variable

**Verification:**

```bash
aws s3 ls s3://<BUCKET_NAME>
```

---

## 🗄️ Module 5: DynamoDB Database via Terraform

**Goals:**

* Persist employee data in NoSQL database

**Terraform Tasks:**

* Create DynamoDB table (`aws_dynamodb_table`)
* Update EC2 app configuration via `user_data` to point to table
* Test CRUD operations via app UI

**Verification:**

```bash
aws dynamodb scan --table-name Employees
```

---

## 📈 Module 6: Monitoring, Load Balancing & Auto Scaling via Terraform

**Goals:**

* Ensure high availability and scale under load

**Terraform Tasks:**

* Create Application Load Balancer (`aws_lb`) with target group (`aws_lb_target_group`)
* Create Launch Template (`aws_launch_template`)
* Create Auto Scaling Group (`aws_autoscaling_group`) linked to ALB
* Add scaling policies (`aws_autoscaling_policy`)

**Verification:**

```bash
ab -n 1000 -c 50 http://<ALB_DNS>
aws autoscaling describe-auto-scaling-groups
```

---

## 🔗 Terraform Workflow

For each module:

```bash
terraform init
terraform plan
terraform apply
terraform destroy   # Optional for cleanup
```

---

## 🧠 What I Learned

This project reinforced:

* Writing clean and reusable Terraform code
* Structuring multi-module IaC projects
* Managing state files (S3 backend + DynamoDB locking)
* Deploying full AWS stacks from scratch without console clicks
* Scaling apps automatically with ALB + ASG

---

## 📮 Feedback

Have Terraform tips, questions, or ideas for collaboration?
Open an issue or reach out 🚀
