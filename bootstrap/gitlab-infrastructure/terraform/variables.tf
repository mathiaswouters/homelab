# Input variables

variable "gitlab_token" {
  description = "GitLab personal access token with API scope"
  type        = string
  sensitive   = true
}

variable "gitlab_base_url" {
  description = "GitLab instance URL"
  type        = string
  default     = "http://192.168.0.11/api/v4/"
}

variable "default_visibility" {
  description = "Default visibility for groups and projects"
  type        = string
  default     = "private"
  validation {
    condition     = contains(["private", "internal", "public"], var.default_visibility)
    error_message = "Visibility must be private, internal, or public"
  }
}

variable "admin_user_id" {
  description = "Your GitLab user ID for admin access"
  type        = number
}