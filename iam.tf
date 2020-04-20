resource "aws_iam_user" "circleci" {
  name = "circleci"
}

resource "aws_iam_policy" "circleci_policy" {
  name   = "${var.project}-circleci-policy"
  policy = data.aws_iam_policy_document.circleci_policy.json
}

resource "aws_iam_user_policy_attachment" "circleci_policy_attach" {
  user       = aws_iam_user.circleci.name
  policy_arn = aws_iam_policy.circleci_policy.arn
}

data "aws_iam_policy_document" "circleci_policy" {
  statement {
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:ListBucket",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:BatchGetImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage",
      "ecs:DescribeServices",
      "ecs:DescribeTaskDefinition",
      "ecs:DescribeTasks",
      "ecs:ListTasks",
      "ecs:RegisterTaskDefinition",
      "ecs:UpdateService",
      "ecs:RunTask",
      "iam:PassRole",
    ]
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs_task_execution_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

resource "aws_iam_role_policy" "ecs_task_execution_role_policy" {
  name = "ecs_task_execution_policy"
  role = aws_iam_role.ecs_task_execution_role.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:*",
                "cloudtrail:LookupEvents",
                "logs:*"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ssm:GetParameters",
                "secretsmanager:GetSecretValue",
                "kms:Decrypt"
            ],
            "Resource": "*"
        }
    ]
}
EOF

}

resource "aws_iam_user" "s3" {
  name = "s3-user"
}

resource "aws_iam_policy" "s3_policy" {
  name   = "${var.project}-s3-policy"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
              "s3:GetObject",
              "s3:GetObjectAcl",
              "s3:PutObject",
              "s3:PutObjectAcl",
              "s3:DeleteObject"
            ],
            "Resource": "*"
        }
    ]
}
EOF

}

resource "aws_iam_user_policy_attachment" "s3_policy_attach" {
  user       = aws_iam_user.s3.name
  policy_arn = aws_iam_policy.s3_policy.arn
}

resource "aws_iam_role" "ecs_autoscale_role" {
  name = "ecs_autoscale_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "application-autoscaling.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

resource "aws_iam_user" "ses" {
  name = "ses-user"
}

resource "aws_iam_policy" "ses_policy" {
  name   = "${var.project}-ses-policy"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
              "ses:SendRawEmail"
            ],
            "Resource": "*"
        }
    ]
}
EOF

}

resource "aws_iam_user_policy_attachment" "ses_policy_attach" {
  user       = aws_iam_user.ses.name
  policy_arn = aws_iam_policy.ses_policy.arn
}

resource "aws_iam_user" "logger" {
  name = "logger"
}

resource "aws_iam_policy" "logger_policy" {
  name   = "${var.project}-logger-policy"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
              "cloudwatch:*",
              "logs:*"
            ],
            "Resource": "*"
        }
    ]
}
EOF

}

resource "aws_iam_user_policy_attachment" "logger_policy_attach" {
  user       = aws_iam_user.logger.name
  policy_arn = aws_iam_policy.logger_policy.arn
}

resource "aws_iam_role" "lambda" {
  name = "lambda_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "lamda"
  role = aws_iam_role.lambda.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "1",
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "*"
        },
        {
            "Sid": "2",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:*:log-group:/aws/lambda/*"
            ]
        },
        {
            "Sid": "3",
            "Effect": "Allow",
            "Action": "kms:Decrypt",
            "Resource": "*"
        },
        {
            "Sid": "4",
            "Effect": "Allow",
            "Action": [
                "autoscaling:Describe*",
                "cloudwatch:Describe*",
                "cloudwatch:Get*",
                "cloudwatch:List*",
                "logs:Get*",
                "logs:List*",
                "logs:Describe*",
                "logs:TestMetricFilter",
                "logs:FilterLogEvents",
                "sns:Get*",
                "sns:List*"
            ],
            "Resource": "*"
        }
    ]
}
EOF

}
