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
        memory      = number
        vm_state    = string
        onboot      = bool
        startup     = string
        ipconfig    = string
        cores       = number
        bridge      = string
        network_tag = number
    }))

    default = {
      "gitlab" = {
        vm_id       = 101
        name        = "gitlab"
        memory      = 16384
        vm_state    = "running"
        onboot      = true
        startup     = "order=2"
        ipconfig    = "ip=192.168.0.11/24,gw=192.168.0.1"
        cores       = 8
        bridge      = "vmbr0"
        network_tag = 0
      }
    }
}