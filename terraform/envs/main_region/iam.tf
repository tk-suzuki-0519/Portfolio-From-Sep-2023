# -----------------------------------
# IAM
# -----------------------------------
# ECS Task Role
resource "aws_iam_role" "task_role" {
  name = format("%s_task_role", var.env_name)
  assume_role_policy = jsonencode({ # 公式情報。"Statements without a sid cannot be overridden. In other words, a statement without a sid from source_policy_documents cannot be overridden by statements from override_policy_documents."
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
  /* 原因切り分け用に一時的に全許可設定にする
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
*/
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "*",
        "Resource" : "*"
      }
    ]
  })
  tags = {
    Name = format("%s_task_policy", var.env_name)
  }
}
resource "aws_iam_role_policy_attachment" "task_attachment" {
  role       = aws_iam_role.task_role.name
  policy_arn = aws_iam_policy.task_policy.arn
}
resource "aws_iam_role_policy_attachment" "task_ecr_admin_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role       = aws_iam_role.task_role.name
}
# ECS Task Execution Role
resource "aws_iam_role" "task_execution_role" {
  name = format("%s_task_execution_role", var.env_name)
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
    Name = format("%s_task_execution_role", var.env_name)
  }
}
resource "aws_iam_role_policy_attachment" "AmazonECSTaskExecutionRolePolicy" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

#ECRからイメージをPULLするための、AmazonEC2ContainerRegistryReadOnlyを付与
resource "aws_iam_policy" "task_execution_ecr_pull_policy" {
  name = format("%s_ecr_pull_policy", var.env_name)
  /*
  policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:GetRepositoryPolicy",
        "ecr:DescribeRepositories",
        "ecr:ListImages",
        "ecr:DescribeImages",
        "ecr:BatchGetImage",
        "ecr:GetLifecyclePolicy",
        "ecr:GetLifecyclePolicyPreview",
        "ecr:ListTagsForResource",
        "ecr:DescribeImageScanFindings",
        "ssm:GetParameters",
        "secretsmanager:GetSecretValue",
        "kms:Decrypt"
      ],
      "Resource": "*"
    }
  ]
}
EOT
}
*/
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "*",
        "Resource" : "*"
      }
    ]
  })
  tags = {
    Name = format("%s_task_execution_ecr_pull_policy", var.env_name)
  }
}
resource "aws_iam_role_policy_attachment" "task_execution_ecr_attachment" {
  policy_arn = aws_iam_policy.task_execution_ecr_pull_policy.arn
  role       = aws_iam_role.task_execution_role.name
}
resource "aws_iam_role_policy_attachment" "task_execution_ecr_admin_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role       = aws_iam_role.task_execution_role.name
}

# ECSExec policy
resource "aws_iam_policy" "ecs_exec_policy" {
  name        = format("%s_ecs_exec_policy", var.env_name)
  description = format("%s_ecs_exec_policy", var.env_name)
  /* 原因切り分け用に一時的に全許可設定にする
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
*/
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "*",
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
