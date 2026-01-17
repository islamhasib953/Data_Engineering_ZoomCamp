# outputs.tf
# ═══════════════════════════════════════════════════════════

# ─────────────────────────────────────────
# Web Servers Outputs
# ─────────────────────────────────────────
output "web_servers_ips" {
  description = "Public IPs of web servers"
  value       = module.web_server[*].public_ip
}

output "web_servers_urls" {
  description = "URLs of web servers"
  value       = module.web_server[*].website_url
}

output "web_servers_ids" {
  description = "Instance IDs of web servers"
  value       = module.web_server[*].instance_id
}

# ─────────────────────────────────────────
# API Server Outputs
# ─────────────────────────────────────────
output "api_server_ip" {
  description = "Public IP of API server"
  value       = var.create_api_server ? module.api_server[0].public_ip : null
}

output "api_server_url" {
  description = "URL of API server"
  value       = var.create_api_server ? "http://${module.api_server[0].public_ip}:8080" : null
}

# ─────────────────────────────────────────
# Summary
# ─────────────────────────────────────────
output "project_summary" {
  description = "ملخص المشروع"
  value = {
    project     = var.project_name
    environment = var.environment
    region      = var.aws_region
    web_count   = var.web_server_count
    api_enabled = var.create_api_server
  }
}