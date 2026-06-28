# AWS VPC Infrastructure — Terraform

Provisions a production-style AWS infrastructure using Terraform with remote state management.

## Architecture

```
Region: ap-south-1
│
├── VPC (10.0.0.0/16)
│   ├── Public Subnet AZ-1 (10.0.1.0/24)  ← EC2 Web Server
│   ├── Public Subnet AZ-2 (10.0.2.0/24)
│   ├── Private Subnet AZ-1 (10.0.10.0/24)
│   └── Private Subnet AZ-2 (10.0.20.0/24)
│
├── Internet Gateway → Public Subnets
├── NAT Gateway → Private Subnets (outbound only)
├── EC2 (Amazon Linux 2, t2.micro, Apache)
│   └── IAM Role with S3 read access
└── S3 Static Website Bucket (public, versioned)

Remote State: S3 + DynamoDB lock
```

## Resources Provisioned

| Resource | Description |
|---|---|
| VPC | Custom VPC with DNS enabled |
| Subnets | 2 public + 2 private across 2 AZs |
| Internet Gateway | Routes public subnet traffic to internet |
| NAT Gateway | Allows private subnet outbound internet access |
| Route Tables | Separate public and private route tables |
| EC2 Instance | Amazon Linux 2, Apache installed via user_data |
| Security Group | SSH (22) + HTTP (80) inbound |
| IAM Role | EC2 instance profile with S3 read-only access |
| S3 Bucket | Static website hosting with public bucket policy |
| Remote State | S3 backend + DynamoDB state locking |

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.5.0
- AWS CLI configured (`aws configure`)
- An existing EC2 key pair in `ap-south-1`

## Usage

### Step 1 — Bootstrap remote state (run once)

```bash
cd bootstrap/
terraform init
terraform apply
```

### Step 2 — Deploy main infrastructure

```bash
cd ..
terraform init
terraform plan
terraform apply
```

### Step 3 — Access resources

```bash
# Get EC2 public IP
terraform output ec2_public_ip

# Get S3 website URL
terraform output s3_website_endpoint
```

### Destroy all resources

```bash
terraform destroy
```

## Variables

| Variable | Default | Description |
|---|---|---|
| `aws_region` | `ap-south-1` | AWS region |
| `environment` | `dev` | Environment tag |
| `vpc_cidr` | `10.0.0.0/16` | VPC CIDR block |
| `instance_type` | `t2.micro` | EC2 instance type |
| `key_pair_name` | `my-key-pair` | EC2 key pair name |
| `s3_bucket_name` | `my-static-site-hari-2026` | S3 bucket name (must be globally unique) |


## Tech Stack

- Terraform >= 1.5
- AWS: VPC, EC2, S3, IAM, DynamoDB, NAT Gateway
- Region: ap-south-1 (Mumbai)
