# 📋 Planned — Terraform 3-Tier Employee Directory Web Application

This is my **blueprint** for building a Terraform-powered AWS 3-Tier Employee Directory App.
Each module contains:

* **Decisions** — What I’m building and *why* (with analogies to make it stick).
* **Variables** — What values I’ll define so configs are reusable.
* **Docs to Read** — Where to learn syntax and details.
* **AI Prompt Template** — Ready to paste into AI to get boilerplate code.

---

## 🛠️ Module 0 — Local & Remote State Setup

### Decisions

* **Create S3 bucket for Terraform state**
  *Why:* Think of this like a shared notebook where Terraform writes down what it has built. Storing it in S3 means you can access it from anywhere and share it across your team.

* **Enable versioning on the bucket**
  *Why:* If Terraform’s “notebook” gets messed up, versioning is your backup — you can roll back to a previous version.

* **Create DynamoDB table for state locking**
  *Why:* This is like putting a “Do Not Disturb” sign on the notebook. It stops two people from editing the same infrastructure at the same time.

* **Name resources using project + environment**
  *Why:* Makes them easy to identify in the AWS Console (e.g., `tfstate-employee-directory-dev`).

### Variables

* `state_bucket_name` — Name of S3 bucket for storing Terraform state.
* `state_dynamodb_table` — Name of DynamoDB table for locking.
* `aws_region` — Region where bucket and table will be created.
* `tags` — Default tags to apply to both resources.

### Docs to Read (Why)

* **aws\_s3\_bucket** – Learn syntax for creating S3 buckets in Terraform.
* **aws\_s3\_bucket\_versioning** – Enable versioning for rollback safety.
* **aws\_dynamodb\_table** – Create the table Terraform uses for locking.
* **terraform backend s3** – Configure Terraform to use the bucket/table automatically.

### AI Prompt Template

> Generate Terraform configuration that creates:
>
> 1. An S3 bucket `${var.state_bucket_name}` in `${var.aws_region}` with versioning enabled, tagged with `${var.tags}`.
> 2. A DynamoDB table `${var.state_dynamodb_table}` with primary key `LockID` (string) for state locking, tagged with `${var.tags}`.
> 3. Configure Terraform backend to use this S3 bucket for remote state storage and DynamoDB for locking. Use variables for names, region, and tags.

---

## 🌍 Module 1 — Global Project Setup

### Decisions

* **Naming convention:** `employee-<env>-<component>`
  *Why:* Like labeling moving boxes — you instantly know where each thing belongs.
* **Environments:** `dev`, `prod` (via workspaces or separate folders)
  *Why:* Test things in a **sandbox** before touching the real thing.
* **Remote state:** S3 backend + DynamoDB locking
  *Why:* S3 is the **filing cabinet** for Terraform’s memory. DynamoDB is the **“Do Not Disturb” sign** so only one change happens at a time.
* **Tagging standard:** `Project`, `Environment`, `Owner`, `CostCenter`
  *Why:* Like sticky notes on your stuff — makes it easy to find, track costs, and clean up.

### Variables

aws\_region
project\_name
environment
tags (map)

### Docs to Read (Why)

* **aws provider** – Tells Terraform which cloud and region to use.
* **terraform backend s3** – Stores Terraform’s memory in S3.
* **terraform state locking dynamodb** – Stops accidental simultaneous edits.
* **terraform workspaces** – Switch between dev/prod without rewriting code.
* **terraform variables / outputs / locals** – Keep code clean and reusable.

### AI Prompt Template

> Generate Terraform configuration to set up the AWS provider in region \${var.aws\_region}, with default tags \${var.tags}, and configure a remote S3 backend with DynamoDB state locking. Include variables for project\_name, environment, and aws\_region.

---

## 🔐 Module 2 — IAM

### Decisions

* **Users:** AdminUser, DevUser
  *Why:* Like having separate keycards for managers and developers.
* **Group:** EC2Admins
  *Why:* Instead of giving keys one by one, put people in a **club** with shared access.
* **EC2 Role:** EmployeeWebAppRole
  *Why:* Give your server only the keys it needs — no more.
* **Policies:** Start with AWS-managed S3 + DynamoDB access
  *Why:* Quick to set up, safe to refine later.

### Variables

admin\_user\_name
dev\_user\_name
iam\_group\_name
ec2\_role\_name
managed\_policy\_arns (list)

### Docs to Read (Why)

* **aws\_iam\_user** – How to create keycard holders.
* **aws\_iam\_group** – How to create clubs.
* **aws\_iam\_group\_policy\_attachment** – How to give clubs their access rights.
* **aws\_iam\_role** – How to give services permissions.
* **aws\_iam\_instance\_profile** – How to attach roles to EC2.

### AI Prompt Template

> Generate Terraform AWS IAM configuration that creates:
>
> * Users \${var.admin\_user\_name} and \${var.dev\_user\_name}
> * Group \${var.iam\_group\_name} with \${var.managed\_policy\_arns} attached
> * Role \${var.ec2\_role\_name} with trust for EC2 and the same managed policies
> * Instance profile bound to that role
>   Use variables and tagging from my global setup.

---

## 🌐 Module 3 — EC2

### Decisions

* **AMI:** Amazon Linux 2023
  *Why:* AWS-maintained and optimized — like a car tuned for the local roads.
* **Instance type:** t2.micro
  *Why:* Fits in the free tier — perfect for testing.
* **Security group:** HTTP/HTTPS only
  *Why:* Locks the front door, leaves only the website door open.
* **Attach IAM profile from IAM module**
  *Why:* Lets EC2 talk to S3/DynamoDB without hard-coded passwords.

