# Subgroups

resource "gitlab_group" "services_monitoring" {
  name             = "monitoring"
  path             = "monitoring"
  parent_id        = gitlab_group.services.id
  description      = "Monitoring stack configurations"
  visibility_level = var.default_visibility

  project_creation_level = "maintainer"
  auto_devops_enabled    = false
}

resource "gitlab_group" "services_security" {
  name             = "security"
  path             = "security"
  parent_id        = gitlab_group.services.id
  description      = "Security services configurations"
  visibility_level = var.default_visibility

  project_creation_level = "maintainer"
  auto_devops_enabled    = false
}

resource "gitlab_group" "services_storage" {
  name             = "storage"
  path             = "storage"
  parent_id        = gitlab_group.services.id
  description      = "Storage solutions configurations"
  visibility_level = var.default_visibility

  project_creation_level = "maintainer"
  auto_devops_enabled    = false
}

resource "gitlab_group" "services_networking" {
  name             = "networking"
  path             = "networking"
  parent_id        = gitlab_group.services.id
  description      = "Networking services configurations"
  visibility_level = var.default_visibility

  project_creation_level = "maintainer"
  auto_devops_enabled    = false
}