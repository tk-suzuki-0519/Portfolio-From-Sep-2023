# -----------------------------------
# RDS
# -----------------------------------
resource "aws_db_parameter_group" "rds_pg" {
  name   = format("%s-rds-pg", var.env_name)
  family = "mysql8.0"

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }
  parameter {
    name  = "character_set_database"
    value = "utf8mb4"
  }
  parameter {
    name  = "character_set_client"
    value = "utf8mb4"
  }
  parameter {
    name  = "general_log"
    value = "1"
  }
  parameter {
    name  = "slow_query_log"
    value = "1"
  }
  parameter {
    name  = "long_query_time"
    value = "10"
  }
  parameter {
    name  = "log_output"
    value = "TABLE"
  }
  lifecycle { # 公式情報によると、バージョンアップ時等の使用中のパラメータグループを強制的に再作成する際に必要。
    create_before_destroy = true
  }
  tags = {
    Name = format("%s-rds-pg", var.env_name)
  }
}
resource "aws_db_option_group" "rds_og" {
  name                     = format("%s-rds-og", var.env_name)
  option_group_description = "Option Group"
  engine_name              = "mysql"
  major_engine_version     = "8.0"
}
resource "aws_db_subnet_group" "rds_sg" {
  name       = format("%s-rds-sg", var.env_name)
  subnet_ids = [for subnet in aws_subnet.private_subnet_db : subnet.id]
  tags = {
    Name = format("%s-rds-sg", var.env_name)
  }
}
resource "aws_db_instance" "rds" {
  # basic settings
  db_name                      = "rds_mysql"
  engine                       = "mysql"
  engine_version               = "8.0.34"
  identifier                   = format("%s-rds-standalone", var.env_name)
  username                     = "admin"
  password                     = "Dev!1234"
  instance_class               = "db.t4g.micro"
  apply_immediately            = true
  performance_insights_enabled = false
  /* TODO SSM parameter store設定後、もしくは構築完了後、このコメントアウトを外す。
  lifecycle {
    ignore_changes = [
      password
    ]
  }
  */
  tags = {
    Name = format("%s-rds", var.env_name)
  }

  # storage settings
  storage_type          = "gp2"
  allocated_storage     = 20
  max_allocated_storage = 0 # "0"でストレージオートスケーリングを無効化。

  # network settings
  multi_az             = false
  db_subnet_group_name = aws_db_subnet_group.rds_sg.name
  publicly_accessible  = false
  vpc_security_group_ids = [
    aws_security_group.db_sg.id
  ]
  port = 3306

  # DB settings
  parameter_group_name = aws_db_parameter_group.rds_pg.name
  option_group_name    = aws_db_option_group.rds_og.name
  enabled_cloudwatch_logs_exports = [
    "error",
    "general",
    "slowquery"
  ]
  timeouts {
    create = "20m"
    update = "60m"
    delete = "30m"
  }

  # backup settings
  auto_minor_version_upgrade = false
  maintenance_window         = "Mon:05:00-Mon:07:00"
  backup_retention_period    = 1
  backup_window              = "04:00-05:00"
  copy_tags_to_snapshot      = true
  delete_automated_backups   = true
  skip_final_snapshot        = true

  # delete settings
  deletion_protection = false # ポートフォリオなので、削除保護はしない。
}