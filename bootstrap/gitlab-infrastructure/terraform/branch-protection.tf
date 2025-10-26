# Protect main branch for critical infrastructure repos

# resource "gitlab_branch_protection" "terraform_modules_main" {
#   project                      = gitlab_project.terraform_modules.id
#   branch                       = "main"
#   push_access_level           = "maintainer"
#   merge_access_level          = "maintainer"
#   allow_force_push            = false
#   code_owner_approval_required = false
# }

# resource "gitlab_branch_protection" "ansible_playbooks_main" {
#   project                      = gitlab_project.ansible_playbooks.id
#   branch                       = "main"
#   push_access_level           = "maintainer"
#   merge_access_level          = "maintainer"
#   allow_force_push            = false
# }

# resource "gitlab_branch_protection" "argocd_apps_main" {
#   project                      = gitlab_project.argocd_apps.id
#   branch                       = "main"
#   push_access_level           = "maintainer"
#   merge_access_level          = "developer"
#   allow_force_push            = false
# }