# -----------------------------------
# VPC endpoint
# -----------------------------------
# VPC endpoint(Gateway) for S3
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = format("com.amazonaws.%s.s3", var.main_region)
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private_app_rt.id]
  ip_address_type   = "ipv4"
  tags = {
    Name = format("%s_endpoint_s3", var.env_name)
  }
}

# AWS PrivateLink(VPC endpoint(Interface)) for the others
