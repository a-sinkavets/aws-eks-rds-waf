# aws-eks-rds-waf
Terraform module for provisioning EKS

## Task requirements
- [x] Provision AWS EKS cluster
- [ ] Provision RDS with multi-az
- [ ] Provision LBs and enable WAF for DDoS

## Prerequisites
- prepare S3 bucket for tfstate file (*ToDo: add DynamoDB table to enable state lock)
go to  `01-backend` folder, run:
  1) `aws configure` filling CLI credentials and AWS region
  2) `terraform -chdir=01-backend init` to prepare Terraform modules
  3) `terraform -chdir=01-backend plan` to check which resources will be created
  4) `terraform -chdir=01-backend apply`approving recources creation
- fill `variables.tf/versions.tf` files with required key and data


## How to use

- `terraform init`
- `terraform plan`
- `terraform apply`
