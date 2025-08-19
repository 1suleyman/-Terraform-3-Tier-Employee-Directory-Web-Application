########################################
# Module 2 — EC2 Deployment (No Hardcoding AMI)
########################################

# 🔧 AMI presets: switch images by changing var.base_image
# - al2023       (owners = amazon)
# - ubuntu_jammy (owners = Canonical: 099720109477)
# - al2          (owners = amazon)
locals {
    # Amazon Machine Image Presets
  ami_presets = {
    # Imagine this as a restaurant menu:
    # Each recipe lists the chef (owners) and the dish name pattern (name).
    # owners → AWS account IDs or “amazon” to indicate the official owner.
    # name → The AMI name pattern (supports * wildcards) that matches the AMI you want.

    # Amazon Linux 2023 preset
    al2023 = {
      owners = ["amazon"]
      name   = "al2023-ami-*-kernel-6.1-x86_64"
    }
    # Ubuntu Jammy preset
    ubuntu_jammy = {
      owners = ["099720109477"] # Canonical
      name   = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
    }
    # Amazon Linux 2 preset
    al2 = {
      owners = ["amazon"]
      name   = "amzn2-ami-hvm-*-x86_64-gp2"
    }
  }

# next ami_selected
# Purpose: Pick one preset from the menu based on the user’s choice in var.base_image.

# lookup(map, key, default) → Finds a value in a map by key, or returns a default if the key doesn’t exist.

# Here:

# local.ami_presets → The AMI menu we just built.

# var.base_image → The AMI name you want (passed in via Terraform variable).

# local.ami_presets["al2023"] → Default to Amazon Linux 2023 if you pass an invalid or missing value.

# Analogy:
# It’s like saying:

# “Look up the recipe for the image name I asked for. If it’s not on the menu, just give me the Amazon Linux 2023 recipe.”

  ami_selected = lookup(local.ami_presets, var.base_image, local.ami_presets["al2023"])
}

# 🔍 Dynamically find the latest AMI for the selected preset in this region
data "aws_ami" "selected" {
  most_recent = true
# Tells Terraform to pick the latest image that matches your filters.
# Without this, AWS might return an older one first.
  owners      = local.ami_selected.owners
# Uses the owners value from your earlier ami_selected local.
# Examples:
# ["amazon"] → Official Amazon Linux AMIs.
# ["099720109477"] → Canonical’s official Ubuntu AMIs.
# This ensures you don’t accidentally pull a fake/malicious image someone else published.

# the filter blocks narrow down the search results — each one is ANDed together (must match all)

  filter {
    name   = "name"
    values = [local.ami_selected.name]
# Matches the AMI name pattern from your preset (ami_presets).
# Supports * wildcards — so "al2023-ami-*-kernel-6.1-x86_64" matches any AL2023 image with kernel 6.1.
  }

  filter {
    name   = "architecture"
    values = [var.ami_architecture]
# Ensures you get the right CPU type (e.g., x86_64 or arm64).
# Controlled by a variable so you can switch if you ever run ARM-based EC2.
  }

  filter {
    name   = "virtualization-type"
    values = [var.ami_virtualization_type]
# Most modern AWS instances use HVM (hardware virtual machine).
# Rarely changes unless using legacy PV virtualization.
  }

  filter {
    name   = "root-device-type"
    values = [var.ami_root_device_type]
# Defines the boot disk type:
# ebs → Root disk is an EBS volume (most common).
# instance-store → Temporary storage tied to the instance.
  }
}
# This data "aws_ami" currently runs a search in AWS for:

# Owner Amazon

# Name starting with al2023-ami...

# Architecture x86_64

# Virtualization hvm

# Root device ebs

# It picks the newest match in your current AWS region.

# Analogy:
# Think of this like ordering a coffee from a menu:

# The preset (ami_selected) is the type of drink you chose (Latte, Cappuccino, Espresso).

# The filters are your customizations (size, milk type, temperature).

# most_recent = true means “give me the freshest one available right now.”

# ...then in your aws_instance "app":
# ami = data.aws_ami.selected.id


