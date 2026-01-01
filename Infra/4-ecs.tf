############################################
# ECS Cluster
############################################

resource "aws_ecs_cluster" "app" {
  name = "cisco-devops-master-ecs-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = local.common_tags
}

############################################
# CloudWatch Log Group
############################################

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/cisco-devops-master-image-service"
  retention_in_days = 14

  tags = local.common_tags
}

############################################
# ECS Task Definition
############################################

resource "aws_ecs_task_definition" "app" {
  family                   = "cisco-devops-master-image-service"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  execution_role_arn = aws_iam_role.ecs_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_role.arn

  runtime_platform {
    cpu_architecture        = "ARM64"
    operating_system_family = "LINUX"
  }

  container_definitions = jsonencode([
    {
      name      = "image-service"
      image     = "${aws_ecr_repository.app.repository_url}:${var.image_tag}"
      essential = true

      portMappings = [
        {
          containerPort = 8080
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "REDIS_HOST"
          value = aws_elasticache_cluster.redis.cache_nodes[0].address
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "api"
        }
      }
    }
  ])

  tags = local.common_tags
}

############################################
# Security Group for ECS Tasks
############################################

resource "aws_security_group" "ecs_task_sg" {
  name        = "cisco-devops-master-ecs-task-sg"
  description = "Allow inbound API traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Public access to API"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

############################################
# ECS Service (NO ALB, Public IP)
############################################

resource "aws_ecs_service" "app" {
  name            = "cisco-devops-master-image-service"
  cluster         = aws_ecs_cluster.app.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = module.vpc.public_subnets
    assign_public_ip = true
    security_groups  = [aws_security_group.ecs_task_sg.id]
  }

  tags = local.common_tags
}

############################################
# Outputs
############################################

output "ecs_cluster_name" {
  value = aws_ecs_cluster.app.name
}

output "ecs_service_name" {
  value = aws_ecs_service.app.name
}
