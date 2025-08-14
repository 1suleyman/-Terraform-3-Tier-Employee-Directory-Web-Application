# 🛠️ Terraform 3-Tier Employee Directory – Combined Plan & Execution Log

This is my **single source of truth** for the project — no more juggling `planned.md` and `executed.md`.
Each module is a mini case study: the plan, the pivot, the execution, and what I learned.

---

## 🌱 Module 0 — Manual Bootstrap for Remote State

### 📌 Planned

Set up **Terraform remote state storage** in AWS using **manual bootstrap** to avoid the chicken-and-egg problem, ensure immutability, and keep state infra safe.

**Manual Creation Steps**:

1. **S3 bucket** – stores `.tfstate`.
2. **DynamoDB table** – provides state locking.
3. Configured via AWS Console or CLI, not Terraform.

**Why manual**:

* Prevent accidental deletion during refactors.
* Backend exists before any `terraform init`.
* Clear separation between “state infra” and “app infra”.

Backend config in `backend.hcl`:

```hcl
bucket         = "tf-state-employee-directory"
key            = "envs/dev/terraform.tfstate"
region         = "eu-west-2"
dynamodb_table = "tf-state-locks"
encrypt        = true
```

---

### 🔄 Pivot

Originally, I let Terraform create the S3 bucket & DynamoDB table in Phase A.
I changed this because:

* It risks Terraform destroying its own backend.
* Collaboration breaks if backend doesn’t exist yet.
* Cleaner lifecycle when backend is manual.

---

### ✅ Executed

1. Created S3 bucket `tf-state-employee-directory`:

   * Region: `eu-west-2`
   * Versioning: Enabled ✅
   * Public access: Blocked ✅
   * Encryption: Amazon S3 managed keys (SSE-S3)
   * Tags: `Project=Employee Directory`, `Environment=Development`, `ManagedBy=Manual`

<img width="558" height="178" alt="Screenshot 2025-08-12 at 16 11 27" src="https://github.com/user-attachments/assets/26c3b0d4-ee4c-47da-a236-b111a769c771" />

2. Created DynamoDB table `tf-state-locks`:

   * Partition key (PK): `LockID` (String)
   * Table settings: default
   * Same tags applied

<img width="429" height="183" alt="Screenshot 2025-08-12 at 16 10 58" src="https://github.com/user-attachments/assets/7b49dc24-66ef-4949-8039-4a06b98b3712" />

3. Ran:

   ```bash
   terraform init -backend-config=backend.hcl
   ```
4. Verified backend connection worked.

<img width="602" height="216" alt="Screenshot 2025-08-12 at 16 14 38" src="https://github.com/user-attachments/assets/55ae246c-de53-4f14-b67f-dcf8e42ec3fa" />

When I got to step 4 and ran:

```bash
terraform init -backend-config=backend.hcl
```

…I checked the S3 bucket and noticed there was no `.tfstate` file.
I initially thought something was wrong, but I later realised this is **expected behaviour** — `terraform init` just connects Terraform to the remote backend; it doesn’t actually create or upload a state file until I run a command that changes infrastructure (like `terraform apply`).

In my backend config, I ended up using:

```hcl
key = "devterraform.tfstate"
```

So the state file will only appear in S3 under that exact name after my first successful `terraform apply`.
Once I applied a simple test resource, the file appeared in the bucket, and DynamoDB started showing lock entries during applies.

💡 Next time, I’ll remember to run a quick test apply right after `init` so I can immediately verify the backend is working.

---

### 💡 Lessons Learned

* Backend config **can’t** use variables — pass with `-backend-config`.
* DynamoDB locking is still relevant for preventing race conditions.
* Manual backend is more stable for long-lived projects.
* Always enable S3 versioning for state recovery.

---

## 🌍 Module 1 — IAM Setup + Global Project Configuration

### 📌 Planned

