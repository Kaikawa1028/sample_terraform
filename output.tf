output "nginx_repository_url" {
  value = aws_ecr_repository.nginx.repository_url
}

output "development_app_repository_url" {
  value = aws_ecr_repository.app-development.repository_url
}

output "staging_app_repository_url" {
  value = aws_ecr_repository.app-staging.repository_url
}

output "production_app_repository_url" {
  value = aws_ecr_repository.app-production.repository_url
}

output "ecs_task_execution_role_arn" {
  value = aws_iam_role.ecs_task_execution_role.arn
}

output "aws_vpc_peering_connection_id_dev" {
  value = aws_vpc_peering_connection.bastion_dev.id
}

output "iam_user_s3_arn" {
  value = aws_iam_user.s3.arn
}

output "ecs_autoscale_role_arn" {
  value = aws_iam_role.ecs_autoscale_role.arn
}

output "zone_id" {
  value = "Z13C1I2S6LQ9QU"
}