### Variables

instance\_name
instance\_type
ami\_id or data aws\_ami lookup
user\_data\_path
web\_ingress\_cidrs (list)
vpc\_id, subnet\_id

### Docs to Read (Why)

* **aws\_instance** – The blueprint for launching a server.
* **aws\_security\_group** – Your firewall.
* **data aws\_ami** – Finds the latest server image.
* **user\_data** – Startup script for your server.

### AI Prompt Template

> Generate Terraform AWS EC2 configuration that launches:
>
> * An instance \${var.instance\_name} in \${var.subnet\_id} with \${var.instance\_type}
> * Using AMI from data source for Amazon Linux 2023
> * With security group allowing HTTP/HTTPS from \${var.web\_ingress\_cidrs}
> * Attaching IAM instance profile \${var.ec2\_instance\_profile}
> * Running user\_data script from \${var.user\_data\_path}
>   Output the instance public IP.

---

## 🏗️ Module 4 — VPC & Networking

### Decisions

* **CIDR:** 10.1.0.0/16
  *Why:* Your app’s private street address range.
* **2 AZs:** eu-west-2a, eu-west-2b
  *Why:* If one area has a power cut, the other keeps running.
* **Public & private subnets**
  *Why:* Like having a public shop front and a private storeroom.
* **Internet gateway + public route table**
  *Why:* The internet gateway is the **main road** into your shop.

### Variables

vpc\_cidr
azs (list)
public\_subnet\_cidrs
private\_subnet\_cidrs
enable\_nat\_gateway

### Docs to Read (Why)

* **aws\_vpc** – Creates your private network.
* **aws\_subnet** – Divides your network into smaller zones.
* **aws\_internet\_gateway** – The bridge to the internet.
* **aws\_route\_table** – The map of where traffic should go.

### AI Prompt Template

> Generate Terraform AWS VPC configuration for:
>
> * CIDR \${var.vpc\_cidr}
> * Public subnets \${var.public\_subnet\_cidrs} and private subnets \${var.private\_subnet\_cidrs}
> * Internet gateway and public route table associated with public subnets
>   Include variable inputs and tags from my global setup.

---

## 🪣 Module 5 — S3

### Decisions

* **Unique bucket name**
  *Why:* S3 is like email addresses — names must be unique across the world.
* **Block public access**
  *Why:* Stops anyone from peeking into your storage box.
* **Allow only EC2 role to Put/Get**
  *Why:* Gives your app the keys, but no one else.

### Variables

photos\_bucket\_name
bucket\_force\_destroy

### Docs to Read (Why)

* **aws\_s3\_bucket** – Creates the storage box.
* **aws\_s3\_bucket\_policy** – Controls who can open it.
* **aws\_s3\_bucket\_public\_access\_block** – Slaps a “Private” sticker on it.

### AI Prompt Template

> Generate Terraform AWS S3 configuration for:
>
> * Bucket \${var.photos\_bucket\_name} with public access blocked
> * Bucket policy allowing only IAM role \${var.ec2\_role\_name} to Put/Get objects
> * force\_destroy set to \${var.bucket\_force\_destroy}

---

## 📄 Module 6 — DynamoDB

### Decisions

* **Table name:** Employees
  *Why:* Stores all your employee info.
* **Partition key:** id (String)
  *Why:* Like a unique ID badge for each record.
* **Billing mode:** PAY\_PER\_REQUEST
  *Why:* Pay only when people come to your shop — no rent for empty space.

### Variables

ddb\_table\_name
ddb\_hash\_key
ddb\_billing\_mode

### Docs to Read (Why)

* **aws\_dynamodb\_table** – How to make the database.
* **aws\_iam\_policy** – How to give your app the right permissions.

### AI Prompt Template

> Generate Terraform AWS DynamoDB configuration for:
>
> * Table \${var.ddb\_table\_name} with hash key \${var.ddb\_hash\_key} (String)
> * Billing mode \${var.ddb\_billing\_mode}
> * Tagged with my global tags

---

## ⚖️ Module 7 — ALB + Auto Scaling

### Decisions

* **ALB:** Internet-facing across 2 public subnets
  *Why:* Like a receptionist that sends visitors to the right desk.
* **Target group:** HTTP on `/`
  *Why:* The ALB’s checklist to know if your app is healthy.
* **Launch template:** EC2 config
  *Why:* Like a cookie cutter for making identical servers.
* **ASG:** desired/min/max = 2/2/4
  *Why:* Keeps enough servers running but can grow on demand.
* **Scaling policy:** Target CPU 60%
  *Why:* Keeps the workload balanced without overspending.

### Variables

alb\_name
target\_group\_name
health\_check\_path
launch\_template\_name
asg\_desired, asg\_min, asg\_max
cpu\_target\_utilization

### Docs to Read (Why)

* **aws\_lb** – How to make the receptionist.
* **aws\_lb\_target\_group** – How to group desks (servers).
* **aws\_launch\_template** – The recipe for servers.
* **aws\_autoscaling\_group** – The team that manages adding/removing servers.
* **aws\_autoscaling\_policy** – The rules for when to scale.

### AI Prompt Template

> Generate Terraform AWS ALB + Auto Scaling configuration for:
>
> * ALB \${var.alb\_name} across \${var.public\_subnet\_ids}
> * Target group \${var.target\_group\_name} with health check path \${var.health\_check\_path}
> * Launch template \${var.launch\_template\_name}
> * ASG desired/min/max = \${var.asg\_desired}, \${var.asg\_min}, \${var.asg\_max}
> * Target tracking scaling policy for \${var.cpu\_target\_utilization}% CPU

