variable "main_region" {
  description = "a main AWS region"
  type        = string
}
variable "env_name" {
  description = "a environment name"
  type        = string
}
variable "admin_iam_arn" {
  description = "a admin iam arn"
  type        = string
}
variable "admin_iam_id" {
  description = "a admin iam id"
  type        = string
}
variable "main_db_pw" {
  description = "main DB access password"
  type        = string
}
variable "elb_account_id" {
  description = "elb account id"
  type        = string
}
variable "S3arn_private_sys_logs_with_objectlock" {
  description = "S3 arn of 'privatesys_logs_with_objectlock'"
  type        = string
}
variable "main_domain" {
  description = "main_domain"
  type        = string
}
