variable proxmox_api_url {
  type = string
  sensitive = true
}

variable proxmox_user {
  type = string
  sensitive = true
}

variable proxmox_password {
  type = string
  sensitive = true
}

variable ciuser {
  type = string
  sensitive = true
}

variable cipassword {
  type = string
  sensitive = true
}

variable sshkeys {
  type = string
  sensitive = true
}

variable vm_configs {
    type = map(object({
        vm_id       = number
        name        = string
        tags        = string
        memory      = number
        vm_state    = string
        onboot      = bool
        startup     = string
        ipconfig    = string
        cores       = number
        bridge      = string
        network_tag = number
        disk_size   = string
    }))

    default = {
      "gitlab" = {
        vm_id       = 101
        name        = "gitlab"
        tags        = "vm,system"
        memory      = 16384
        vm_state    = "running"
        onboot      = true
        startup     = "order=2"
        ipconfig    = "ip=192.168.0.11/24,gw=192.168.0.1"
        cores       = 8
        bridge      = "vmbr0"
        network_tag = 0
        disk_size   = "60G"
      }

      "gitlab-runner" = {
        vm_id       = 102
        name        = "gitlab-runner"
        tags        = "vm,system"
        memory      = 8192
        vm_state    = "running"
        onboot      = true
        startup     = "order=3"
        ipconfig    = "ip=192.168.0.12/24,gw=192.168.0.1"
        cores       = 4
        bridge      = "vmbr0"
        network_tag = 0
        disk_size   = "40G"
      }
    }
}