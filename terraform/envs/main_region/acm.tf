# -----------------------------------
# acm
# -----------------------------------
resource "aws_acm_certificate" "main_region_cert" {
  domain_name               = var.main_domain
  subject_alternative_names = [format("www.%s", var.main_domain)]
  validation_method         = "DNS"
  tags = {
    Name = format("%s_cert", var.main_domain)
  }
  # デフォルトではリソースが削除されてから作成されるが、証明書に関してはロードバランサーで使用中なので、作成してから削除させる
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_acm_certificate_validation" "cert_valid" {
  certificate_arn = aws_acm_certificate.main_region_cert.arn
  #  validation_record_fqdns = [for record in aws_route53_record.cert_valid : record.fqdn]
}
resource "aws_route53_record" "cert_valid" {
  for_each = {
    for dvo in aws_acm_certificate.main_region_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.main_domain.id
}