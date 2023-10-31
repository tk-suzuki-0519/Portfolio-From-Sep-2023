output "vpc_id" {
  description = "ID of project VPC"
  value       = aws_vpc.prod_vpc.id
}