* **Naming convention**: `employee-<env>-<component>`
* **Environments**: `dev` and `prod` via workspaces
* **Tagging**: Project, Environment, Owner, CostCenter
* **IAM setup**:

  * Users: `AdminUser`, `DevUser`
  * Group: `EC2Admins` (AmazonEC2FullAccess)
  * Role: `EmployeeWebAppRole` (S3 & DynamoDB full access)

---

### ✅ Executed

1. Configured AWS provider in `var.aws_region` with default tags from `var.tags`.
2. Created `dev` workspace:

   ```bash
   terraform workspace new dev
   terraform workspace select dev
   ```
3. IAM Resources:

   * `AdminUser` & `DevUser` with console + CLI access. ✅
   * Group `EC2Admins` with `AmazonEC2FullAccess`. ✅

<img width="361" height="554" alt="Screenshot 2025-08-13 at 16 32 37" src="https://github.com/user-attachments/assets/2f0c00a6-1091-4c44-98a1-ce4dab660f01" />

   * `EmployeeWebAppRole` with trust policy for EC2 and S3/DynamoDB full access. ✅

<img width="295" height="58" alt="Screenshot 2025-08-13 at 16 34 18" src="https://github.com/user-attachments/assets/a130312d-7963-47b0-8483-e1cbb9b8f34e" />

<img width="638" height="265" alt="Screenshot 2025-08-13 at 16 34 30" src="https://github.com/user-attachments/assets/3b354303-0bb6-415e-80df-101f7f86ca44" />
  
   * Instance profile for EC2 attachment. ✅

## Here's the link for the terraform files used to create this 

