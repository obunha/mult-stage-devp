resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.env}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_cluster" "main" {
  name = "${var.env}-cluster"
}

resource "aws_ecs_service" "main" {
  name            = "${var.env}-service"
  cluster         = aws_ecs_cluster.main.id
  # Task definition is now managed by GitHub Actions
  # We provide a dummy or initial task definition if required,
  # but usually we create the service after the first deploy or use a placeholder.
  # To avoid Terraform errors, we will remove the task_definition requirement
  # by using a lifecycle ignore or managing it via the CI/CD pipeline.

  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnets
    assign_public_ip = true
    security_groups  = [var.security_group_id]
  }

  lifecycle {
    ignore_changes = [task_definition]
  }
}

resource "aws_cloudwatch_log_group" "app" {
  name = "/ecs/${var.env}-app"
}

output "service_name" {
  value = aws_ecs_service.main.name
}

output "cluster_name" {
  value = aws_ecs_cluster.main.name
}
