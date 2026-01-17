
variable "project_name" {
  description = "project name"
  type        = string
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment (e.g., dev, staging, prod)"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
}

variable "web_instance_type" {
  description = "Instance type for web server"
  type        = string
  default     = "t2.micro"
}

variable "api_instance_type" {
  description = "Instance type for API server"
  type        = string
  default     = "t2.small"
}

variable "create_api_server" {
  description = "Create API Server?"
  type        = bool
  default     = false
}

variable "web_server_count" {
  description = "Number of web servers to create"
  type        = number
  default     = 1
}