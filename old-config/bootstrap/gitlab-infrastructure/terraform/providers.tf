# GitLab provider config

terraform {
  required_providers {
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "18.5.0"
    }
  }
}

provider "gitlab" {
  token    = var.gitlab_token
  base_url = var.gitlab_base_url
}