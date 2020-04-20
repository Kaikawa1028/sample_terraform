resource "aws_cloudfront_origin_access_identity" "assets_origin_access_identity" {
  comment = "origin access identity for asset files (${var.env})"
}

resource "aws_cloudfront_distribution" "assets" {
  origin {
    domain_name = aws_lb.web.dns_name
    origin_id   = "${var.project}_${var.env}_alb"

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_protocol_policy   = "https-only"
      origin_read_timeout      = 30
      origin_ssl_protocols     = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  origin {
    domain_name = aws_s3_bucket.assets.bucket_domain_name
    origin_id   = "${var.project}_${var.env}_assets"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.assets_origin_access_identity.cloudfront_access_identity_path
    }
  }

  enabled         = true
  is_ipv6_enabled = true
  comment         = "For ${var.project} Assets (${var.env})"

  aliases = ["${var.env}.event-organizer.jp"]

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.cdn.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  default_cache_behavior {
    viewer_protocol_policy = "redirect-to-https"
    compress               = false
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "${var.project}_${var.env}_alb"

    forwarded_values {
      query_string = true
      headers      = ["*"]

      cookies {
        forward = "all"
      }
    }
  }

  ordered_cache_behavior {
    viewer_protocol_policy = "redirect-to-https"
    path_pattern           = "/css/*"
    compress               = false
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "${var.project}_${var.env}_assets"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  ordered_cache_behavior {
    viewer_protocol_policy = "redirect-to-https"
    path_pattern           = "/images/*"
    compress               = false
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "${var.project}_${var.env}_assets"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  ordered_cache_behavior {
    viewer_protocol_policy = "redirect-to-https"
    path_pattern           = "/img/*"
    compress               = false
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "${var.project}_${var.env}_assets"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  ordered_cache_behavior {
    viewer_protocol_policy = "redirect-to-https"
    path_pattern           = "/js/*"
    compress               = false
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "${var.project}_${var.env}_assets"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  ordered_cache_behavior {
    viewer_protocol_policy = "redirect-to-https"
    path_pattern           = "/vendor/*"
    compress               = false
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "${var.project}_${var.env}_assets"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  ordered_cache_behavior {
    viewer_protocol_policy = "redirect-to-https"
    path_pattern           = "/mix-manifest.json"
    compress               = false
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "${var.project}_${var.env}_assets"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  ordered_cache_behavior {
    viewer_protocol_policy = "redirect-to-https"
    path_pattern           = "/robots.txt"
    compress               = false
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "${var.project}_${var.env}_assets"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.cloudfront_logs.bucket_domain_name
    prefix          = "assets"
  }

  tags = {
    Environment = var.env
  }
}
