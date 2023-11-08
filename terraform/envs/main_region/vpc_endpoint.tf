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
  subnet_ids          = [aws_subnet.private_subnet_app[each.key].id]
  #  security_group_ids  = [aws_security_group.vpc_endpoint_sg.id]
}
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = format("com.amazonaws.%s.ecr.api", var.main_region)
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = [aws_subnet.private_subnet_app[each.key].id]
  #  security_group_ids  = [aws_security_group.vpc_endpoint_sg.id]
}
resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = format("com.amazonaws.%s.ssm", var.main_region)
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = [aws_subnet.private_subnet_app[each.key].id]
  #  security_group_ids  = [aws_security_group.vpc_endpoint_sg.id]
}
resource "aws_vpc_endpoint" "logs" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = format("com.amazonaws.%s.logs", var.main_region)
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = [aws_subnet.private_subnet_app[each.key].id]
  #  security_group_ids  = [aws_security_group.vpc_endpoint_sg.id]
}
# AWS PrivateLink(VPC endpoint(Interface)) endpoint route table association
resource "aws_vpc_endpoint_route_table_association" "endpoint_rta_ecr_dkr" {
  route_table_id  = aws_route_table.private_app_rt.id
  vpc_endpoint_id = aws_vpc_endpoint.ecr_dkr.id
}
resource "aws_vpc_endpoint_route_table_association" "endpoint_rta_ecr_api" {
  route_table_id  = aws_route_table.private_app_rt.id
  vpc_endpoint_id = aws_vpc_endpoint.ecr_api.id
}
resource "aws_vpc_endpoint_route_table_association" "endpoint_rta_ssm" {
  route_table_id  = aws_route_table.private_app_rt.id
  vpc_endpoint_id = aws_vpc_endpoint.ssm.id
}
resource "aws_vpc_endpoint_route_table_association" "endpoint_rta_logs" {
  route_table_id  = aws_route_table.private_app_rt.id
  vpc_endpoint_id = aws_vpc_endpoint.logs.id
}