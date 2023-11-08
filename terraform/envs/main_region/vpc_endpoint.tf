# -----------------------------------
# VPC endpoint
# -----------------------------------
# VPC endpoint(Gateway) for S3
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = format("com.amazonaws.%s.s3", var.main_region)
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private_app_rt.id]
  tags = {
    Name = format("%s_endpoint_s3", var.env_name)
  }
}

# AWS PrivateLink(VPC endpoint(Interface))
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = format("com.amazonaws.%s.ecr.dkr", var.main_region)
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = [for subnet in aws_subnet.private_subnet_app : subnet.id]
  #  security_group_ids  = [aws_security_group.vpc_endpoint_sg.id]
  tags = {
    Name = format("%s_endpoint_ecr_dkr", var.env_name)
  }
}
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = format("com.amazonaws.%s.ecr.api", var.main_region)
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = [for subnet in aws_subnet.private_subnet_app : subnet.id]
  #  security_group_ids  = [aws_security_group.vpc_endpoint_sg.id]
  tags = {
    Name = format("%s_endpoint_ecr_api", var.env_name)
  }
}
resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = format("com.amazonaws.%s.ssm", var.main_region)
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = [for subnet in aws_subnet.private_subnet_app : subnet.id]
  #  security_group_ids  = [aws_security_group.vpc_endpoint_sg.id]
  tags = {
    Name = format("%s_endpoint_ssm", var.env_name)
  }
}
resource "aws_vpc_endpoint" "logs" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = format("com.amazonaws.%s.logs", var.main_region)
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = [for subnet in aws_subnet.private_subnet_app : subnet.id]
  #  security_group_ids  = [aws_security_group.vpc_endpoint_sg.id]
  tags = {
    Name = format("%s_endpoint_logs", var.env_name)
  }
}