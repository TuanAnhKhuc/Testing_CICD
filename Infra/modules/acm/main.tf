resource "aws_acm_certificate" "this" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  tags = var.tags
}

locals {
  dvo_map = { for dvo in aws_acm_certificate.this.domain_validation_options : dvo.domain_name => {
    name  = dvo.resource_record_name
    type  = dvo.resource_record_type
    value = dvo.resource_record_value
  } }
}

resource "aws_route53_record" "validation" {
  for_each = local.dvo_map
  zone_id  = var.hosted_zone_id
  name     = each.value.name
  type     = each.value.type
  records  = [each.value.value]
  ttl      = 60
}

resource "aws_acm_certificate_validation" "this" {
  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn]
}
