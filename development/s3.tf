resource "aws_s3_bucket" "lb_logs" {
  bucket = "${var.project}.${var.env}.lb-logs"

  policy = <<EOL
{
  "Id": "",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "${data.aws_elb_service_account.main.id}"
        ]
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${var.project}.${var.env}.lb-logs/*"
    }
  ]
}
EOL

  lifecycle {
    ignore_changes = [policy]
  }
}

resource "aws_s3_bucket" "cloudfront_logs" {
  bucket = "${var.project}.cloudfront-${var.env}-log"
  acl    = "private"

  policy = <<EOL
{
  "Id": "",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {"CanonicalUser": "${aws_cloudfront_origin_access_identity.assets_origin_access_identity.s3_canonical_user_id}"},
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${var.project}.cloudfront-${var.env}-log/*"
    }
  ]
}
EOL
  lifecycle {
    ignore_changes = [policy]
  }
}

resource "aws_s3_bucket" "assets" {
  bucket = "${var.project}.${var.env}.assets"
  acl    = "private"
}

data "aws_iam_policy_document" "asset_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.assets.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.assets_origin_access_identity.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "web_assets_policy" {
  bucket = aws_s3_bucket.assets.id
  policy = data.aws_iam_policy_document.asset_policy.json
}

# 添付ファイル用バケット
resource "aws_s3_bucket" "uploads" {
  bucket = "${var.project}.${var.env}.uploads"
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

data "aws_iam_policy_document" "uploads_policy" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:DeleteObject"
    ]
    resources = ["${aws_s3_bucket.uploads.arn}/*"]

    principals {
      type = "AWS"
      identifiers = [
        data.terraform_remote_state.common.outputs.iam_user_s3_arn
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "uploads_policy" {
  bucket = aws_s3_bucket.uploads.id
  policy = data.aws_iam_policy_document.uploads_policy.json
}
