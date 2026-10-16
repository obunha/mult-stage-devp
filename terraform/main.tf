provider "aws" {
  region = "af-south-1"
}

# Networking Data - Automatically find default VPC and Subnets
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Security Group for the application
resource "aws_security_group" "app_sg" {
  name        = "multistage-app-sg"
  description = "Allow inbound traffic on port 3000"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create ECR for Dev
module "ecr_dev" {
  source = "./modules/ecr"
  env    = "dev"
}

# Create ECS for Dev
module "ecs_dev" {
  source            = "./modules/ecs"
  env               = "dev"
  region            = "af-south-1"
  image_url         = module.ecr_dev.repository_url
  subnets           = data.aws_subnets.default.ids
  security_group_id = aws_security_group.app_sg.id
}

# Create ECR for Staging
module "ecr_staging" {
  source = "./modules/ecr"
  env    = "staging"
}

# Create ECS for Staging
module "ecs_staging" {
  source            = "./modules/ecs"
  env               = "staging"
  region            = "af-south-1"
  image_url         = module.ecr_staging.repository_url
  subnets           = data.aws_subnets.default.ids
  security_group_id = aws_security_group.app_sg.id
}

# Create ECR for Production
module "ecr_production" {
  source = "./modules/ecr"
  env    = "production"
}

# Create ECS for Production
module "ecs_production" {
  source            = "./modules/ecs"
  env               = "production"
  region            = "af-south-1"
  image_url         = module.ecr_production.repository_url
  subnets           = data.aws_subnets.default.ids
  security_group_id = aws_security_group.app_sg.id
}
