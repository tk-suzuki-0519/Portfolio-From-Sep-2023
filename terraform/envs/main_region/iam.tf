# -----------------------------------
# IAM
# -----------------------------------
# ECS Task Role
resource "aws_iam_role" "task_role" {
  name = format("%s_task_role", var.env_name)
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
  tags = {
    Name = format("%s_task_role", var.env_name)
  }
}
resource "aws_iam_policy" "task_policy" {
  name = format("%s_task_policy", var.env_name)
  path = "/service-role/"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "ssm:GetParametersByPath",
          "ssm:GetParameters",
          "ssm:GetParameter"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ecr:GetAuthorizationToken",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ecr:CompleteLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ],
        "Resource" : "*"
      }
    ]
  })
  tags = {
    Name = format("%s_task_policy", var.env_name)
  }
}
resource "aws_iam_role_policy_attachment" "task_attachment" {
  policy_arn = aws_iam_policy.task_policy.arn
  role       = aws_iam_role.task_role.name
}
# ECS Task Ececution Role
resource "aws_iam_role" "task_execution_role" {
  name               = format("%s_task_execution_role", var.env_name)
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
  tags = {
    Name = format("%s_task_execution_role", var.env_name)
  }
}
resource "aws_iam_role_policy_attachment" "AmazonECSTaskExecutionRolePolicy" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECSExec policy
resource "aws_iam_policy" "ecs_exec_policy" {
  name        = format("%s_ecs_exec_policy", var.env_name)
  description = format("%s_ecs_exec_policy", var.env_name)
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:ExecuteCommand",
        "ecs:DescribeTasks",
        "ssmmessages:CreateControlChannel",
        "ssmmessages:CreateDataChannel",
        "ssmmessages:OpenControlChannel",
        "ssmmessages:OpenDataChannel"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "ecs_exec_policy_attachment" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = aws_iam_policy.ecs_exec_policy.arn
}
resource "aws_iam_role" "ecs_autoscale_role" {
  name               = format("%s_ecs_autoscale_role", var.env_name)
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "application-autoscaling.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}
resource "aws_iam_policy" "ecs_autoscale_role" {
  name   = format("%s_ecs_autoscale_policy", var.env_name)
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Action": [
            "ecs:DescribeServices",
            "ecs:UpdateService",
            "cloudwatch:PutMetricAlarm",
            "cloudwatch:DescribeAlarms",
            "cloudwatch:DeleteAlarms"
        ],
        "Resource": [
            "*"
        ],
      "Effect": "Allow"
    }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "ecs_autoscale_role_attach" {
  role       = aws_iam_role.ecs_autoscale_role.name
  policy_arn = aws_iam_policy.ecs_autoscale_role.arn
}