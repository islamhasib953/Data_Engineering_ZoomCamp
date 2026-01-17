# modules/webserver/README.md

# 🖥️ Webserver Module

## Description
This module creates a complete web server setup including:
- EC2 Instance with Apache installed
- Security Group with configurable ports
- Elastic IP for static public IP

## Usage

module "my_webserver" {
  source = "./modules/webserver"

  server_name   = "my-web-server"
  instance_type = "t2.micro"
  ami_id        = "ami-12345678"
  environment   = "dev"
  allowed_ports = [22, 80, 443]
}

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| server_name | اسم السيرفر | string | - | yes |
| instance_type | نوع الـ Instance | string | t2.micro | no |
| ami_id | معرف الـ AMI | string | - | yes |
| environment | البيئة | string | - | yes |
| allowed_ports | البورتات المسموحة | list(number) | [22,80,443] | no |

## Outputs

| Name | Description |
|------|-------------|
| instance_id | معرف الـ Instance |
| public_ip | عنوان IP العام |
| private_ip | عنوان IP الخاص |
| website_url | رابط الموقع |