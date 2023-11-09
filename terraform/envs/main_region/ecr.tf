# -----------------------------------
# ECR
# -----------------------------------
resource "aws_ecr_repository" "ecr_repo" {
  name                 = format("%s_ecr_repo", var.env_name)
  image_tag_mutability = "MUTABLE"
  force_delete         = true # ポートフォリオのため、強制削除を許可する。
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
    Name = format("%s_ecr_repo", var.env_name)
  }
}