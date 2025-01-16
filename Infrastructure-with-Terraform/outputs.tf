output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "web_instance_public_ip" {
  description = "Public IP of web server"
  value       = aws_instance.web.public_ip
}

output "db_instance_private_ip" {
  description = "Private IP of database server"
  value       = aws_instance.db.private_ip
}
