variable "server_name" {
  description = "اسم السيرفر"
  type        = string
}

variable "instance_type" {
  description = "نوع الـ Instance"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "معرف الـ AMI"
  type        = string
}

variable "environment" {
  description = "البيئة (dev, staging, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be: dev, staging, or prod"
  }
}

variable "allowed_ports" {
  description = "البورتات المسموح بها"
  type        = list(number)
  default     = [22, 80, 443]
}

variable "tags" {
  description = "Tags إضافية"
  type        = map(string)
  default     = {}
}