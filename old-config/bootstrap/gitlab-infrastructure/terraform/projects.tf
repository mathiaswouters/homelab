# Repository definitions

###############################
### Infrastructure projects ###
###############################

resource "gitlab_project" "terraform_modules" {
  name             = "terraform-modules"
  namespace_id     = gitlab_group.infrastructure.id
  description      = "Reusable Terraform modules for homelab infrastructure"
  visibility_level = var.default_visibility
  default_branch   = "main"

  initialize_with_readme           = true
  remove_source_branch_after_merge = true
  issues_access_level              = "enabled"
  merge_requests_access_level      = "enabled"
  merge_method                     = "merge"
}

resource "gitlab_project" "ansible_playbooks" {
  name             = "ansible-playbooks"
  namespace_id     = gitlab_group.infrastructure.id
  description      = "Ansible playbooks and roles for homelab automation"
  visibility_level = var.default_visibility
  default_branch   = "main"

  initialize_with_readme           = true
  remove_source_branch_after_merge = true
  issues_access_level              = "enabled"
  merge_requests_access_level      = "enabled"
  merge_method                     = "merge"
}

resource "gitlab_project" "proxmox_automation" {
  name             = "proxmox-automation"
  namespace_id     = gitlab_group.infrastructure.id
  description      = "Proxmox automation scripts and configurations"
  visibility_level = var.default_visibility
  default_branch   = "main"

  initialize_with_readme           = true
  remove_source_branch_after_merge = true
  issues_access_level              = "enabled"
  merge_requests_access_level      = "enabled"
  merge_method                     = "merge"
}

###########################
### Kubernetes projects ###
###########################

resource "gitlab_project" "argocd_apps" {
  name             = "argocd-apps"
  namespace_id     = gitlab_group.kubernetes.id
  description      = "ArgoCD Application definitions for GitOps"
  visibility_level = var.default_visibility
  default_branch   = "main"

  initialize_with_readme           = true
  remove_source_branch_after_merge = true
  issues_access_level              = "enabled"
  merge_requests_access_level      = "enabled"
  merge_method                     = "merge"
}

resource "gitlab_project" "helm_charts" {
  name             = "helm-charts"
  namespace_id     = gitlab_group.kubernetes.id
  description      = "Custom Helm charts for homelab services"
  visibility_level = var.default_visibility
  default_branch   = "main"

  initialize_with_readme           = true
  remove_source_branch_after_merge = true
  issues_access_level              = "enabled"
  merge_requests_access_level      = "enabled"
  merge_method                     = "merge"
}

resource "gitlab_project" "k8s_manifests" {
  name             = "k8s-manifests"
  namespace_id     = gitlab_group.kubernetes.id
  description      = "Raw Kubernetes manifests"
  visibility_level = var.default_visibility
  default_branch   = "main"

  initialize_with_readme           = true
  remove_source_branch_after_merge = true
  issues_access_level              = "enabled"
  merge_requests_access_level      = "enabled"
  merge_method                     = "merge"
}

###########################
### Monitoring projects ###
###########################

resource "gitlab_project" "prometheus_config" {
  name             = "prometheus-config"
  namespace_id     = gitlab_group.services_monitoring.id
  description      = "Prometheus configuration and rules"
  visibility_level = var.default_visibility
  default_branch   = "main"

  initialize_with_readme           = true
  remove_source_branch_after_merge = true
  issues_access_level              = "enabled"
  merge_requests_access_level      = "enabled"
  merge_method                     = "merge"
}

resource "gitlab_project" "grafana_dashboards" {
  name             = "grafana-dashboards"
  namespace_id     = gitlab_group.services_monitoring.id
  description      = "Grafana dashboard definitions"
  visibility_level = var.default_visibility
  default_branch   = "main"

  initialize_with_readme           = true
  remove_source_branch_after_merge = true
  issues_access_level              = "enabled"
  merge_requests_access_level      = "enabled"
  merge_method                     = "merge"
}

#########################
### Security projects ###
#########################

resource "gitlab_project" "vault_config" {
  name             = "vault-config"
  namespace_id     = gitlab_group.services_security.id
  description      = "HashiCorp Vault configuration"
  visibility_level = var.default_visibility
  default_branch   = "main"

  initialize_with_readme           = true
  remove_source_branch_after_merge = true
  issues_access_level              = "enabled"
  merge_requests_access_level      = "enabled"
  merge_method                     = "merge"
}

