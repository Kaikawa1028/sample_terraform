resource "aws_ecs_cluster" "main" {
  name = "${var.project}-${var.env}"
}

resource "aws_ecs_service" "app" {
  name                               = "app"
  cluster                            = aws_ecs_cluster.main.arn
  task_definition                    = aws_ecs_task_definition.app.arn
  desired_count                      = 1
  launch_type                        = "FARGATE"
  deployment_minimum_healthy_percent = 50
  health_check_grace_period_seconds  = 60

  network_configuration {
    security_groups = [aws_security_group.ecs_tasks.id]

    subnets = [
      aws_subnet.public-primary.id,
      aws_subnet.public-secondary.id,
      aws_subnet.public-tertiary.id
    ]

    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.web.arn
    container_name   = "nginx"
    container_port   = "80"
  }

  lifecycle {
    ignore_changes = [
      task_definition
    ]
  }
}

resource "aws_ecs_service" "cron" {
  name                               = "cron"
  cluster                            = aws_ecs_cluster.main.arn
  task_definition                    = aws_ecs_task_definition.cron.arn
  desired_count                      = 1
  launch_type                        = "FARGATE"
  deployment_minimum_healthy_percent = 50

  network_configuration {
    security_groups = [aws_security_group.ecs_tasks.id]

    subnets = [
      aws_subnet.public-primary.id,
      aws_subnet.public-secondary.id,
      aws_subnet.public-tertiary.id
    ]

    assign_public_ip = true
  }

  lifecycle {
    ignore_changes = [
      task_definition,
      desired_count
    ]
  }
}

resource "aws_ecs_task_definition" "app" {
  family                   = "${var.project}-${var.env}-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  container_definitions    = data.template_file.app_task_definition.rendered
  execution_role_arn       = data.terraform_remote_state.common.outputs.ecs_task_execution_role_arn
  cpu                      = var.fargate_cpu * 2
  memory                   = var.fargate_memory * 2
}

resource "aws_ecs_task_definition" "migrate" {
  family                   = "${var.project}-${var.env}-migrate"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  container_definitions    = data.template_file.migration_task_definition.rendered
  execution_role_arn       = data.terraform_remote_state.common.outputs.ecs_task_execution_role_arn
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
}

resource "aws_ecs_task_definition" "cron" {
  family                   = "${var.project}-${var.env}-cron"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  container_definitions    = data.template_file.cron_task_definition.rendered
  execution_role_arn       = data.terraform_remote_state.common.outputs.ecs_task_execution_role_arn
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
}
