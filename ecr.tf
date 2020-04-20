resource "aws_ecr_repository" "nginx" {
  name = "${var.project}-nginx"
}

resource "aws_ecr_repository" "app-development" {
  name = "${var.project}-app-development"
}

resource "aws_ecr_repository" "app-staging" {
  name = "${var.project}-app-staging"
}

resource "aws_ecr_repository" "app-production" {
  name = "${var.project}-app-production"
}

resource "aws_ecr_lifecycle_policy" "app-development" {
  repository = aws_ecr_repository.app-development.name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep last 50 images",
            "selection": {
                "tagStatus": "tagged",
                "tagPrefixList": ["app"],
                "countType": "imageCountMoreThan",
                "countNumber": 50
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF

}

resource "aws_ecr_lifecycle_policy" "app-staging" {
  repository = aws_ecr_repository.app-staging.name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep last 50 images",
            "selection": {
                "tagStatus": "tagged",
                "tagPrefixList": ["app"],
                "countType": "imageCountMoreThan",
                "countNumber": 50
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF

}

resource "aws_ecr_lifecycle_policy" "app-production" {
  repository = aws_ecr_repository.app-production.name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep last 50 images",
            "selection": {
                "tagStatus": "tagged",
                "tagPrefixList": ["app"],
                "countType": "imageCountMoreThan",
                "countNumber": 50
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF

}
