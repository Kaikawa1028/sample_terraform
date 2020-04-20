# resource "aws_cloudwatch_log_group" "laravel" {
#   name = "${var.project}-${var.env}"

#   tags = {
#     Environment = var.env
#     Application = "laravel"
#   }
# }


resource "aws_cloudwatch_log_group" "nginx" {
  name = "/ecs/${var.project}-${var.env}-nginx"

  tags = {
    Environment = var.env
    Application = "nginx"
  }
}

resource "aws_cloudwatch_log_group" "app" {
  name = "/ecs/${var.project}-${var.env}-app"

  tags = {
    Environment = var.env
    Application = "app"
  }
}

resource "aws_cloudwatch_log_group" "migrate" {
  name = "/ecs/${var.project}-${var.env}-migrate"

  tags = {
    Environment = var.env
    Application = "migrate"
  }
}

resource "aws_cloudwatch_log_group" "cron" {
  name = "/ecs/${var.project}-${var.env}-cron"

  tags = {
    Environment = var.env
    Application = "cron"
  }
}

resource "aws_cloudwatch_log_group" "server" {
  name = "${var.project}-development"

  tags = {
    Environment = var.env
    Application = "server"
  }
}

resource "aws_cloudwatch_metric_alarm" "service_sacle_out_alerm" {
  alarm_name          = "${var.project}-${var.env}-ecs-cpu-utilization-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "300" # 5分
  statistic           = "Average"
  threshold           = "75"

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.app.name
  }

  alarm_actions = [aws_appautoscaling_policy.scale_up.arn]
}

resource "aws_cloudwatch_metric_alarm" "service_sacle_down_alerm" {
  alarm_name          = "${var.project}-${var.env}-ecs-cpu-utilization-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "30"

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.app.name
  }

  alarm_actions = [aws_appautoscaling_policy.scale_down.arn]
}

resource "aws_appautoscaling_policy" "scale_up" {
  name               = "app-scale-up"
  service_namespace  = aws_appautoscaling_target.app_scale_target.service_namespace
  resource_id        = aws_appautoscaling_target.app_scale_target.resource_id
  scalable_dimension = aws_appautoscaling_target.app_scale_target.scalable_dimension

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }

  depends_on = [aws_appautoscaling_target.app_scale_target]
}

resource "aws_appautoscaling_policy" "scale_down" {
  name               = "app-scale-down"
  service_namespace  = aws_appautoscaling_target.app_scale_target.service_namespace
  resource_id        = aws_appautoscaling_target.app_scale_target.resource_id
  scalable_dimension = aws_appautoscaling_target.app_scale_target.scalable_dimension

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }

  depends_on = [aws_appautoscaling_target.app_scale_target]
}

resource "aws_appautoscaling_target" "app_scale_target" {
  max_capacity       = 3
  min_capacity       = 2
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.app.name}"
  role_arn           = data.terraform_remote_state.common.outputs.ecs_autoscale_role_arn
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}
