output "vpc_id" {
  description = "ID của VPC"
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "Danh sách ID public subnets"
  value       = [for s in aws_subnet.public : s.id]
}

output "private_subnet_ids" {
  description = "Danh sách ID private subnets"
  value       = [for s in aws_subnet.private : s.id]
}
