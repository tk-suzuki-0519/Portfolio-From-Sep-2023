# -----------------------------------
# S3
# -----------------------------------
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
resource "aws_s3_bucket_lifecycle_configuration" "public_assets" {
  bucket = aws_s3_bucket.public_assets.id
  rule {
    id     = "public_assets"
    status = "Enabled"
    filter { # prefixを指定しない場合必須。(ここでいうprefixとは、filter内prefixではなく、filterと同列に配置できるprefix。)lifecycle ruleを適応する適用する範囲を指定。
      prefix = ""
    }
  }
}
resource "aws_s3_bucket_policy" "public_assets_policy" {
  bucket = aws_s3_bucket.public_assets.id
  policy = data.aws_iam_policy_document.allow_access_from_public.json
}
data "aws_iam_policy_document" "allow_access_from_public" {
  statement {
    principals { # 公式より右記を抜粋。"To have Terraform render JSON containing "Principal": {"AWS": "*"}, use type = "AWS" and identifiers = ["*"]."
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "S3:GetObject",
    ]
    resources = [
      aws_s3_bucket.public_assets.arn
    ]
  }
}







# private bucket
# loopを防ぐ実装を行う
/*
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object
上記方法でも暗号化ができる。どちらにするか検討する。上の方法だとserver_side_encryption 属性を付与している。
resource "aws_s3_bucket_server_side_encryption_configuration" "private_admin" {
  bucket = aws_s3_bucket.private_admin.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
resource "aws_s3_bucket_public_access_block" "private_ab" {
  bucket                  = aws_s3_bucket.private_ab.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  depends_on = [
    aws_s3_bucket_policy.public_assets_policy
  ]
}
resource "aws_s3_object" "object" {
  bucket = aws_s3_bucket.public_assets.id
  key    = "new_object_key"
  source = "path/to/file"
  etag = filemd5("path/to/file") # privateの場合、etagの使用を検討する
}
*/