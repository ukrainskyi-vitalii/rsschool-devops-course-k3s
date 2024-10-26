output "main_vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_1_id" {
  description = "Public subnet ID"
  value       = aws_subnet.public.id
}

output "private_subnet_1_id" {
  description = "Private subnet ID"
  value       = aws_subnet.private.id
}

output "private_subnet_1_cidr" {
  value = aws_subnet.private.cidr_block
}

output "main_vpc_cidr" {
  value = aws_vpc.main.cidr_block
}
