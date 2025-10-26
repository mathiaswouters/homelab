# Useful outputs

# output "group_urls" {
#   description = "URLs for all created groups"
#   value = {
#     infrastructure = gitlab_group.infrastructure.web_url
#     kubernetes     = gitlab_group.kubernetes.web_url
#     services       = gitlab_group.services.web_url
#     applications   = gitlab_group.applications.web_url
#     pipelines      = gitlab_group.pipelines.web_url
#   }
# }

# output "project_urls" {
#   description = "URLs for key projects"
#   value = {
#     terraform_modules  = gitlab_project.terraform_modules.web_url
#     ansible_playbooks  = gitlab_project.ansible_playbooks.web_url
#     argocd_apps       = gitlab_project.argocd_apps.web_url
#     ci_templates      = gitlab_project.ci_templates.web_url
#   }
# }

# output "group_ids" {
#   description = "Group IDs for reference"
#   value = {
#     infrastructure = gitlab_group.infrastructure.id
#     kubernetes     = gitlab_group.kubernetes.id
#     services       = gitlab_group.services.id
#     applications   = gitlab_group.applications.id
#     pipelines      = gitlab_group.pipelines.id
#   }
# }