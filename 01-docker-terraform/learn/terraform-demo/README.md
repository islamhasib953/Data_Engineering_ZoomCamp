# README.md

# 🚀 My Terraform Project

## 📋 Description
مشروع Terraform لإنشاء بنية تحتية على AWS تتضمن:
- Web Servers متعددة
- API Server (اختياري)
- Security Groups
- Elastic IPs

## 📁 Project Structure

terraform-project/
├── main.tf           # Main configuration
├── variables.tf      # Variable definitions
├── outputs.tf        # Output definitions
├── terraform.tfvars  # Variable values
├── providers.tf      # Provider configuration
├── versions.tf       # Version constraints
├── README.md         # This file
└── modules/
    └── webserver/    # Webserver module


## 🚀 Quick Start

### Prerequisites
- Terraform >= 1.0.0
- AWS CLI configured
- AWS Account

### Usage

# 1. Clone the project
git clone <repo-url>
cd terraform-project

# 2. Initialize Terraform
terraform init

# 3. Review the plan
terraform plan

# 4. Apply the configuration
terraform apply

# 5. Destroy when done
terraform destroy


## ⚙️ Configuration

### Variables

| Variable | Description | Default |
|----------|-------------|---------|
| project_name | اسم المشروع | - |
| aws_region | AWS Region | us-east-1 |
| environment | البيئة | - |
| web_server_count | عدد Web Servers | 1 |
| create_api_server | إنشاء API Server | false |

### Customization
عدّل ملف `terraform.tfvars` حسب احتياجاتك:

project_name      = "my-project"
environment       = "prod"
web_server_count  = 3
create_api_server = true


## 📤 Outputs
بعد `terraform apply` ستحصل على:
- Web Servers IPs
- Web Servers URLs
- API Server IP (if enabled)

## 🏗️ Architecture

┌─────────────────────────────────────────┐
│                  AWS                     │
│  ┌─────────────────────────────────┐   │
│  │     Web Server 1                 │   │
│  │     ├── EC2 Instance            │   │
│  │     ├── Security Group          │   │
│  │     └── Elastic IP              │   │
│  └─────────────────────────────────┘   │
│  ┌─────────────────────────────────┐   │
│  │     Web Server 2                 │   │
│  │     └── ...                      │   │
│  └─────────────────────────────────┘   │
│  ┌─────────────────────────────────┐   │
│  │     API Server (Optional)        │   │
│  │     └── ...                      │   │
│  └─────────────────────────────────┘   │
└─────────────────────────────────────────┘


## 👤 Author
Your Name

## 📄 License
MIT