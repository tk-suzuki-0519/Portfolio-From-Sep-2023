# -----------------------------------
# VPC endpoint
# -----------------------------------
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = format("com.amazonaws.%s.ecr.dkr", var.main_region)
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = [for subnet in aws_subnet.public_subnet_app : subnet.id]
  security_group_ids  = [aws_security_group.vpc_endpoint_sg.id]
  tags = {
    Name = format("%s_endpoint_ecr_dkr", var.env_name)
  }
}
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = format("com.amazonaws.%s.ecr.api", var.main_region)
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = [for subnet in aws_subnet.public_subnet_app : subnet.id]
  security_group_ids  = [aws_security_group.vpc_endpoint_sg.id]
  tags = {
    Name = format("%s_endpoint_ecr_api", var.env_name)
  }
}
resource "aws_vpc_endpoint" "logs" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = format("com.amazonaws.%s.logs", var.main_region)
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = [for subnet in aws_subnet.public_subnet_app : subnet.id]
  security_group_ids  = [aws_security_group.vpc_endpoint_sg.id]
  tags = {
    Name = format("%s_endpoint_logs", var.env_name)
  }
}