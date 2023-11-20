# -----------------------------------
# SSM(AWS Systems Manager)
# -----------------------------------
# SSM Parameter Store
resource "aws_ssm_parameter" "db_pw" {
  name  = format("/%s/db/pw", var.env_name)
  type  = "SecureString"
  value = var.main_db_pw
  tags = {
    Name = format("%s_main_db_pw", var.env_name)
  }
}