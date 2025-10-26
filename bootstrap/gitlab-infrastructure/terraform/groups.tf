# Root groups

resource "gitlab_group" "infrastructure" {
  name             = "infrastructure"
  path             = "infrastructure"
  description      = "Infrastructure as Code - Terraform, Ansible, ..."
  visibility_level = var.default_visibility

  request_access_enabled            = false
  require_two_factor_authentication = false
  project_creation_level            = "maintainer"
  subgroup_creation_level           = "maintainer"
  auto_devops_enabled               = false
}

resource "gitlab_group" "kubernetes" {
  name             = "kubernetes"
  path             = "kubernetes"
  description      = "Kubernetes configurations and GitOps"
  visibility_level = var.default_visibility

  request_access_enabled            = false
  require_two_factor_authentication = false
  project_creation_level            = "maintainer"
  subgroup_creation_level           = "maintainer"
  auto_devops_enabled               = false
}

resource "gitlab_group" "services" {
  name             = "services"
  path             = "services"
  description      = "Homelab services configurations"
  visibility_level = var.default_visibility

  request_access_enabled            = false
  require_two_factor_authentication = false
  project_creation_level            = "maintainer"
  subgroup_creation_level           = "maintainer"
  auto_devops_enabled               = false
}

resource "gitlab_group" "applications" {
  name             = "applications"
  path             = "applications"
  description      = "Homelab applications and projects"
  visibility_level = var.default_visibility

  request_access_enabled            = false
  require_two_factor_authentication = false
  project_creation_level            = "maintainer"
  subgroup_creation_level           = "maintainer"
  auto_devops_enabled               = false
}

resource "gitlab_group" "pipelines" {
  name             = "pipelines"
  path             = "pipelines"
  description      = "Shared CI/CD templates and tools"
  visibility_level = var.default_visibility

  request_access_enabled            = false
  require_two_factor_authentication = false
  project_creation_level            = "maintainer"
  subgroup_creation_level           = "maintainer"
  auto_devops_enabled               = false
}