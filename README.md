# Multi-Environment Deployment Pipeline

This project implements a robust CI/CD pipeline that promotes application deployments from **Development** to **Staging** and finally to **Production** using GitHub Actions, Docker, AWS ECS, and Terraform.

## 🚀 Architecture

- **Application**: Node.js Express app with a `/health` endpoint for smoke testing.
- **Containerization**: Docker images tagged with the Git SHA for traceability.
- **Infrastructure**: AWS ECS (Fargate) managed via Terraform modules.
- **Orchestration**: GitHub Actions using reusable workflows and environment gates.

## 🛠 Pipeline Flow

1. **Push to `main`**: Triggers the `promote.yml` workflow.
2. **Deploy to Dev**: Build $\rightarrow$ Push to ECR $\rightarrow$ Deploy to ECS Dev $\rightarrow$ Smoke Test.
3. **Deploy to Staging**: (Depends on Dev success) $\rightarrow$ Build $\rightarrow$ Push to ECR $\rightarrow$ Deploy to ECS Staging $\rightarrow$ Smoke Test.
4. **Deploy to Production**: (Depends on Staging success) $\rightarrow$ **Manual Approval Gate** $\rightarrow$ Build $\rightarrow$ Push to ECR $\rightarrow$ Deploy to ECS Prod $\rightarrow$ Smoke Test.

## ⚙️ Setup Instructions

### 1. GitHub Repository Configuration
To make the pipeline functional, you must configure the following in your GitHub repository:

#### Environments
Go to **Settings** $\rightarrow$ **Environments** and create:
- `dev`
- `staging`
- `production`

#### Protection Rules
- For the `production` environment, enable **Required reviewers**. This ensures that no code reaches production without explicit sign-off.

#### Secrets
Add the following secrets to each environment (or as repository secrets):
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION`

### 2. Infrastructure Deployment
The Terraform modules are located in `terraform/modules/`. To provision the infrastructure:
1. Initialize Terraform: `terraform init`
2. Apply the configuration for each environment (Dev, Staging, Prod).

## 📂 Project Structure

- `app/`: The application source code and Docker configuration.
- `.github/workflows/`:
  - `deploy.yml`: Reusable workflow containing the core build and deploy logic.
  - `promote.yml`: The orchestrator that manages the promotion sequence.
- `terraform/`: Infrastructure as Code modules for ECR and ECS.
