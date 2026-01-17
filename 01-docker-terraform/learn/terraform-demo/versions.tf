# versions.tf

terraform {
  required_version = ">= 1.0.0"

  # ─────────────────────────────────────────
  # Backend Configuration
  # ─────────────────────────────────────────
  backend "s3" {
    bucket         = "my-terraform-state-bucket-12345"
    key            = "project-name/terraform.tfstate"
    region         = "us-east-1"
    
    # State Locking
    dynamodb_table = "terraform-state-locks"
    
    # Encryption
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}