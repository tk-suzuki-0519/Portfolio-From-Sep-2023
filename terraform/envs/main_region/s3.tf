# -----------------------------------
# S3
# -----------------------------------
# TODO s3 cross region replicationの実装。
# S3 Storage Lens
resource "aws_s3control_storage_lens_configuration" "s3_storage_lens" {
  config_id = format("%s_S3_Storage_Lens", var.env_name)
  storage_lens_configuration {
    enabled = true
    account_level {
      activity_metrics {
        enabled = true
      }
      bucket_level {
        activity_metrics {
          enabled = true
        }
      }
    }
    data_export {
      cloud_watch_metrics {
        enabled = true
      }
      # TODO 後々、S3バケットに出力する必要性があるようであれば、ここで出力する。ループに注意。
    }
  }
}
# ランダムID生成
# "random_string"の使用は公式非推奨
# https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string
resource "random_id" "s3" {
  byte_length = 8
  keepers = { # Generate a new bucket with a random numbers name each time when the following setting below changes.
    region = var.main_region
  }
}
# public bucket
# TODO 静的ウェブサイトのホスティングをALBを実装するタイミングで実装する。
resource "aws_s3_bucket" "public_assets" { # versioningをこの中で使用する事は公式非推奨。そのため、"aws_s3_bucket_versioning"内で実装。
  bucket = format("%s-public-assets-%s", var.env_name, random_id.s3.hex)
  tags = {
    Name = format("%s-public-assets-%s", var.env_name, random_id.s3.hex)
  }
}
resource "aws_s3_bucket_versioning" "public_assets_versioning" {
  bucket = aws_s3_bucket.public_assets.id
  versioning_configuration {
    status = "Disabled"
  }
}
resource "aws_s3_bucket_public_access_block" "public_ab" {
  bucket                  = aws_s3_bucket.public_assets.id
  block_public_acls       = true
  block_public_policy     = false # S3バケットを自動作成する処理の中で、block_public_policyはデフォルトtrueなのでfalseにしないと新規作成時でも設定したポリシーの適応が失敗し構築が失敗する。
  ignore_public_acls      = true
  restrict_public_buckets = false
  depends_on = [
    aws_s3_bucket.public_assets
  ]
}
resource "aws_s3_bucket_policy" "public_assets_policy" {
  bucket = aws_s3_bucket.public_assets.id
  policy = data.aws_iam_policy_document.allow_access_from_public.json
  depends_on = [
    aws_s3_bucket_public_access_block.public_ab
  ]
}
data "aws_iam_policy_document" "allow_access_from_public" {
  statement {
    effect = "Allow" # デフォルトは"Allow"
    principals {     # 公式より右記を抜粋。"To have Terraform render JSON containing "Principal": {"AWS": "*"}, use type = "AWS" and identifiers = ["*"]."
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "S3:GetObject",
    ]
    resources = [
      aws_s3_bucket.public_assets.arn,       # buckerそのものへのアクセス
      "${aws_s3_bucket.public_assets.arn}/*" # bucket内のオブジェクトへのアクセス
    ]
  }
}
resource "aws_s3_bucket_lifecycle_configuration" "public_assets_lifecycle" {
  bucket = aws_s3_bucket.public_assets.id
  rule {
    id     = "public_assets_cleanup_abort_multipart"
    status = "Enabled"
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
    filter { # prefixを指定しない場合必須。(ここでいうprefixとは、filter内prefixではなく、filterと同列に配置できるprefix。)lifecycle ruleを適応する適用する範囲を指定。ここでは全てを指定。
      prefix = ""
    }
  }
}
# TODO ドメインが確定したらCORSの設定を行う
/*
resource "aws_s3_bucket_cors_configuration" "public_assets_cors" {
  bucket = aws_s3_bucket.public_assets_cors.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST"]
    allowed_origins = ["https://domainname.com", "http://localhost:port"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }

  cors_rule {
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
  }
}
*/

