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