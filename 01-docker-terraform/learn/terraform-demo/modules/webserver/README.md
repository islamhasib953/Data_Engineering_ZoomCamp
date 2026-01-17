# Webserver Module

A reusable Terraform module for deploying EC2-based web servers with security groups and elastic IP addresses.

## Features

- EC2 instance with Apache web server
- Security group with configurable port access
- Elastic IP for static public addressing
- User data script for automatic Apache installation
- Comprehensive tagging for resource management

## Usage

```hcl
module "webserver" {
  source = "./modules/webserver"

  server_name   = "production-web"
  instance_type = "t2.small"
  ami_id        = "ami-0c55b159cbfafe1f0"
  environment   = "prod"
  allowed_ports = [22, 80, 443]
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.0 |
| aws | >= 4.0 |

## Resources Created

- `aws_instance` - EC2 instance with user data
- `aws_security_group` - Firewall rules for inbound traffic
- `aws_eip` - Elastic IP address

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| server_name | Server identifier for naming | `string` | - | yes |
| instance_type | EC2 instance type | `string` | `"t2.micro"` | no |
| ami_id | Amazon Machine Image ID | `string` | - | yes |
| environment | Environment tag (dev/staging/prod) | `string` | - | yes |
| allowed_ports | List of inbound ports to allow | `list(number)` | `[22, 80, 443]` | no |

## Outputs

| Name | Description |
|------|-------------|
| instance_id | EC2 instance identifier |
| public_ip | Public IP address (Elastic IP) |
| private_ip | Private IP within VPC |
| website_url | HTTP URL for accessing the server |

## Example

### Basic Web Server

```hcl
module "simple_web" {
  source = "./modules/webserver"

  server_name   = "web-01"
  instance_type = "t2.micro"
  ami_id        = "ami-0c55b159cbfafe1f0"
  environment   = "development"
}
```

### Production Web Server with Custom Ports

```hcl
module "prod_web" {
  source = "./modules/webserver"

  server_name   = "prod-web-01"
  instance_type = "t2.medium"
  ami_id        = "ami-0c55b159cbfafe1f0"
  environment   = "production"
  allowed_ports = [22, 80, 443, 8080]
}
```

### Multiple Web Servers

```hcl
module "web_cluster" {
  source = "./modules/webserver"
  count  = 3

  server_name   = "web-${count.index + 1}"
  instance_type = "t2.small"
  ami_id        = "ami-0c55b159cbfafe1f0"
  environment   = "production"
}
```

## Security Notes

- Default security group allows SSH (22), HTTP (80), and HTTPS (443)
- All outbound traffic is permitted
- Consider restricting SSH access to specific IP ranges in production
- Security group ingress rules allow traffic from 0.0.0.0/0 by default

## Accessing Outputs

```hcl
output "server_ip" {
  value = module.webserver.public_ip
}

output "server_url" {
  value = module.webserver.website_url
}
```

## Maintenance

To update the module:
1. Run `terraform init -upgrade` to fetch the latest version
2. Review changes with `terraform plan`
3. Apply updates with `terraform apply`

## Notes

The module includes a basic Apache installation via user data. For production deployments, consider using a pre-configured AMI or a configuration management tool like Ansible.