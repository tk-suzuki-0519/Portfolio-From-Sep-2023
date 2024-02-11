# -----------------------------------
# ECR
# -----------------------------------
resource "aws_ecr_repository" "ecr_nginx" {
  name                 = "ecr_nginx"
  image_tag_mutability = "MUTABLE"
  force_delete         = true # ポートフォリオのため、強制削除を許可する。
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
    Name = format("%s_ecr_nginx", var.env_name)
  }
}
resource "aws_ecr_repository" "ecr_php" {
  name                 = "ecr_php"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
    Name = format("%s_ecr_php", var.env_name)
  }
}