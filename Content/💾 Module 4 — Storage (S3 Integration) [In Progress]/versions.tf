terraform {
  # Backend values are supplied at init time via -backend-config
  backend "s3" {}
#   for example 
# cd Module_1
# terraform init -backend-config=backend.hcl 
# terraform apply
}
