# Homelab

*Here comes the introduction*

## Kubernetes Setup

### Management Cluster

#### VMs

- 1 x control (2 cpu - 8 GB ram)
- 2 x worker (2 cpu - 8 GB ram)

#### Services

- ArgoCD
- Harbor
- HashiCorp Vault
- Cert-Manager
- External-DNS
- Monitoring stack
- Log
- Ingress Controller
- ...

### Workload Cluster

#### VMs

- 1 x control (2 cpu - 8 GB ram)
- 2 x worker (2 cpu - 8 GB ram)

#### Services

- Ingress
- Application workloads

## Setup:

1. copy_ssh_keys_to_vms script:
```
chmod 700 copy_ssh_keys_to_vms.sh
./copy_ssh_keys_to_vms.sh
```

2. bootstrap playbook:
```
ansible-playbook bootstrap.yml -i inventory/hosts.ini -K
```

3. update-vms playbook:
```
ansible-playbook update-vms.yml -i inventory/hosts.ini
```

4. other playbooks:
```
ansible-playbook playbooks/main.yml
```

## Resources
- **[The Lazy Automator - YouTube Channel](https://www.youtube.com/@Tech-TheLazyAutomator/videos)**
- [Proxmox Cloud-Init Guide - YT Jim's Garage](https://www.youtube.com/watch?v=Kv6-_--y5CM)
- [Proxmox Terraform Guide #1 - YT Jim's Garage](https://www.youtube.com/watch?v=ZGWn6xREdDE)
- [Proxmox Terraform Guide #2 - YT Learn Linux TV](https://www.youtube.com/watch?v=1kFBk0ePtxo)
- [Pi-Hole DNS Guide - YT WunderTech](https://www.youtube.com/watch?v=6sznCZ7ttbI)
- [Jim's Garage - YouTube Videos](https://www.youtube.com/@Jims-Garage/videos)
- [VirtualizationHowto - YouTube Videos](https://www.youtube.com/@VirtualizationHowto/videos)
- [ARR Stack Tutorial - YouTube Video](https://www.youtube.com/watch?v=GPouykKLqbE)

## Homelab Architecture & Services:

- [Homelab Architecture & Services]()
- [Homelab Architecture Diagram]()


---

## Things to look into:

- **Cloudflare tunnel**

- **DNS + Hostnames with Public owned domain name --> mathiaswouters.com**
