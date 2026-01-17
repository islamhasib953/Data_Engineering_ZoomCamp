# main.tf
# ═══════════════════════════════════════════════════════════

# ─────────────────────────────────────────
# Local Variables
# ─────────────────────────────────────────
locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    CreatedBy   = "Terraform"
    CreatedAt   = timestamp()
  }
}

# ─────────────────────────────────────────
# Web Servers (Multiple)
# ─────────────────────────────────────────
module "web_server" {
  source = "./modules/webserver"
  count  = var.web_server_count

  server_name   = "${var.project_name}-web-${count.index + 1}"
  instance_type = var.web_instance_type
  ami_id        = var.ami_id
  environment   = var.environment
  allowed_ports = [22, 80, 443]
  tags          = local.common_tags
}

# ─────────────────────────────────────────
# API Server (Conditional)
# ─────────────────────────────────────────
module "api_server" {
  source = "./modules/webserver"
  count  = var.create_api_server ? 1 : 0

  server_name   = "${var.project_name}-api"
  instance_type = var.api_instance_type
  ami_id        = var.ami_id
  environment   = var.environment
  allowed_ports = [22, 8080]
  tags          = local.common_tags
}