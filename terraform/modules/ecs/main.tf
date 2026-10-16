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

resource "aws_ecs_task_definition" "app" {
  family                   = "${var.env}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "app"
      image     = var.image_url
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.env}-app"
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "main" {
  name            = "${var.env}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnets
    assign_public_ip = true
    security_groups  = [var.security_group_id]
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

output "task_definition_arn" {
  value = aws_ecs_task_definition.app.arn
}