# private bucket for admin use
resource "aws_s3_bucket" "private_admin" {
  bucket = format("%s-private-admin-%s", var.env_name, random_id.s3.hex)
  tags = {
    Name = format("%s-private-admin-%s", var.env_name, random_id.s3.hex)
  }
}
resource "aws_s3_bucket_versioning" "private_admin_versioning" {
  bucket = aws_s3_bucket.private_admin.id
  versioning_configuration {
    status = "Enabled"
  }
}
resource "aws_s3_bucket_public_access_block" "private_admin_ab" {
  bucket                  = aws_s3_bucket.private_admin.id
  block_public_acls       = true
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = true
  depends_on = [
    aws_s3_bucket.private_admin
  ]
}
resource "aws_s3_bucket_policy" "private_admin_policy" {
  bucket = aws_s3_bucket.private_admin.id
  policy = data.aws_iam_policy_document.limited_access_only_private_admin.json
  depends_on = [
    aws_s3_bucket_public_access_block.private_admin_ab
  ]
}
data "aws_iam_policy_document" "limited_access_only_private_admin" {
  statement {
    effect = "Allow"
    principals { # 特定のadminユーザを許可。
      type        = "AWS"
      identifiers = [var.admin_iam_arn]
    }
    actions = [
      "S3:*",
    ]
    resources = [
      aws_s3_bucket.private_admin.arn,
      "${aws_s3_bucket.private_admin.arn}/*"
    ]
  }
}
resource "aws_s3_bucket_lifecycle_configuration" "private_admin_lifecycle" {
  bucket = aws_s3_bucket.private_admin.id
  rule {
    id     = "private_admin_cleanup_abort_multipart"
    status = "Enabled"
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
    filter {
      prefix = ""
    }
  }
  rule {
    id     = "private_admin_noncurrent_version_expiration"
    status = "Enabled"
    noncurrent_version_expiration { # 非現行バージョンをどれだけの数残すかを設定。
      newer_noncurrent_versions = 3
      noncurrent_days           = 90 # 公式ではオプションだが、右記のterraform cloudのapplyエラーを回避するために設定。"'NoncurrentDays' for NoncurrentVersionExpiration action must be a positive integer"
    }

    filter {
    }
  }
}
# private bucket for main system logs use with object lock
resource "aws_s3_bucket" "private_sys_logs_with_objectlock" {
  bucket              = format("%s-private-sys-logs-with-objectlock-%s", var.env_name, random_id.s3.hex)
  object_lock_enabled = true
  tags = {
    Name = format("%s-private-sys-logs-with-objectlock-%s", var.env_name, random_id.s3.hex)
  }
}
resource "aws_s3_bucket_public_access_block" "private_sys_logs_with_objectlock_ab" {
  bucket                  = aws_s3_bucket.private_sys_logs_with_objectlock.id
  block_public_acls       = true
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = true
  depends_on = [
    aws_s3_bucket.private_sys_logs_with_objectlock
  ]
}
resource "aws_s3_bucket_policy" "private_sys_logs__with_objectlock_policy" {
  bucket = aws_s3_bucket.private_sys_logs_with_objectlock.id
  policy = data.aws_iam_policy_document.limited_access_only_private_sys_logs_with_objectlock.json
  depends_on = [
    aws_s3_bucket_public_access_block.private_sys_logs_with_objectlock_ab
  ]
}
data "aws_iam_policy_document" "limited_access_only_private_sys_logs_with_objectlock" {
  statement {
    effect = "Allow"
    principals { # TODO 都度、logを吐き出すsystemを追加する。
      type        = "AWS"
      identifiers = [var.admin_iam_arn]
    }
    actions = [ # TODO logを吐き出すsystemを追加する際は、putのみ許可。
      "S3:*",
    ]
    resources = [
      aws_s3_bucket.private_sys_logs_with_objectlock.arn,
      "${aws_s3_bucket.private_sys_logs_with_objectlock.arn}/*"
    ]
  }
}
resource "aws_s3_bucket_object_lock_configuration" "private_sys_logs_with_objectlock" { # バージョニングと有効化は指定する必要無し。デフォルトで有効化される。
  bucket = aws_s3_bucket.private_sys_logs_with_objectlock.id
  rule {
    default_retention {
      mode = "GOVERNANCE"
      days = 90
    }
  }
}
resource "aws_s3_bucket_lifecycle_configuration" "private_sys_logs_with_objectlock_lifecycle" {
  bucket = aws_s3_bucket.private_sys_logs_with_objectlock.id
  rule {
    id     = "private_sys_logs_with_objectlock_cleanup_abort_multipart"
    status = "Enabled"
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
    filter {
      prefix = ""
    }
  }
  rule {
    id     = "private_sys_logs_with_objectlock_noncurrent_version_expiration"
    status = "Enabled"
    noncurrent_version_expiration {
      newer_noncurrent_versions = 3
      noncurrent_days           = 90
    }
    filter {
    }
  }
}
# private bucket for system logs use without object lock
resource "aws_s3_bucket" "private_sys_logs" {
  bucket = format("%s-private-sys-logs-%s", var.env_name, random_id.s3.hex)
  tags = {
    Name = format("%s-private-sys-logs-%s", var.env_name, random_id.s3.hex)
  }
}
resource "aws_s3_bucket_versioning" "private_sys_logs_versioning" {
  bucket = aws_s3_bucket.private_sys_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}
resource "aws_s3_bucket_public_access_block" "private_sys_logs_ab" {
  bucket                  = aws_s3_bucket.private_sys_logs.id
  block_public_acls       = true
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = true
  depends_on = [
    aws_s3_bucket.private_sys_logs
  ]
}
resource "aws_s3_bucket_policy" "private_sys_logs_policy" {
  bucket = aws_s3_bucket.private_sys_logs.id
  policy = data.aws_iam_policy_document.limited_access_only_private_sys_logs.json
  depends_on = [
    aws_s3_bucket_public_access_block.private_sys_logs_ab
  ]
}
data "aws_iam_policy_document" "limited_access_only_private_sys_logs" {
  statement {
    effect = "Allow"
    principals { # TODO 都度、logを吐き出すsystemを追加する。
      type        = "AWS"
      identifiers = [var.admin_iam_arn]
    }
    actions = [ # TODO logを吐き出すsystemを追加する際は、putのみ許可。
      "S3:*",
    ]
    resources = [
      aws_s3_bucket.private_sys_logs.arn,
      "${aws_s3_bucket.private_sys_logs.arn}/*"
    ]
  }
}
resource "aws_s3_bucket_lifecycle_configuration" "private_sys_logs_lifecycle" {
  bucket = aws_s3_bucket.private_sys_logs.id
  rule {
    id     = "private_sys_logs"
    status = "Enabled"
    expiration {
      days = 90
    }
    filter {
      prefix = ""
    }
  }
  rule {
    id     = "private_sys_logs_cleanup_abort_multipart"
    status = "Enabled"
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
    filter {
      prefix = ""
    }
  }
  rule {
    id     = "private_sys_logs_noncurrent_version_expiration"
    status = "Enabled"
    noncurrent_version_expiration {
      newer_noncurrent_versions = 3
      noncurrent_days           = 90
    }

    filter {
    }
  }
}
# private bucket for system logs loop avoidance use
# TODO loopを防ぐ実装を必要になったタイミングで行う