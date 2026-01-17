
output "instance_id" {
  description = "EC2 Instance ID"
  value       = aws_instance.this.id
}

output "public_ip" {
  description = "Elastic IP address"
  value       = aws_eip.this.public_ip
}

output "private_ip" {
  description = "Private IP address"
  value       = aws_instance.this.private_ip
}

output "security_group_id" {
  description = "Security Group ID"
  value       = aws_security_group.this.id
}

output "website_url" {
  description = "Website URL"
  value       = "http://${aws_eip.this.public_ip}"
}