# Security Group: Allow only HTTP/HTTPS inbound, all outbound +SSH from your IP only
resource "aws_security_group" "web_sg" {
# aws_security_group → Tells Terraform you’re creating a security group in AWS.

# "web_sg" → Terraform’s internal name for referencing it (aws_security_group.web_sg.id).

# name → The actual AWS name for the SG.

# description → What it’s for (shows up in AWS console).

# vpc_id → Associates it with a specific VPC 
  name        = "employee-webapp-sg"
  description = "Allow HTTP/HTTPS only"
  vpc_id      = aws_vpc.main.id
########################################
  # HTTP (IPv4 + IPv6)
  ########################################
# from_port / to_port = 80 → This is HTTP.

# protocol = "tcp" → The TCP protocol.

# cidr_blocks = ["0.0.0.0/0"] → Means "from any IPv4 address in the world".
  ingress {
    description = "HTTP from anywhere (IPv4)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

# ::/0 is the IPv6 equivalent of "allow from anywhere".

# Same as above but for IPv6 traffic.
  ingress {
    description      = "HTTP from anywhere (IPv6)"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    ipv6_cidr_blocks = ["::/0"]
  }
  ########################################
  # HTTPS (IPv4 + IPv6)
  ########################################
  ingress {
    description = "HTTPS from anywhere (IPv4)"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description      = "HTTPS from anywhere (IPv6)"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    ipv6_cidr_blocks = ["::/0"]
  }
  ########################################
  # SSH (IPv4 only — restricted)
  ########################################
  ingress {
    description = "SSH from my IP only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_ip] # ✅ Will pull from variables.tf
  }
########################################
  # Egress Rules (all Outbound) 
  ########################################
# from_port / to_port = 0 → Matches all ports.

# protocol = "-1" → Means "all protocols".

# IPv4 + IPv6 → Allow traffic to any destination.

# This means your EC2 can make outbound requests anywhere (updates, APIs, S3, etc.).
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

# Adds a Name tag in AWS for easier identification.
  tags = {
    Name = "employee-webapp-sg"
  }
}

# User data for bootstrapping Flask app (minimal, original style)
# Purpose
# This block creates a multi-line string (HEREDOC) in Terraform called local.user_data.
# That string is passed to EC2 as a user data script, which AWS runs once when the instance boots for the first time.

# It’s basically Terraform’s way of saying:

# “When the EC2 server starts, run these Linux commands automatically to set up my app.”

# ### 1. Locals

# ```hcl
# locals {
#   user_data = <<-EOF
# ```

# * **`locals {}`** → Defines local variables in Terraform (can be reused within the same module).
# * **`user_data`** → The name we gave this local variable to hold the EC2 startup script.
# * **`<<-EOF ... EOF`** → HEREDOC syntax for multi-line strings in Terraform (keeps formatting exactly as written).

# ---

# ### 2. Script begins

# ```bash
# #!/bin/bash
# set -eux
# ```

# * **`#!/bin/bash`** → Tells the system to run this script using Bash.
# * **`set -eux`** → Adds safety and debug visibility:

#   * `-e` → Exit if any command fails.
#   * `-u` → Exit if an undefined variable is used.
#   * `-x` → Print each command before running it (helps debug in EC2 logs).

# ---

# ### 3. Move into the EC2 default user’s home directory

# ```bash
# cd /home/ec2-user
# ```

# * Amazon Linux instances have a default user called **`ec2-user`**.
# * This ensures all subsequent commands run in that user’s home folder.

# ---

# ### 4. Install system dependencies (before unzipping)

# ```bash
# dnf -y install unzip python3 python3-pip
# dnf -y install stress || true
# ```

# * **`dnf`** → Amazon Linux 2023 package manager.
# * Installs:

#   * `unzip` → Needed to extract `.zip` files (installed *before* running unzip).
#   * `python3` → Python runtime.
#   * `python3-pip` → Python package manager.
#   * `stress` → CPU load testing tool (optional, errors ignored with `|| true`).

# ---

# ### 5. Download and extract the Flask app

# ```bash
# curl -O https://aws-tc-largeobjects.s3-us-west-2.amazonaws.com/DEV-AWS-MO-GCNv2/FlaskApp.zip
# unzip -o FlaskApp.zip
# cd FlaskApp
# ```

# * **`curl -O`** → Downloads the app ZIP file from an AWS training S3 bucket.
# * **`unzip -o`** → Extracts files, overwriting if they already exist.
# * **`cd FlaskApp`** → Moves into the extracted app folder.

# ---

# ### 6. Install Python packages

# ```bash
# pip3 install --upgrade pip
# pip3 install -r requirements.txt
# ```

# * Upgrades `pip` to the latest version.
# * Installs all required Python packages listed in `requirements.txt`.

# ---

# ### 7. Set environment variables

# ```bash
# export PHOTOS_BUCKET=employee-flask-app
# export AWS_DEFAULT_REGION=${var.aws_region}
# export DYNAMO_MODE=on
# export FLASK_APP=application
# ```

# * **`PHOTOS_BUCKET`** → S3 bucket name where employee photos are stored.
# * **`AWS_DEFAULT_REGION`** → Set dynamically from your Terraform `aws_region` variable.
# * **`DYNAMO_MODE`** → Enables DynamoDB mode in the app.
# * **`FLASK_APP`** → Tells Flask which application file to run.

# ---

# ### 8. Run the Flask app on port 80

# ```bash
# nohup python3 -m flask run --host=0.0.0.0 --port=80 >/var/log/flaskapp.log 2>&1 &
# ```

# * **`nohup`** → Keeps the process running after the script finishes.
# * **`python3 -m flask run`** → Launches Flask using the module flag (`-m`).
# * **`--host=0.0.0.0`** → Makes the app accessible from any network interface (needed for public access).
# * **`--port=80`** → Runs on HTTP port 80 (open in the SG).
# * Output redirection:

#   * `>/var/log/flaskapp.log` → Saves standard output to a log file.
#   * `2>&1` → Sends errors to the same log.
# * **`&`** → Runs the process in the background so the script can exit.



# --- Module 4: Flask app with S3 integration (Amazon Linux 2023) ---
locals {
  user_data = <<-EOF
    #!/bin/bash -ex 
    wget https://aws-tc-largeobjects.s3-us-west-2.amazonaws.com/DEV-AWS-MO-GCNv2/FlaskApp.zip 
    unzip FlaskApp.zip 
    cd FlaskApp/ 
    yum -y install python3 
    yum -y install python3-pip 
    pip install -r requirements.txt 
    yum -y install stress 
    export PHOTOS_BUCKET=employee-photo-bucket-456s
    export AWS_DEFAULT_REGION=eu-west-2
    export DYNAMO_MODE=on 
    FLASK_APP=application.py /usr/local/bin/flask run --host=0.0.0.0 --port=80
  EOF
}

# key_name: This is the name the key pair will have in the AWS console.

# public_key: This path points to a public key file that you must generate on your local machine.





# Collect public subnet ids to pick one
locals {
  # this loops through all public subnets created in the VPC module and gets their IDs
  public_subnet_ids = [for s in aws_subnet.public : s.id]
}

# EC2 instance
# What it is
# This resource block tells Terraform:

# “Create an EC2 instance with this AMI, this instance type, these permissions, this security group, and run this startup script.”

# aws_instance → Terraform resource type for EC2 instances.

# "app" → Terraform’s internal name for referencing this instance elsewhere (aws_instance.app.id).

resource "aws_instance" "app" {
# Uses the AMI ID from the data "aws_ami" "selected" lookup you set up earlier.

# This ensures the instance always gets the latest matching image (Amazon Linux 2023, Ubuntu, etc.) without hardcoding an AMI ID.
  ami                    = data.aws_ami.selected.id
# Picks the hardware size:

# t2.micro → Free-tier eligible, 1 vCPU, 1 GB RAM.

# Good for testing and low-cost deployments.
  instance_type          = "t2.micro"
# Attaches the IAM instance profile you created in Module 1 (EmployeeWebAppInstanceProfile).

# Gives the EC2 instance AWS permissions (e.g., read/write S3 bucket, read/write DynamoDB).
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
# Associates your EC2 with the web_sg security group.

# This enforces the inbound/outbound traffic rules you defined earlier (HTTP/HTTPS open, optional SSH from your IP).
  vpc_security_group_ids = [aws_security_group.web_sg.id]

# Put EC2 in the first public subnet
  subnet_id                   = local.public_subnet_ids[0]

associate_public_ip_address = true  # ensure a public IPv4 is attached

# Passes your startup script (locals.user_data) to EC2.

# AWS runs this script once on first boot to:

# Download and install your app

# Install dependencies

# Start the Flask app
  user_data              = local.user_data
# By default, changing user_data won’t trigger an instance replacement.

# This forces Terraform to terminate and recreate the EC2 instance if the script changes — ensuring your changes actually take effect.
  user_data_replace_on_change = true

# Adds a Name tag in AWS for easier identification in the console.

# Tagging is also useful for cost tracking and automation
  tags = {
    Name = "employee-webapp-ec2"
  }
}

# Flow of Dependencies
# AMI → Comes from data.aws_ami.selected (dynamic lookup).

# IAM profile → Comes from Module 1.

# Security group → Comes from your SG resource.

# User data → Comes from your locals.user_data block.

# Terraform builds the EC2 instance only after all of the above are ready.

# Analogy:
# Think of this as filling out an order form for a server:

# AMI → Which OS?

# Instance type → How powerful?

# IAM profile → What keys to the AWS kingdom?

# Security group → Who can knock on the door?

# User data → What should it do as soon as it’s turned on?



########################################
# Helpful Outputs
########################################
output "ec2_public_ip" {
  description = "Public IP of the web app instance"
  value       = aws_instance.app.public_ip
}

output "ec2_public_dns" {
  description = "Public DNS of the web app instance"
  value       = aws_instance.app.public_dns
}

output "app_url" {
  description = "Convenience URL to test the app"
  value       = "http://${aws_instance.app.public_dns}"
}

output "selected_ami_id" {
  description = "AMI ID used by the instance"
  value       = data.aws_ami.selected.id
}

output "selected_ami_name" {
  description = "AMI name matched by filters"
  value       = data.aws_ami.selected.name
}
