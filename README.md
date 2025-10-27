# Cloud Resume Challenge - AWS Infrastructure

[![Terraform](https://img.shields.io/badge/Terraform-v1.12.2-623CE4?logo=terraform)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-Cloud-FF9900?logo=amazon-aws)](https://aws.amazon.com/)

## 📋 Overview

This repository contains the **Infrastructure as Code (IaC)** for the [Cloud Resume Challenge](https://cloudresumechallenge.dev/docs/the-challenge/aws/), implementing a serverless resume website with visitor counter functionality on AWS using Terraform.

**Live Site:** [lukamasa.com](https://lukamasa.com)

**Frontend Repository:** [greqq/cloud-resume](https://github.com/greqq/cloud-resume)

---

## 🏗️ Architecture

```
┌─────────────┐
│  Cloudflare │  DNS Management
│     DNS     │  lukamasa.com → CloudFront
└──────┬──────┘
       │
       ▼
┌─────────────────────────────────────────────────────────────┐
│                      AWS Infrastructure                      │
│                                                              │
│  ┌──────────────┐      ┌─────────────┐                     │
│  │  CloudFront  │──────│  S3 Bucket  │  Website Hosting    │
│  │     (CDN)    │      │ (Private)   │                     │
│  └──────────────┘      └─────────────┘                     │
│                                                              │
│  ┌──────────────┐      ┌─────────────┐      ┌───────────┐ │
│  │ API Gateway  │──────│   Lambda    │──────│ DynamoDB  │ │
│  │  (REST API)  │      │  (Python)   │      │  Tables   │ │
│  └──────────────┘      └─────────────┘      └───────────┘ │
│                                                              │
│  ┌──────────────┐      ┌─────────────┐                     │
│  │  CloudWatch  │──────│     SNS     │  Monitoring         │
│  │   Alarms     │      │   Topics    │                     │
│  └──────────────┘      └─────────────┘                     │
└─────────────────────────────────────────────────────────────┘
```

---

## 🧩 Modules

| Module | Purpose | Key Resources |
|--------|---------|---------------|
| **s3** | Static website hosting | S3 bucket with CloudFront OAC |
| **cloudfront** | CDN with HTTPS | Distribution, cache policy, OAC |
| **certificate** | SSL/TLS certificate | ACM certificate (DNS validation) |
| **lambda** | Visitor counter logic | Python function, IAM role |
| **api_gateway** | REST API endpoint | API Gateway with CORS support |
| **dynamodb** | Visitor count storage | VisitorCounter table |
| **dynamodb_unique_visits** | Unique visitor tracking | UniqueVisitors table |
| **monitoring** | Alarms & notifications | CloudWatch alarms, SNS topics |

---

## 🚀 Getting Started

### Prerequisites

- **Terraform:** v1.12.0 or higher
- **AWS CLI:** Configured with SSO
- **AWS Account:** With appropriate permissions
- **Git:** For version control

### Initial Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/greqq/terraform-aws-infrastructure.git
   cd terraform-aws-infrastructure
   ```

2. **Login to AWS SSO:**
   ```bash
   ./aws-login.sh
   # Or manually:
   aws sso login --profile FullAccessLambdaDynamo-591968772652
   export AWS_PROFILE=FullAccessLambdaDynamo-591968772652
   ```

3. **Initialize Terraform:**
   ```bash
   cd environments/production
   terraform init -backend-config=backend.conf
   ```

4. **Review planned changes:**
   ```bash
   terraform plan
   ```

5. **Apply infrastructure:**
   ```bash
   terraform apply
   ```

---

## 📁 Project Structure

```
terraform-aws-infrastructure/
├── README.md
├── aws-login.sh                    # AWS SSO login helper
├── setup-dev-environment.sh        # Dev environment setup
│
├── environments/
│   ├── development/                # Dev environment (isolated testing)
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   └── production/                 # Production environment
│       ├── main.tf                 # Module composition
│       ├── variables.tf            # Variable definitions
│       ├── terraform.tfvars        # Configuration values
│       ├── outputs.tf              # Exported values
│       └── backend.conf            # S3 backend config
│
└── modules/                        # Reusable infrastructure components
    ├── api_gateway/
    ├── certificate/
    ├── cloudfront/
    ├── dynamodb/
    ├── dynamodb_unique_visits/
    ├── lambda/
    ├── monitoring/
    └── s3/
```

---

## 🔐 Backend Configuration

### Remote State Storage

Terraform state is stored remotely in **S3** with **DynamoDB locking** to prevent concurrent modifications:

```hcl
bucket         = "terraform-state-webflow-lma"
key            = "global/s3/terraform.tfstate"
region         = "us-east-1"
dynamodb_table = "terraform-up-and-running-locks"
```

---

## 🔧 Configuration

### Key Variables (terraform.tfvars)

| Variable | Value | Description |
|----------|-------|-------------|
| `domain_name` | `lukamasa.com` | Primary domain |
| `bucket_name` | `cloud-resume-lma` | S3 bucket for website |
| `function_name` | `incrementCounter` | Lambda function name |
| `billing_mode` | `PAY_PER_REQUEST` | DynamoDB billing (serverless) |
| `environment_type` | `prod` | Environment identifier |


---

## 🔄 CI/CD Integration

The frontend repository uses GitHub Actions to:

1. **Pull infrastructure outputs** from Terraform
2. **Build Next.js app** with correct API URL (`NEXT_PUBLIC_API_URL`)
3. **Deploy to S3** bucket
4. **Invalidate CloudFront** cache

**Workflow:** `.github/workflows/ci.yaml` in [cloud-resume](https://github.com/greqq/cloud-resume)

---

## 🛠️ Common Operations

### Update Infrastructure

```bash
cd environments/production
terraform plan      # Review changes
terraform apply     # Apply changes
```

### View Current State

```bash
terraform show
terraform state list  # List all resources
```

### Destroy Resources

```bash
# ⚠️ CAUTION: This will destroy all infrastructure!
terraform destroy
```

### Unlock State (if stuck)

```bash
terraform force-unlock <LOCK_ID>
```

### Add New Resource

1. Modify or create module in `modules/`
2. Update `environments/production/main.tf` to use module
3. Add variables to `terraform.tfvars` if needed
4. Run `terraform plan` and `terraform apply`

## 🙏 Acknowledgments

- [Cloud Resume Challenge](https://cloudresumechallenge.dev/) by Forrest Brazeal
