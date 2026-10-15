provider "aws" {
  region = "af-south-1"
}

# Create ECR for Dev
module "ecr_dev" {
  source = "./modules/ecr"
  env    = "dev"
}

# Create ECR for Staging
module "ecr_staging" {
  source = "./modules/ecr"
  env    = "staging"
}

# Create ECR for Production
module "ecr_production" {
  source = "./modules/ecr"
  env    = "production"
}
