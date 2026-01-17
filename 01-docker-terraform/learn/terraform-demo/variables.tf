# variables.tf
# ═══════════════════════════════════════════════════════════

# ─────────────────────────────────────────
# General Variables
# ─────────────────────────────────────────
variable "project_name" {
  description = "اسم المشروع"
  type        = string
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "البيئة (dev, staging, prod)"
  type        = string
}

# ─────────────────────────────────────────
# EC2 Variables
# ─────────────────────────────────────────
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

# ─────────────────────────────────────────
# Feature Flags
# ─────────────────────────────────────────
variable "create_api_server" {
  description = "هل تنشئ API Server؟"
  type        = bool
  default     = false
}

variable "web_server_count" {
  description = "عدد Web Servers"
  type        = number
  default     = 1
}