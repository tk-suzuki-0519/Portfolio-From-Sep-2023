# -----------------------------------
# Security groups and Security group rules
# Terraform official no longer recommends using "aws_security_group_rule" and insted suggests "aws_vpc_security_group_ingress_rule" and "aws_vpc_security_group_egress_rule".
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
# -----------------------------------
# web sg
resource "aws_security_group" "web_sg" {
  name        = format("%s_sg_web", var.env_name)
  vpc_id      = aws_vpc.vpc.id
  description = "sg"
  tags = {
    Name = format("%s_web_sg", var.env_name)
  }
}
# web sgr
# TODO CloudFrontを実装した際に、ALBは"0.0.0.0/0"からではなく、CloudFrontからのみアクセスを許可できるかを検討する。
resource "aws_vpc_security_group_ingress_rule" "web_sg_in_http" { # 80版ポートはALBでのリダイレクト用に空けておく。
  security_group_id = aws_security_group.web_sg.id
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}
resource "aws_vpc_security_group_ingress_rule" "web_sg_in_https" {
  security_group_id = aws_security_group.web_sg.id
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}
resource "aws_vpc_security_group_egress_rule" "web_sg_out_all" { # 今後の拡張性を考え明示的に設定。
  security_group_id = aws_security_group.web_sg.id
  from_port         = 0
  to_port           = 0
  ip_protocol       = "tcp" # 仕様上、ここを"-1"にするとエラーになる。(ポートとプロトコルを同時に全て開放できない模様。)
  cidr_ipv4         = "0.0.0.0/0"
}
# fargate sg
resource "aws_security_group" "fargate_sg" {
  name        = format("%s_sg_fargate", var.env_name)
  vpc_id      = aws_vpc.vpc.id
  description = "sg"
  tags = {
    Name = format("%s_fargate_sg", var.env_name)
  }
}
# fargate sgr
resource "aws_vpc_security_group_ingress_rule" "fargate_sg_in_http" {
  security_group_id            = aws_security_group.fargate_sg.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.web_sg.id
}
# TODO Systems Managerからのingressを後々必要になった時に追記する。
# TODO ECS on Fargateの実装時の原因切り分けを容易にするため、下記で一旦Fargateのプライベートサブネットのegress通信を全て許可する。実装完了後、想定されている通信のみegress許可する。現在想定：DBとS3への通信。
resource "aws_vpc_security_group_egress_rule" "fargate_sg_out_all" {
  security_group_id = aws_security_group.fargate_sg.id
  from_port         = 0
  to_port           = 0
  ip_protocol       = "tcp" # 仕様上、ここを"-1"にするとエラーになる。(ポートとプロトコルを同時に全て開放できない模様。)
  cidr_ipv4         = "0.0.0.0/0"
}
# db sg
resource "aws_security_group" "db_sg" {
  name        = format("%s_sg_db", var.env_name)
  vpc_id      = aws_vpc.vpc.id
  description = "sg"
  tags = {
    Name = format("%s_db_sg", var.env_name)
  }
}
# db sgr
resource "aws_vpc_security_group_ingress_rule" "db_sg_in_tcp3306" {
  security_group_id            = aws_security_group.db_sg.id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.fargate_sg.id
}
# db sgrでは、fargateへの通信を許可するegressルールは追加しない。
# 理由 デフォルトでegreeルールは全て許可だが、何かしらのセキュリティグループを作成した段階でegressルールは仕様で全て拒否になる。この拒否ルールはDBサブネットで想定された設定。また、ingressでfargateからの通信は許可しているため、ステートフルの観点からfargateへの応答通信は成立し、問題がないため。
# vpc endpoint sg
resource "aws_security_group" "vpc_endpoint_sg" {
  name        = format("%s_vpc_endpoint_sg", var.env_name)
  description = "vpc endpoint security group"
  vpc_id      = aws_vpc.vpc.id
  ingress {
    description = "from public subnet app"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    /*
    cidr_blocks = [for subnet_id, subnet in aws_subnet.public_subnet_app : subnet.cidr_block]
    */
  }
  egress {
    description = "to public subnet app"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = format("%s_vpc_endpoint_sg", var.env_name)
  }
}