resource "gitlab_project" "wazuh_config" {
  name             = "wazuh-config"
  namespace_id     = gitlab_group.services_security.id
  description      = "Wazuh configuration"
  visibility_level = var.default_visibility
  default_branch   = "main"

  initialize_with_readme           = true
  remove_source_branch_after_merge = true
  issues_access_level              = "enabled"
  merge_requests_access_level      = "enabled"
  merge_method                     = "merge"
}

########################
### Storage projects ###
########################

resource "gitlab_project" "longhorn_config" {
  name             = "longhorn-config"
  namespace_id     = gitlab_group.services_storage.id
  description      = "Longhorn configuration"
  visibility_level = var.default_visibility
  default_branch   = "main"

  initialize_with_readme           = true
  remove_source_branch_after_merge = true
  issues_access_level              = "enabled"
  merge_requests_access_level      = "enabled"
  merge_method                     = "merge"
}

resource "gitlab_project" "minio_config" {
  name             = "minio-config"
  namespace_id     = gitlab_group.services_storage.id
  description      = "MinIO configuration"
  visibility_level = var.default_visibility
  default_branch   = "main"

  initialize_with_readme           = true
  remove_source_branch_after_merge = true
  issues_access_level              = "enabled"
  merge_requests_access_level      = "enabled"
  merge_method                     = "merge"
}

###########################
### Networking projects ###
###########################

resource "gitlab_project" "traefik_config" {
  name             = "traefik-config"
  namespace_id     = gitlab_group.services_networking.id
  description      = "Traefik reverse proxy configuration"
  visibility_level = var.default_visibility
  default_branch   = "main"

  initialize_with_readme           = true
  remove_source_branch_after_merge = true
  issues_access_level              = "enabled"
  merge_requests_access_level      = "enabled"
  merge_method                     = "merge"
}

resource "gitlab_project" "cert_manager_config" {
  name             = "cert-manager-config"
  namespace_id     = gitlab_group.services_networking.id
  description      = "cert-manager and Let's Encrypt configuration"
  visibility_level = var.default_visibility
  default_branch   = "main"

  initialize_with_readme           = true
  remove_source_branch_after_merge = true
  issues_access_level              = "enabled"
  merge_requests_access_level      = "enabled"
  merge_method                     = "merge"
}

resource "gitlab_project" "metallb_config" {
  name             = "metallb-config"
  namespace_id     = gitlab_group.services_networking.id
  description      = "MetalLB load balancer configuration"
  visibility_level = var.default_visibility
  default_branch   = "main"

  initialize_with_readme           = true
  remove_source_branch_after_merge = true
  issues_access_level              = "enabled"
  merge_requests_access_level      = "enabled"
  merge_method                     = "merge"
}

#############################
### Applications projects ###
#############################

resource "gitlab_project" "homelab_dashboard" {
  name             = "homelab-dashboard"
  namespace_id     = gitlab_group.applications.id
  description      = "Homelab dashboard application"
  visibility_level = var.default_visibility
  default_branch   = "main"

  initialize_with_readme           = true
  remove_source_branch_after_merge = true
  issues_access_level              = "enabled"
  merge_requests_access_level      = "enabled"
  merge_method                     = "merge"
}

##########################
### Pipelines projects ###
##########################
resource "gitlab_project" "ci_templates" {
  name             = "ci-templates"
  namespace_id     = gitlab_group.pipelines.id
  description      = "Reusable GitLab CI/CD templates"
  visibility_level = var.default_visibility
  default_branch   = "main"

  initialize_with_readme           = true
  remove_source_branch_after_merge = true
  issues_access_level              = "enabled"
  merge_requests_access_level      = "enabled"
  merge_method                     = "merge"
}

resource "gitlab_project" "scripts" {
  name             = "scripts"
  namespace_id     = gitlab_group.pipelines.id
  description      = "Custom scripts"
  visibility_level = var.default_visibility
  default_branch   = "main"

  initialize_with_readme           = true
  remove_source_branch_after_merge = true
  issues_access_level              = "enabled"
  merge_requests_access_level      = "enabled"
  merge_method                     = "merge"
}