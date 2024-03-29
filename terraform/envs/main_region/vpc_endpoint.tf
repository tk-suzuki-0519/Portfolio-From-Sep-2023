# -----------------------------------
# VPC endpoint
# -----------------------------------
# VPC endpoint(Gateway) for S3
/*
resource "aws_vpc_endpoint" "s3_from_app" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = format("com.amazonaws.%s.s3_from_app", var.main_region)
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.public_app_rt.id]
  tags = {
    Name = format("%s_endpoint_s3_from_app", var.env_name)
  }
}

# AWS PrivateLink(VPC endpoint(Interface))
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
*/