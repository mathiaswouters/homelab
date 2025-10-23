terraform {
  required_providers {
    gitlab = {
      source = "gitlabhq/gitlab"
      version = "18.5.0"
    }
  }
}

provider "gitlab" {
  # Configuration options
}
