# This tf file consists of ECS and Auto Scaling.
# -----------------------------------
# ECS
# -----------------------------------
resource "aws_ecs_cluster" "cluster" {
  name = format("%s_ecs_cluster", var.env_name)
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  configuration {
    execute_command_configuration {
      logging = "NONE"
      log_configuration {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.ecs_exec.name
      }
    }
  }
}
resource "aws_ecs_task_definition" "nginx_php" {
  family = format("%s_nginx_task_definition", var.env_name)
  container_definitions = jsonencode([
    {
      name      = "nginx"
      image     = format("%s.dkr.ecr.%s.amazonaws.com/ecr_nginx:latest", var.admin_iam_id, var.main_region)
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
      dependsOn = [
        {
          containerName = "php"
          condition     = "START"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs.name
          awslogs-region        = var.main_region
          awslogs-stream-prefix = "ecs"
        }
      }
    },
    {
      name         = "php"
      image        = format("%s.dkr.ecr.%s.amazonaws.com/ecr_php:latest", var.admin_iam_id, var.main_region)
      portMappings = []
      environment  = []
      secrets      = []
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs.name
          awslogs-region        = var.main_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
  task_role_arn            = aws_iam_role.task_role.arn
  execution_role_arn       = aws_iam_role.task_execution_role.arn
  cpu                      = 512
  memory                   = 3072 # 2048
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
}
resource "aws_ecs_service" "service" {
  name    = format("%s_ecs_service", var.env_name)
  cluster = aws_ecs_cluster.cluster.arn
  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    base              = 0
    weight            = 1
  }
  platform_version = "1.4.0"
  task_definition  = aws_ecs_task_definition.nginx_php.arn
  desired_count    = 1
  network_configuration {
    assign_public_ip = true
    security_groups  = [aws_security_group.fargate_sg.id]
    subnets          = [for subnet in aws_subnet.public_subnet_app : subnet.id]
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.alb_tg.arn
    container_name   = "nginx"
    container_port   = 80
  }
  enable_execute_command = true
  tags = {
    Name = format("%s_ecs_service", var.env_name)
  }
}

# Auto Scaling
resource "aws_appautoscaling_target" "app_autoscaling_target" {
  service_namespace  = "ecs"
  resource_id        = format("service/%s_ecs_cluster/%s_ecs_service", var.env_name, var.env_name)
  scalable_dimension = "ecs:service:DesiredCount"
  role_arn           = format("arn:aws:iam::%s:role/aws-service-role/ecs.application-autoscaling.amazonaws.com/AWSServiceRoleForApplicationAutoScaling_ECSService", var.admin_iam_id)
  min_capacity       = 1
  max_capacity       = 2
}
resource "aws_appautoscaling_policy" "app_autoscaling_scale_up" {
  name               = format("%s_name_app_autoscaling_up", var.env_name)
  service_namespace  = "ecs"
  resource_id        = format("service/%s_ecs_cluster/%s_ecs_service", var.env_name, var.env_name)
  scalable_dimension = "ecs:service:DesiredCount"
  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 120
    metric_aggregation_type = "Average"
    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }
}
resource "aws_appautoscaling_policy" "app_autoscaling_scale_down" {
  name               = format("%s_name_app_autoscaling_down", var.env_name)
  service_namespace  = "ecs"
  resource_id        = format("service/%s_ecs_cluster/%s_ecs_service", var.env_name, var.env_name)
  scalable_dimension = "ecs:service:DesiredCount"
  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 120
    metric_aggregation_type = "Average"
    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = -1
    }
  }
}
resource "aws_cloudwatch_metric_alarm" "alarm_cpu_high" {
  alarm_name          = format("%s_cpu_utilization_high", var.env_name)
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "70"
  dimensions = {
    ClusterName = format("%s_ecs_cluster", var.env_name)
    ServiceName = format("%s_ecs_service", var.env_name)
  }
  alarm_actions = [aws_appautoscaling_policy.app_autoscaling_scale_up.arn]
}
resource "aws_cloudwatch_metric_alarm" "alarm_cpu_low" {
  alarm_name          = format("%s_cpu_utilization_low", var.env_name)
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = 25
  dimensions = {
    ClusterName = format("%s_ecs_cluster", var.env_name)
    ServiceName = format("%s_ecs_service", var.env_name)
  }
  alarm_actions = [aws_appautoscaling_policy.app_autoscaling_scale_down.arn]
}