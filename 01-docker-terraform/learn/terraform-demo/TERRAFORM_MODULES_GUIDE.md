# Terraform Modules Guide

## What is a Module?

A Terraform module is a container for multiple resources that are used together. Modules are the primary way to package and reuse resource configurations in Terraform.

## Module Structure

```
module/
├── main.tf          # Primary resource definitions
├── variables.tf     # Input variable declarations
├── outputs.tf       # Output value definitions
├── providers.tf     # Provider configurations (optional)
├── versions.tf      # Version constraints (optional)
└── README.md        # Documentation
```

## Why Use Modules?

### Benefits

1. **Reusability** - Write once, use multiple times
2. **Organization** - Group related resources logically
3. **Encapsulation** - Hide implementation details
4. **Consistency** - Enforce standards across deployments
5. **Maintainability** - Update in one place, apply everywhere

## Module Types

### 1. Root Module
The main working directory where you run Terraform commands. Every Terraform configuration has at least one module, the root module.

### 2. Child Module
A module that is called by another module. Can be local or remote.

### 3. Published Module
Modules published to the Terraform Registry or other module sources, ready for public consumption.

## Creating a Module

### Basic Structure

```hcl
# modules/ec2-instance/variables.tf
variable "instance_name" {
  description = "Name tag for the instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "AMI ID to use for the instance"
  type        = string
}

variable "environment" {
  description = "Environment tag"
  type        = string
  default     = "dev"
}
```

```hcl
# modules/ec2-instance/main.tf
resource "aws_instance" "this" {
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = {
    Name        = var.instance_name
    Environment = var.environment
  }
}

resource "aws_eip" "this" {
  instance = aws_instance.this.id
  domain   = "vpc"

  tags = {
    Name = "${var.instance_name}-eip"
  }
}
```

```hcl
# modules/ec2-instance/outputs.tf
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.this.id
}

output "public_ip" {
  description = "Public IP address"
  value       = aws_eip.this.public_ip
}

output "private_ip" {
  description = "Private IP address"
  value       = aws_instance.this.private_ip
}
```

## Using Modules

### Local Module

```hcl
module "web_server" {
  source = "./modules/ec2-instance"

  instance_name = "web-server-01"
  ami_id        = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.small"
  environment   = "production"
}

module "db_server" {
  source = "./modules/ec2-instance"

  instance_name = "db-server-01"
  ami_id        = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.medium"
  environment   = "production"
}
```

### Accessing Module Outputs

```hcl
output "web_server_ip" {
  value = module.web_server.public_ip
}

output "db_server_ip" {
  value = module.db_server.private_ip
}
```

## Module Sources

Terraform supports various module sources:

### Local Path
```hcl
module "local" {
  source = "./modules/my-module"
}
```

### Terraform Registry
```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"
}
```

### GitHub
```hcl
module "github" {
  source = "github.com/username/repo//modules/example"
}
```

### Git URL with Tag
```hcl
module "git" {
  source = "git::https://example.com/repo.git?ref=v1.0.0"
}
```

### S3 Bucket
```hcl
module "s3" {
  source = "s3::https://s3-eu-west-1.amazonaws.com/bucket/module.zip"
}
```

## Advanced Features

### Count with Modules

```hcl
module "web_servers" {
  source = "./modules/ec2-instance"
  count  = 3

  instance_name = "web-${count.index + 1}"
  ami_id        = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  environment   = "production"
}

output "web_ips" {
  value = module.web_servers[*].public_ip
}
```

### For_each with Modules

```hcl
module "app_servers" {
  source   = "./modules/ec2-instance"
  for_each = {
    api    = "t2.medium"
    worker = "t2.small"
    cache  = "t2.micro"
  }

  instance_name = each.key
  instance_type = each.value
  ami_id        = "ami-0c55b159cbfafe1f0"
  environment   = "production"
}

output "app_ips" {
  value = {
    for k, v in module.app_servers : k => v.public_ip
  }
}
```

## Provider Configuration

### Passing Providers to Modules

```hcl
provider "aws" {
  alias  = "us_east"
  region = "us-east-1"
}

provider "aws" {
  alias  = "eu_west"
  region = "eu-west-1"
}

module "us_infrastructure" {
  source = "./modules/infrastructure"

  providers = {
    aws = aws.us_east
  }
}

module "eu_infrastructure" {
  source = "./modules/infrastructure"

  providers = {
    aws = aws.eu_west
  }
}
```

## Input Validation

```hcl
variable "environment" {
  description = "Deployment environment"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string

  validation {
    condition     = can(regex("^t[23]\\.", var.instance_type))
    error_message = "Instance type must be from t2 or t3 family."
  }
}
```

## Best Practices

### 1. Documentation
- Always include a README.md with usage examples
- Document all variables and outputs
- Specify version requirements

### 2. Versioning
- Use semantic versioning for published modules
- Pin module versions in production

```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"  # Allow 5.x updates
}
```

### 3. Single Purpose
- Each module should solve one problem well
- Keep modules focused and composable

### 4. Useful Outputs
- Export all potentially useful values
- Include computed values consumers might need

### 5. Input Validation
- Validate inputs to catch errors early
- Provide clear error messages

### 6. Clear Naming
- Use descriptive variable names
- Follow consistent naming conventions

## Module Commands

```bash
# Download and update modules
terraform init

# Update to latest module versions
terraform init -upgrade

# Show module tree
terraform providers

# List resources in a module
terraform state list module.web_server

# Show module resource details
terraform state show module.web_server.aws_instance.this
```

## Example: Complete Module Implementation

### Directory Structure
```
terraform-project/
├── main.tf
├── variables.tf
├── outputs.tf
└── modules/
    └── webserver/
        ├── main.tf
        ├── variables.tf
        ├── outputs.tf
        └── README.md
```

### Module Definition (modules/webserver/main.tf)
```hcl
resource "aws_security_group" "this" {
  name        = "${var.server_name}-sg"
  description = "Security group for ${var.server_name}"

  dynamic "ingress" {
    for_each = var.allowed_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.server_name}-sg"
    Environment = var.environment
  }
}

resource "aws_instance" "this" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.this.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              EOF

  tags = {
    Name        = var.server_name
    Environment = var.environment
  }
}

resource "aws_eip" "this" {
  instance = aws_instance.this.id
  domain   = "vpc"

  tags = {
    Name        = "${var.server_name}-eip"
    Environment = var.environment
  }
}
```

### Root Module Usage (main.tf)
```hcl
provider "aws" {
  region = "us-east-1"
}

module "web_cluster" {
  source = "./modules/webserver"
  count  = 3

  server_name   = "web-${count.index + 1}"
  instance_type = "t2.micro"
  ami_id        = "ami-0c55b159cbfafe1f0"
  environment   = "production"
  allowed_ports = [22, 80, 443]
}

output "web_server_ips" {
  value = module.web_cluster[*].public_ip
}

output "web_server_urls" {
  value = [for m in module.web_cluster : m.website_url]
}
```

## Troubleshooting

### Module Not Found
```bash
# Reinitialize to download modules
terraform init
```

### Module Update Issues
```bash
# Force module update
terraform init -upgrade
```

### State Issues
```bash
# Move module resources
terraform state mv module.old_name module.new_name

# Remove module from state
terraform state rm module.removed_module
```

## Resources

- [Terraform Module Documentation](https://www.terraform.io/docs/language/modules/index.html)
- [Terraform Registry](https://registry.terraform.io/)
- [Module Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)
