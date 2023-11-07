# -----------------------------------
# CloudWatch Logs
# -----------------------------------
resource "aws_cloudwatch_log_group" "error" {
  name              = format("/%s/rds/error", var.env_name)
  retention_in_days = 90
}
resource "aws_cloudwatch_log_group" "general" {
  name              = format("/%s/rds/general", var.env_name)
  retention_in_days = 90
}
resource "aws_cloudwatch_log_group" "slowquery" {
  name              = format("/%s/rds/slowquery", var.env_name)
  retention_in_days = 90
}