# modules/webserver/outputs.tf
# ═══════════════════════════════════════════════════════════

output "instance_id" {
  description = "معرف الـ EC2 Instance"
  value       = aws_instance.this.id
}

output "public_ip" {
  description = "عنوان IP العام (Elastic IP)"
  value       = aws_eip.this.public_ip
}

output "private_ip" {
  description = "عنوان IP الخاص"
  value       = aws_instance.this.private_ip
}

output "security_group_id" {
  description = "معرف الـ Security Group"
  value       = aws_security_group.this.id
}

output "website_url" {
  description = "رابط الموقع"
  value       = "http://${aws_eip.this.public_ip}"
}