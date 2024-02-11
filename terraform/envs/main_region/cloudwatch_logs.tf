# -----------------------------------
# CloudWatch Logs
# -----------------------------------
resource "aws_cloudwatch_log_group" "error" {
  name              = format("/aws/rds/instance/%s-rds-standalone/error", var.env_name)
  retention_in_days = 90
}
resource "aws_cloudwatch_log_group" "general" {
  name              = format("/aws/rds/instance/%s-rds-standalone/general", var.env_name)
  retention_in_days = 90
}
resource "aws_cloudwatch_log_group" "slowquery" {
  name              = format("/aws/rds/instance/%s-rds-standalone/slowquery", var.env_name)
  retention_in_days = 90
}
resource "aws_cloudwatch_log_group" "ecs" {
  name              = format("/aws/ecs/%s", var.env_name)
  retention_in_days = 90
}
resource "aws_cloudwatch_log_group" "ecs_exec" {
  name              = format("/aws/ecs_exec/%s", var.env_name)
  retention_in_days = 90
}