[🌍 Module 1 — IAM Setup + Global Project Configuration](https://github.com/1suleyman/-Terraform-3-Tier-Employee-Directory-Web-Application/tree/main/Content/%F0%9F%8C%8D%20Module%201%20%E2%80%94%20IAM%20Setup%20%2B%20Global%20Project%20Configuration)

---

### 💡 Lessons Learned

* Tagging at provider level saves repetition.
* Workspaces allow quick environment switching without re-init (unless backend changes).
* Setting up instance profile early avoids later backtracking.

---

## 🌐 Module 2 — EC2 Deployment

### 📌 Planned

* Use **Amazon Linux 2023** AMI.
* `t2.micro` instance for free-tier testing.
* Security group allows only **HTTP/HTTPS**.
* Attach IAM instance profile from Module 1.
* Use `user_data` to bootstrap Flask app.

---

### ✅ Executed

* Used `data "aws_ami" "selected"` with **presets** (`var.base_image` = `al2023` / `ubuntu_jammy` / `al2`) and filters (`architecture`, `virtualization-type`, `root-device-type`) to fetch the **latest** AMI in `var.aws_region`.
* Provisioned `aws_instance.app` (`t2.micro`) with:

  * **IAM instance profile**: `aws_iam_instance_profile.ec2_profile` (from Module 1).
  * **Security group** `aws_security_group.web_sg`: HTTP/HTTPS from anywhere.
  * **User data** via Terraform HEREDOC (`local.user_data`) — intended to bootstrap Flask app.
* Added helpful **outputs**: `ec2_public_ip`, `ec2_public_dns`, `app_url`, `selected_ami_id`, `selected_ami_name`.

---

### ⚠ What Actually Happened

1. **Subnet Link Missing**

   * Forgot to explicitly link EC2 to the VPC's subnet in Terraform.
   * Initially launched into a subnet with **no auto-assign public IPv4**.

2. **No Public IP Assigned**

   * Fixed by enabling **auto-assign public IPv4** in the subnet settings (via AWS Console).

3. **Public IP Website Not Loading**

   * Discovered **route table pointed to a deleted IGW** (status: `blackhole`).

4. **User Data Script Errors**

   * **Filename mismatch**: Downloaded `FlaskApp.zip` but tried to unzip `employee-app.zip`.
   * **Unzip before install**: Attempted `unzip` before `dnf install unzip`.
   * **Flask port issue**: Default `python3 application.py` bound to `127.0.0.1:5000`, not `0.0.0.0:80` (unreachable with SG only allowing port 80).
   * **Public IP requirement**: Needed `associate_public_ip_address = true` in Terraform **and** a subnet route to an active IGW.

5. **Confirmed Root Cause**

   * Replaced Flask user data with **simple Apache test page**:

     ```bash
     #!/bin/bash
     set -eux
     dnf update -y
     dnf install -y httpd
     systemctl start httpd
     systemctl enable httpd
     echo "<h1>🎉 Hello from EC2!</h1>" > /var/www/html/index.html
     ```
   * Result: Static site loaded instantly → proved **user\_data script** was the issue.

<img width="532" height="208" alt="Screenshot 2025-08-14 at 16 58 19" src="https://github.com/user-attachments/assets/96564d55-18de-431f-913d-ac278500fe8b" />

---

### 🔎 Validation

* `terraform plan` resolved correct AMI and SG rules.
* After fixing subnet + IGW + minimal `user_data`, instance launched and was reachable at `http://<public-ip>`.
* Verified IAM role permissions (Module 1 config intact).

## Here's the link for the terraform files (that have added changes) used to create this 

[🚀 Module 2: Launching the App on EC2](https://github.com/1suleyman/-Terraform-3-Tier-Employee-Directory-Web-Application/tree/main/Content/%F0%9F%9A%80%20Module%202%3A%20Launching%20the%20App%20on%20EC2)
---

### 💡 Lessons Learned

* **Don’t hardcode AMI IDs** — always fetch dynamically with filters.
* **Always link EC2 to a subnet** that has:

  * Auto-assign public IPv4 enabled, **and**
  * Route to a valid Internet Gateway.
* Keep **user\_data minimal** for testing (Apache/HTML) before running complex scripts.
* Set `user_data_replace_on_change = true` to trigger re-provisioning on script updates.
* Debug route tables early — **blackhole = no internet**.

---

## 🏗️ Module 3 — VPC & Networking

### 📌 Planned

* **CIDR**: `10.1.0.0/16`
* 2 AZs for HA.
* Public and private subnets.
* Internet Gateway & public route table.

---

### ✅ Executed

* Created VPC, subnets, IGW, and route tables.
* Associated public subnets with public route table.
* Validated public subnet had internet connectivity.

---

### 💡 Lessons Learned

* Tag subnets as `public`/`private` for clarity.
* Always test connectivity with a temporary EC2 in the public subnet.

---

## 🪣 Module 4 — S3 (Profile Photos)

### 📌 Planned

* Unique bucket name for profile photo storage.
* Public access blocked.
* Policy allows only EC2 role to access.

---

### ✅ Executed

* Created S3 bucket with public access blocked.
* Added bucket policy restricting access to `EmployeeWebAppRole`.
* Validated EC2 could upload and retrieve images.

---

### 💡 Lessons Learned

* Use bucket policy **and** IAM role for layered security.
* Always test both upload and download flows.

---

## 📄 Module 5 — DynamoDB (Employee Records)

### 📌 Planned

* Table name: `Employees`
* Partition key: `id` (String)
* Billing mode: On-demand.

---

### ✅ Executed

* Created table with `id` as PK.
* Attached policy to EC2 role for CRUD access.
* Validated app could read/write to the table.

---

### 💡 Lessons Learned

* PAY\_PER\_REQUEST billing avoids unused capacity costs.
* Keep key schema simple unless advanced queries are required.

---

## ⚖️ Module 6 — ALB + Auto Scaling

### 📌 Planned

* Internet-facing ALB in public subnets.
* Target group on HTTP `/`.
* Launch template for EC2.
* ASG: min=2, max=4, desired=2.
* CPU target policy: 60%.

---

### ✅ Executed

* Created ALB across public subnets.
* Created target group & attached EC2 instances.
* Launch template for app instances.
* Auto Scaling Group with CPU tracking.
* Validated:

  * ALB evenly distributed traffic.
  * Scaling triggered under CPU load.

---

### 💡 Lessons Learned

* Test scaling with `stress` tool to verify thresholds.
* Health checks must match app’s response path — mismatches cause false failures.
