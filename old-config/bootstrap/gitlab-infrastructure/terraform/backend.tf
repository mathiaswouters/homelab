# To store tf state file in GitLab, so it can be shared

terraform {
  backend "http" {
    address        = "http://192.168.0.11/api/v4/projects/1/terraform/state/gitlab-infra"
    lock_address   = "http://192.168.0.11/api/v4/projects/1/terraform/state/gitlab-infra/lock"
    unlock_address = "http://192.168.0.11/api/v4/projects/1/terraform/state/gitlab-infra/lock"
    lock_method    = "POST"
    unlock_method  = "DELETE"
    username       = "mathias"
    retry_wait_min = 5
  }
}