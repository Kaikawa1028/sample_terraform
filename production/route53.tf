resource "aws_route53_record" "web" {
  zone_id = data.terraform_remote_state.common.outputs.zone_id
  name    = "event-organizer.jp"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.assets.domain_name
    zone_id                = aws_cloudfront_distribution.assets.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "cert_validation" {
  name    = aws_acm_certificate.web.domain_validation_options.0.resource_record_name
  type    = aws_acm_certificate.web.domain_validation_options.0.resource_record_type
  zone_id = data.terraform_remote_state.common.outputs.zone_id
  records = [
    aws_acm_certificate.web.domain_validation_options.0.resource_record_value
  ]
  ttl = 300
}
