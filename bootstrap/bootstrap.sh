#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}GitLab Homelab Bootstrap${NC}"
echo -e "${GREEN}=====================================${NC}"
echo ""

# Step 1: Terraform Provisioning
echo -e "${YELLOW}Step 1: Provisioning VMs with Terraform...${NC}"
cd terraform-provisioning

if [ ! -f "credentials.auto.tfvars" ]; then
    echo -e "${RED}ERROR: credentials.auto.tfvars not found!${NC}"
    echo "Please create it from credentials.auto.tfvars.example"
    exit 1
fi

terraform init
terraform plan
read -p "Do you want to apply this Terraform plan? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    echo "Terraform apply cancelled."
    exit 0
fi

terraform apply

echo -e "${GREEN}✓ VMs provisioned successfully${NC}"
echo ""

# Wait for VMs to be ready
echo -e "${YELLOW}Waiting 30 seconds for VMs to fully boot...${NC}"
sleep 30

# Step 2: Install GitLab and GitLab Runner
echo -e "${YELLOW}Step 2: Installing GitLab and GitLab Runner...${NC}"
cd ../ansible

# Test connectivity
echo "Testing SSH connectivity..."
ansible all -m ping

echo ""
echo "Installing GitLab and GitLab Runner..."
ansible-playbook site.yml

echo -e "${GREEN}✓ GitLab and GitLab Runner installed${NC}"
echo ""

# Step 3: Instructions for manual token creation
echo -e "${YELLOW}=====================================${NC}"
echo -e "${YELLOW}Step 3: Manual Configuration Required${NC}"
echo -e "${YELLOW}=====================================${NC}"
echo ""
echo "Please complete the following steps:"
echo ""
echo "1. Access GitLab UI:"
echo "   URL: http://192.168.0.11 (or http://gitlab)"
echo ""
echo "2. Login with root credentials (displayed above)"
echo ""
echo "3. Create a runner token:"
echo "   - Go to: Admin Area → CI/CD → Runners"
echo "   - Click: 'New instance runner'"
echo "   - Configure: Tags: 'shell,linux', Enable 'Run untagged jobs'"
echo "   - Click: 'Create runner'"
echo "   - Copy the token (starts with glrt-)"
echo ""
echo "4. Store the token in Ansible Vault:"
echo "   cd $(pwd)"
echo "   mkdir -p group_vars/gitlab-runner"
echo "   ansible-vault create group_vars/gitlab-runner/vault.yml"
echo ""
echo "   Add this content:"
echo "   ---"
echo "   vault_gitlab_runner_token: \"glrt-your-token-here\""
echo ""
echo "5. Create vars file:"
echo "   vi group_vars/gitlab-runner/vars.yml"
echo ""
echo "   Add this content:"
echo "   ---"
echo "   gitlab_runner_token: \"{{ vault_gitlab_runner_token }}\""
echo ""
echo "6. Register the runner:"
echo "   ansible-playbook register-runner.yml --ask-vault-pass"
echo ""
echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}Bootstrap Phase 1 Complete!${NC}"
echo -e "${GREEN}=====================================${NC}"
