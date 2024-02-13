# -----------------------------------
# route 53
# -----------------------------------
data "aws_route53_zone" "main_domain" {
  name = var.main_domain
}
resource "aws_route53_zone" "sub_domain" {
  name = format("www.%s", var.main_domain)
}
resource "aws_route53_record" "sub-ns" {
  zone_id = aws_route53_zone.main_domain.zone_id
  name    = format("www.%s", var.main_domain)
  type    = "NS"
  ttl     = "300"
  records = aws_route53_zone.sub-ns.name_servers
}
resource "aws_route53_record" "sub-a" {
  zone_id = aws_route53_zone.sub-ns.zone_id
  name    = aws_route53_zone.sub-ns.name
  type    = "A"
  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}