# Homelab

## Steps:
1) Follow this guide: [TrueNas YouTube Guide](https://www.youtube.com/watch?v=SJZxgxc0Qhg)
2) See where everything needs to be deployed and where everything will be ran
3) Create a drawio diagram of everything

## Architecture:
- **Hypervisor**: Proxmox
- **NAS**: TrueNAS
- **Infrastructure as Code (provisioning vms)**: Terraform
- **Configuration as Code (configuring vms)**: Ansible
- **CI/CD & Version Control**: GitLab
- **GitOps**: ArgoCD
- **Container Orchestration / Kubernetes**: ...  --> 2 clusters (test and prod)
- **Monitoring**: Prometheus + Grafana
- **Persistent Volumes**: Longhorn
- **Container Registry**: Harbor
- **Secrets Management**: HashiCorp Vault / OpenBao
- **Certs / TLS Management**: Cert-Manager + Let's Encrypt
- **DNS**: Pi-Hole - External-DNS
- **Load Balancer**: MetalLB

## Services:
- **Dashboard**: Homepage
- **Reverse Proxy**: Traefik
- **VPN / Remote Access**: Tailscale / Twingate / Wireguard
- **Ad-Blocking**: Pi-Hole
- **Smart Home**: Home Assistant
- **Linktree alternative**: Littlelink
- **Link Shortener**: Shlink
- **File Hosting Services**: NextCloud
- **Torrent**: qBittorent
- **Media Stack**: ARR Stack
- **Jellyfin**: Media Player
- **...**: ...

## ARR Stack Tutorial

[ARR Stack Tutorial - YouTube Video](https://www.youtube.com/watch?v=GPouykKLqbE)

## Resources
[Jim's Garage - YouTube Videos](https://www.youtube.com/@Jims-Garage/videos)
