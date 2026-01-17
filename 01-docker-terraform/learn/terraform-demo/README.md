# Terraform AWS Infrastructure Project

A modular Terraform configuration for deploying scalable web infrastructure on AWS.

## Overview

This project demonstrates Infrastructure as Code (IaC) best practices using Terraform to provision EC2-based web servers with proper security controls and static IP assignments.

## Architecture

The infrastructure consists of:
- Multiple web server instances (configurable count)
- Optional API server for backend services
- Security groups with customizable firewall rules
- Elastic IP addresses for stable public endpoints

## Project Structure

```
terraform-demo/
├── main.tf              # Resource definitions
├── variables.tf         # Input variable declarations
├── outputs.tf           # Output value definitions
├── terraform.tfvars     # Variable value assignments
├── providers.tf         # Provider configurations
├── versions.tf          # Version constraints
└── modules/
    └── webserver/       # Reusable webserver module
        ├── main.tf
        ├── variables.tf
        ├── outputs.tf
        └── README.md
```

## Prerequisites

- Terraform >= 1.0.0
- AWS CLI configured with appropriate credentials
- Active AWS account with EC2 permissions

## Quick Start

### Initialize Project

```bash
terraform init
```

This downloads required provider plugins and sets up the backend.

### Plan Changes

```bash
terraform plan
```

Review the proposed infrastructure changes before applying.

### Apply Configuration

```bash
terraform apply
```

Confirm the action to provision resources.

### Destroy Resources

```bash
terraform destroy
```

Remove all infrastructure when no longer needed.

## Configuration

### Input Variables

| Variable | Description | Type | Default | Required |
|----------|-------------|------|---------|----------|
| project_name | Project identifier | string | - | yes |
| aws_region | AWS deployment region | string | us-east-1 | no |
| environment | Environment name | string | - | yes |
| web_server_count | Number of web servers | number | 1 | no |
| create_api_server | Deploy API server | bool | false | no |

### Customizing Variables

Edit `terraform.tfvars` to match your requirements:

```hcl
project_name      = "my-web-app"
environment       = "production"
web_server_count  = 3
create_api_server = true
```

## Module Usage

The webserver module encapsulates EC2 instance creation with security groups and elastic IPs:

```hcl
module "web" {
  source = "./modules/webserver"

  server_name   = "web-server-01"
  instance_type = "t2.micro"
  ami_id        = "ami-0c55b159cbfafe1f0"
  environment   = "production"
  allowed_ports = [22, 80, 443]
}
```

## Outputs

After successful deployment, Terraform provides:
- Public IP addresses for each server
- Full HTTP URLs for accessing web servers
- Instance IDs for management tasks

## Security Considerations

- Security groups restrict inbound traffic to specified ports
- SSH access should be limited to trusted IP ranges in production
- Use AWS Secrets Manager or similar for sensitive data
- Enable CloudTrail for audit logging

## Cost Management

This configuration uses t2.micro instances by default, which qualify for AWS Free Tier. Monitor your usage to avoid unexpected charges.

## Troubleshooting

### Common Issues

**State Lock Error**
```bash
terraform force-unlock <LOCK_ID>
```

**Provider Authentication**
```bash
aws configure
```

**Module Updates**
```bash
terraform init -upgrade
```

## Best Practices Applied

- Modular design for reusability
- Explicit version constraints
- Comprehensive variable validation
- Detailed output definitions
- Environment-based tagging

## Contributing

When modifying this infrastructure:
1. Test changes in a development environment first
2. Run `terraform fmt` to format code
3. Run `terraform validate` to check syntax
4. Update documentation as needed

## License

MIT