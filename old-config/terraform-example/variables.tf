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
      "vm-1" = {
        vm_id       = 102
        name        = "vm-1"
        tags        = "tag1,tag2"
        memory      = 1024
        vm_state    = "running"
        onboot      = true
        startup     = "order=2"
        ipconfig    = "ip=192.168.0.12/24,gw=192.168.0.1"
        cores       = 1
        bridge      = "vmbr0"
        network_tag = 0
        disk_size   = "32G"
      }

      "vm-2" = {
        vm_id       = 102
        name        = "vm-2"
        tags        = "tag1,tag2"
        memory      = 1024
        vm_state    = "running"
        onboot      = true
        startup     = "order=2"
        ipconfig    = "ip=<IP_ADDRESS>/<SUBNET_MASK>,gw=<GATEWAY_IP_ADDRESS>"
        cores       = 1
        bridge      = "vmbr0"
        network_tag = 0
        disk_size   = "32G"
      }

      "vm-3" = {
        vm_id       = 103
        name        = "vm-3"
        tags        = "tag1,tag2"
        memory      = 1024
        vm_state    = "running"
        onboot      = true
        startup     = "order=2"
        ipconfig    = "ip=<IP_ADDRESS>/<SUBNET_MASK>,gw=<GATEWAY_IP_ADDRESS>"
        cores       = 1
        bridge      = "vmbr0"
        network_tag = 0
        disk_size   = "32G"
      }
    }
}