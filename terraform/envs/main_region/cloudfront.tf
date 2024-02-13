# -----------------------------------
# CloudFront
# -----------------------------------
resource "aws_cloudfront_distribution" "asset" {
  # basic settings
  enabled             = true
  is_ipv6_enabled     = false
  price_class         = "PriceClass_All"
  aliases             = [var.main_domain]
  retain_on_delete    = false
  wait_for_deployment = false
  comment             = "cache distribution"
  tags = {
    Name = format("%s_cloudfront", var.env_name)
  }
  # オリジン設定/ALB
  origin {
    domain_name = var.main_domain
    origin_id   = aws_lb.alb.id
    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_protocol_policy   = "match-viewer" # "https-only"はhttp禁止後に設定。
      origin_read_timeout      = 20
      origin_ssl_protocols     = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }
  # オリジン設定/S3
  origin {
    domain_name              = aws_s3_bucket.public_assets.bucket_regional_domain_name
    origin_id                = aws_s3_bucket.public_assets.id
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }
  # ビヘイビア設定/ALBキャッシュ
  default_cache_behavior {
    allowed_methods  = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    cached_methods   = ["HEAD", "GET", "OPTIONS"]
    target_origin_id = aws_lb.alb.id
    forwarded_values {
      query_string = true
      cookies {
        forward = "all"
      }
      headers = ["*"]
    }
    viewer_protocol_policy = "allow-all" # "redirect-to-https"はACM実装後に有効化する。
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
  }
  # ビヘイビア設定/S3キャッシュ
  ordered_cache_behavior {
    path_pattern     = "/public/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = aws_s3_bucket.public_assets.id
    forwarded_values {
      query_string = false
      headers      = []
      cookies {
        forward = "none"
      }
    }
    min_ttl                = 0
    default_ttl            = 86400    # 24h
    max_ttl                = 31536000 # 1 year
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }
  # アクセス制限
  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["JP"]
    }
  }
  # 証明書
/*
  viewer_certificate {
    cloudfront_default_certificate = false
    # acm_certificate_arn            = var.
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }
*/
}

# OAC
resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = format("%s_oac", var.env_name)
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}