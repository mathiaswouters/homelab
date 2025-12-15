# GitLab Infrastructure as Code

This repository manages the entire GitLab group and project structure using Terraform.

## Structure

- `infrastructure/` - IaC tools (Terraform, Ansible, Packer)
- `kubernetes/` - K8s configs and GitOps
- `services/` - Service configurations (monitoring, security, etc.)
- `applications/` - Homelab applications
- `pipelines/` - Shared CI/CD templates

## Prerequisites

1. GitLab personal access token with `api` scope
2. Terraform >= 1.6
3. Access to GitLab instance at http://192.168.0.11

## Usage

### Initial Setup
```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your token

terraform init
terraform plan
terraform apply
```

### CI/CD Pipeline

The repository includes a GitLab CI/CD pipeline that:
- Validates Terraform on every MR
- Plans changes on main branch
- Applies changes manually (approval required)

### Adding New Projects

1. Create feature branch
2. Add project definition to `03-projects.tf`
3. Create MR
4. Review plan output
5. Merge and manually trigger apply

## State Management

Terraform state is stored in GitLab's HTTP backend at:
```
http://192.168.0.11/api/v4/projects/1/terraform/state/gitlab-infra
```

## Variables

Set these CI/CD variables in the gitlab-infrastructure project:
- `GITLAB_TOKEN` - Personal access token (masked, protected)