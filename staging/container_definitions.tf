data "template_file" "app_task_definition" {
  template = <<DEFINITION
    [
      {
        "name": "nginx",
        "image": "${data.terraform_remote_state.common.outputs.nginx_repository_url}:staging",
        "cpu": ${var.fargate_cpu},
        "memory": ${var.fargate_memory},
        "essential": true,
        "networkMode": "awsvpc",
        "portMappings": [
          {
            "containerPort": 80,
            "hostPort": 80
          }
        ],
        "logConfiguration": {
          "logDriver": "awslogs",
          "options": {
            "awslogs-group": "/ecs/${var.project}-${var.env}-nginx",
            "awslogs-region": "ap-northeast-1",
            "awslogs-stream-prefix": "nginx"
          }
        }
      },
      {
        "name": "app",
        "image": "${data.terraform_remote_state.common.outputs.staging_app_repository_url}:latest",
        "cpu": ${var.fargate_cpu},
        "memory": ${var.fargate_memory},
        "essential": true,
        "networkMode": "awsvpc",
        "portMappings": [
          {
            "containerPort": 9000,
            "hostPort": 9000
          }
        ],
        "logConfiguration": {
          "logDriver": "awslogs",
          "options": {
            "awslogs-group": "/ecs/${var.project}-${var.env}-app",
            "awslogs-region": "ap-northeast-1",
            "awslogs-stream-prefix": "app"
          }
        },
        "environment": [
          {
            "name": "APP_NAME",
            "value": "Laravel"
          },
          {
            "name": "APP_ENV",
            "value": "staging"
          },
          {
            "name": "APP_DEBUG",
            "value": "true"
          },
          {
            "name": "APP_LOG_LEVEL",
            "value": "debug"
          },
          {
            "name": "APP_LOG",
            "value": "daily"
          },
          {
            "name": "DB_CONNECTION",
            "value": "mysql"
          },
          {
            "name": "DB_HOST",
            "value": "${aws_rds_cluster.aurora_cluster.endpoint}"
          },
          {
            "name": "DB_PORT",
            "value": "3306"
          },
          {
            "name": "DB_USERNAME",
            "value": "organizer"
          },
          {
            "name": "DB_DATABASE",
            "value": "event_organizer"
          },
          {
            "name": "REDIS_HOST",
            "value": "${aws_elasticache_cluster.main.cache_nodes.0.address}"
          },
          {
            "name": "REDIS_PORT",
            "value": "6379"
          },
          {
            "name": "CACHE_DRIVER",
            "value": "redis"
          },
          {
            "name": "SESSION_DRIVER",
            "value": "redis"
          },
          {
            "name": "SESSION_LIFETIME",
            "value": "10080"
          },
          {
            "name": "ADMIN_HTTPS",
            "value": "true"
          }
        ]
      }
    ]
  DEFINITION
}

data "template_file" "migration_task_definition" {
  template = <<DEFINITION
    [
      {
        "name": "migration",
        "image": "${data.terraform_remote_state.common.outputs.staging_app_repository_url}:latest",
        "cpu": ${var.fargate_cpu},
        "memory": ${var.fargate_memory},
        "essential": true,
        "entryPoint": ["/bin/sh"],
        "command": ["-c", "php artisan migrate --force"],
        "networkMode": "awsvpc",
        "logConfiguration": {
          "logDriver": "awslogs",
          "options": {
            "awslogs-group": "/ecs/${var.project}-${var.env}-migration",
            "awslogs-region": "ap-northeast-1",
            "awslogs-stream-prefix": "migration"
          }
        },
        "environment": [
          {
            "name": "APP_NAME",
            "value": "Laravel"
          },
          {
            "name": "APP_ENV",
            "value": "staging"
          },
          {
            "name": "APP_DEBUG",
            "value": "true"
          },
          {
            "name": "APP_LOG_LEVEL",
            "value": "debug"
          },
          {
            "name": "APP_LOG",
            "value": "daily"
          },
          {
            "name": "DB_CONNECTION",
            "value": "mysql"
          },
          {
            "name": "DB_HOST",
            "value": "${aws_rds_cluster.aurora_cluster.endpoint}"
          },
          {
            "name": "DB_PORT",
            "value": "3306"
          },
          {
            "name": "DB_USERNAME",
            "value": "organizer"
          },
          {
            "name": "DB_DATABASE",
            "value": "event_organizer"
          },
          {
            "name": "REDIS_HOST",
            "value": "${aws_elasticache_cluster.main.cache_nodes.0.address}"
          },
          {
            "name": "REDIS_PORT",
            "value": "6379"
          },
          {
            "name": "CACHE_DRIVER",
            "value": "redis"
          },
          {
            "name": "SESSION_DRIVER",
            "value": "redis"
          },
          {
            "name": "SESSION_LIFETIME",
            "value": "10080"
          },
          {
            "name": "ADMIN_HTTPS",
            "value": "true"
          }
        ]
      }
    ]
  DEFINITION
}

data "template_file" "cron_task_definition" {
  template = <<DEFINITION
    [
      {
        "name": "cron",
        "image": "${data.terraform_remote_state.common.outputs.staging_app_repository_url}:latest",
        "cpu": ${var.fargate_cpu},
        "memory": ${var.fargate_memory},
        "entryPoint": ["/bin/sh"],
        "command": ["-c", "echo '* * * * * php /app/artisan schedule:run' > /var/spool/cron/crontabs/root && crond -l 2 -f"],
        "essential": true,
        "logConfiguration": {
          "logDriver": "awslogs",
          "options": {
            "awslogs-group": "/ecs/${var.project}-${var.env}-cron",
            "awslogs-region": "ap-northeast-1",
            "awslogs-stream-prefix": "cron"
          }
        },
        "environment": [
          {
            "name": "APP_NAME",
            "value": "Laravel"
          },
          {
            "name": "APP_ENV",
            "value": "staging"
          },
          {
            "name": "APP_DEBUG",
            "value": "true"
          },
          {
            "name": "APP_LOG_LEVEL",
            "value": "debug"
          },
          {
            "name": "APP_LOG",
            "value": "daily"
          },
          {
            "name": "DB_CONNECTION",
            "value": "mysql"
          },
          {
            "name": "DB_HOST",
            "value": "${aws_rds_cluster.aurora_cluster.endpoint}"
          },
          {
            "name": "DB_PORT",
            "value": "3306"
          },
          {
            "name": "DB_USERNAME",
            "value": "organizer"
          },
          {
            "name": "DB_DATABASE",
            "value": "event_organizer"
          },
          {
            "name": "REDIS_HOST",
            "value": "${aws_elasticache_cluster.main.cache_nodes.0.address}"
          },
          {
            "name": "REDIS_PORT",
            "value": "6379"
          },
          {
            "name": "CACHE_DRIVER",
            "value": "redis"
          },
          {
            "name": "SESSION_DRIVER",
            "value": "redis"
          },
          {
            "name": "SESSION_LIFETIME",
            "value": "10080"
          },
          {
            "name": "ADMIN_HTTPS",
            "value": "true"
          }
        ]
      }
    ]
  DEFINITION
}
