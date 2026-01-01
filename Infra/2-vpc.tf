data "aws_availability_zones" "azs" {
  state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "cisco-devops-master-vpc"
  cidr = "10.0.0.0/16"

  enable_dns_support   = true
  enable_dns_hostnames = true

  azs = slice(data.aws_availability_zones.azs.names, 0, 3)

  # Public subnets – ECS tasks will run here (no ALB)
  public_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24"
  ]

  # Private subnets – Redis, future workloads
  private_subnets = [
    "10.0.101.0/24",
    "10.0.102.0/24",
    "10.0.103.0/24"
  ]

  # NAT (needed for private subnets)
  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  map_public_ip_on_launch = false

  # Global VPC tags
  tags = {
    Project = "cisco"
    Network = "Devops-master"
  }

  # Public subnet tags (ECS public tasks)
  public_subnet_tags = {
    Tier = "public"
    Role = "ecs-public"
  }

  # Private subnet tags (Redis / internal services)
  private_subnet_tags = {
    Tier = "private"
    Role = "internal"
  }

  # Per-subnet Name tags
  public_subnet_names = [
    "cisco-public-ecs-a",
    "cisco-public-ecs-b",
    "cisco-public-ecs-c"
  ]

  private_subnet_names = [
    "cisco-private-internal-a",
    "cisco-private-internal-b",
    "cisco-private-internal-c"
  ]
}
