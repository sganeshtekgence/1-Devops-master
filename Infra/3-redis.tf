############################################
# Security Group for Redis
############################################

resource "aws_security_group" "redis_sg" {
  name        = "cisco-devops-master-redis-sg"
  description = "Allow Redis access from ECS tasks only"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "Redis from ECS tasks"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_task_sg.id]
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
# ElastiCache Subnet Group (Private Subnets)
############################################

resource "aws_elasticache_subnet_group" "redis" {
  name       = "cisco-devops-master-redis-subnet-group"
  subnet_ids = module.vpc.private_subnets

  tags = local.common_tags
}

############################################
# ElastiCache Redis Cluster
############################################

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "cisco-devops-master-redis"
  engine               = "redis"
  engine_version       = "7.0"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  port                 = 6379

  subnet_group_name    = aws_elasticache_subnet_group.redis.name
  security_group_ids  = [aws_security_group.redis_sg.id]

  tags = local.common_tags
}

############################################
# Outputs
############################################

output "redis_endpoint" {
  description = "Redis primary endpoint"
  value       = aws_elasticache_cluster.redis.cache_nodes[0].address
}
