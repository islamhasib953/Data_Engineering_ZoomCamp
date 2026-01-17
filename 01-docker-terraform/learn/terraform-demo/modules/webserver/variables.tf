variable "server_name" {
  description = "server name"
  type        = string
}

variable "instance_type" {
  description = "EC2 Instance Type"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be: dev, staging, or prod"
  }
}

variable "allowed_ports" {
  description = "Allowed ports"
  type        = list(number)
  default     = [22, 80, 443]
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}