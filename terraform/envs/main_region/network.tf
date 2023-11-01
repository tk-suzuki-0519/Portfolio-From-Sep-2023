# This tf file consists of VPC, Subnets, Route tables and Internet gateway.
# -----------------------------------
# VPC
# -----------------------------------
resource "aws_vpc" "vpc" {
  cidr_block = "172.30.0.0/16"
  tags = {
    Name = format("%s_vpc", var.env_name)
  }
}
# -----------------------------------
# subnets
# -----------------------------------
# public subnets
resource "aws_subnet" "public_subnet" {
  for_each = {
    "172.30.1.0/24"  = "ap-northeast-1a"
    "172.30.17.0/24" = "ap-northeast-1c"
    "172.30.33.0/24" = "ap-northeast-1d"
  }
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.key
  availability_zone = each.value
  tags = {
    Name = format("%s_public_subnet_%s", var.env_name, each.value)
  }
}
# private subnets
resource "aws_subnet" "private_subnet" {
  for_each = {
    "172.30.2.0/24"  = "ap-northeast-1a"
    "172.30.3.0/24"  = "ap-northeast-1a"
    "172.30.18.0/24" = "ap-northeast-1c"
    "172.30.19.0/24" = "ap-northeast-1c"
    "172.30.34.0/24" = "ap-northeast-1d"
    "172.30.35.0/24" = "ap-northeast-1d"
  }
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.key
  availability_zone = each.value
  tags = {
    Name = format("%s_private_subnet_%s", var.env_name, each.value)
  }
}
# -----------------------------------
# Route tables
# -----------------------------------
# a route 



# -----------------------------------
# Internet gateway
# -----------------------------------