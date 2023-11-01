# This tf file consists of VPC, Subnets, Route tables and Internet gateway.
# -----------------------------------
# VPC
# -----------------------------------
resource "aws_vpc" "vpc" {
  cidr_block                       = "172.30.0.0/16"
  enable_dns_hostnames             = true # VPC内のインスタンスがDNSホスト名を取得する。またAWSサービス間での通信を可能にする場合がある。
  enable_dns_support               = true # デフォルトでtrueだが指定。VPC内でのサービス間の通信に必須。
  assign_generated_ipv6_cidr_block = false
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
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = each.key
  availability_zone       = each.value
  map_public_ip_on_launch = true
  tags = {
    Name = format("%s_public_%s", var.env_name, each.value)
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
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = each.key
  availability_zone       = each.value
  map_public_ip_on_launch = false
  tags = {
    Name = format("%s_private_%s", var.env_name, each.value)
  }
}
# -----------------------------------
# Route tables
# -----------------------------------
# a route table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = format("%s_public_rt", var.env_name)
  }
}
resource "aws_route_table_association" "public_rta" {
  route_table_id = aws_route_table.public_rt.id
  subnet_id      = aws_subnet.public_subnet[each.value].id
}
# -----------------------------------
# Internet gateway
# -----------------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = format("%s_igw", var.env_name)
  }
}
resource "aws_route" "public_rt_igw_r" {
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
  route_table_id         = aws_route_table.public_rt.id
}