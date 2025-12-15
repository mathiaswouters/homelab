# Group-level CI/CD vars

# # Infrastructure group variables
# resource "gitlab_group_variable" "infra_proxmox_url" {
#   group             = gitlab_group.infrastructure.id
#   key               = "PROXMOX_URL"
#   value             = "https://192.168.0.1:8006/api2/json"
#   protected         = true
#   masked            = true
#   environment_scope = "*"
# }

# resource "gitlab_group_variable" "infra_ansible_user" {
#   group             = gitlab_group.infrastructure.id
#   key               = "ANSIBLE_USER"
#   value             = "mathias"
#   protected         = false
#   masked            = false
#   environment_scope = "*"
# }
