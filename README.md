<div align="center">

# 🏗️ AWS VPC Infrastructure — Terraform

**Production-style, multi-AZ AWS network provisioned entirely as code**

[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.5.0-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)](https://developer.hashicorp.com/terraform)
[![AWS](https://img.shields.io/badge/AWS-ap--south--1-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)](#)
[![State](https://img.shields.io/badge/State-S3%20%2B%20DynamoDB-4FE0C4?style=for-the-badge)](#)

</div>

---

## 📖 Overview

This project stands up a **3-tier AWS network from scratch** using Terraform — a real VPC with public and private subnets across two Availability Zones, a web server that's actually internet-facing, a private tier with outbound-only access via NAT, and remote state that's safe for a team to share.

No manual console clicking. `terraform apply`, and the whole network exists. `terraform destroy`, and it's gone — cleanly, every time.

---

## 🗺️ Architecture

```
Region: ap-south-1 (Mumbai)
│
├── VPC (10.0.0.0/16)
│   ├── Public Subnet  AZ-1  (10.0.1.0/24)   ← EC2 Web Server (Apache)
│   ├── Public Subnet  AZ-2  (10.0.2.0/24)
│   ├── Private Subnet AZ-1  (10.0.10.0/24)
│   └── Private Subnet AZ-2  (10.0.20.0/24)
│
├── Internet Gateway  → Public Subnets  (inbound + outbound)
├── NAT Gateway        → Private Subnets (outbound only)
│
├── EC2 (Amazon Linux 2, t2.micro, Apache via user_data)
│   └── IAM Role → S3 read access (no hardcoded credentials)
│
└── S3 Static Website Bucket (public, versioned)

Remote State: S3 backend + DynamoDB state locking
```

**Why it's built this way:**
- **Two AZs, not one** — the network survives a single Availability Zone going down.
- **Public/private split** — only the web tier is internet-facing; everything else stays behind NAT.
- **IAM role over access keys** — the EC2 instance talks to S3 through an instance profile, not stored credentials.
- **Remote state with locking** — S3 holds the state file, DynamoDB prevents two people (or two pipeline runs) from applying at the same time and corrupting it.

---

## 📦 Resources Provisioned

| Resource | Description |
|---|---|
| **VPC** | Custom VPC with DNS support + DNS hostnames enabled |
| **Subnets** | 2 public + 2 private, spread across 2 Availability Zones |
| **Internet Gateway** | Routes public subnet traffic to/from the internet |
| **NAT Gateway** | Gives private subnets outbound-only internet access |
| **Route Tables** | Separate public and private route tables |
| **EC2 Instance** | Amazon Linux 2, Apache installed automatically via `user_data` |
| **Security Group** | Inbound SSH (22) + HTTP (80) only |
| **IAM Role** | EC2 instance profile with S3 read-only access |
| **S3 Bucket** | Static website hosting, versioned, public bucket policy |
| **Remote State** | S3 backend + DynamoDB table for state locking |

---

## ✅ Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) `>= 1.5.0`
- AWS CLI configured — `aws configure`
- An existing EC2 key pair in `ap-south-1`

---

## 🚀 Usage

### Step 1 — Bootstrap remote state *(run once)*
```bash
cd bootstrap/
terraform init
terraform apply
```

### Step 2 — Deploy the main infrastructure
```bash
cd ..
terraform init
terraform plan
terraform apply
```

### Step 3 — Grab your outputs
```bash
# EC2 public IP
terraform output ec2_public_ip

# S3 static website URL
terraform output s3_website_endpoint
```

### 🧹 Tear it all down
```bash
terraform destroy
```

---

## ⚙️ Variables

| Variable | Default | Description |
|---|---|---|
| `aws_region` | `ap-south-1` | AWS region |
| `environment` | `dev` | Environment tag |
| `vpc_cidr` | `10.0.0.0/16` | VPC CIDR block |
| `instance_type` | `t2.micro` | EC2 instance type |
| `key_pair_name` | `my-key-pair` | EC2 key pair name |
| `s3_bucket_name` | `my-static-site-hari-2026` | S3 bucket name (must be globally unique) |

---

## 🛠️ Tech Stack

- **Terraform** `>= 1.5`
- **AWS**: VPC · EC2 · S3 · IAM · DynamoDB · NAT Gateway
- **Region**: `ap-south-1` (Mumbai)

---

## 📸 Screenshots

<img width="1645" height="1011" alt="Terraform apply output showing provisioned resources" src="https://github.com/user-attachments/assets/3479735c-e1f1-4f3a-9364-ea4296bf7b67" />

<img width="1919" height="981" alt="AWS Console view of deployed VPC infrastructure" src="https://github.com/user-attachments/assets/7e2ec69c-7699-45a6-99c8-a87a794ed012" />

---

## 📬 Contact

<div align="center">

[![Email](https://img.shields.io/badge/Email-shindeshrihari8%40gmail.com-D14836?style=flat-square&logo=gmail&logoColor=white)](mailto:shindeshrihari8@gmail.com)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-shrihari--shinde-0A66C2?style=flat-square&logo=linkedin&logoColor=white)](https://linkedin.com/in/shrihari-shinde-1958aa1a5)
[![GitHub](https://img.shields.io/badge/GitHub-shrihari2259-181717?style=flat-square&logo=github&logoColor=white)](https://github.com/shrihari2259)

</div>

---

<div align="center">
<sub>My first end-to-end Terraform project — built, broken, and fixed until `terraform apply` ran clean. ⭐ Star it if it helped you learn IaC.</sub>
</div>
