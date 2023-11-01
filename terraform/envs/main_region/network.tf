# This tf file consists of VPC, Subnets, Route tables and Internet gateway.
# -----------------------------------
# VPC
# -----------------------------------
resource "aws_vpc" "vpc" {
  cidr_block = "172.16.0.0/12"
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
    "172.16.1.0/24"  = "ap-northeast-1a"
    "172.16.17.0/24" = "ap-northeast-1c"
    "172.16.33.0/24" = "ap-northeast-1d"
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
    "172.17.1.0/24"  = "ap-northeast-1a"
    "172.17.2.0/24"  = "ap-northeast-1a"
    "172.17.17.0/24" = "ap-northeast-1c"
    "172.17.18.0/24" = "ap-northeast-1c"
    "172.17.33.0/24" = "ap-northeast-1d"
    "172.17.34.0/24" = "ap-northeast-1d"
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