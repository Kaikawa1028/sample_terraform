# CloudFront用にバージニア北部に証明書をリクエスト
resource "aws_acm_certificate" "cdn" {
  domain_name       = "${var.env}.event-organizer.jp"
  validation_method = "DNS"
  provider          = aws.virginia

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate" "web" {
  domain_name       = "${var.env}.event-organizer.jp"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "cdn" {
  certificate_arn = aws_acm_certificate.cdn.arn
  validation_record_fqdns = [
    aws_route53_record.cert_validation.fqdn
  ]

  provider = aws.virginia
}

resource "aws_acm_certificate_validation" "web" {
  certificate_arn = aws_acm_certificate.web.arn
  validation_record_fqdns = [
    aws_route53_record.cert_validation.fqdn
  ]
}
