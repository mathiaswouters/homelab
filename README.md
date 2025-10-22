# Homelab

*Here comes the introduction*

## HP Z440 NIC Fix:

[Manual - HP Z440 NIC Fix](/docs/hp_z440-NIC-fix.md)

## Resources
- **[The Lazy Automator - YouTube Channel](https://www.youtube.com/@Tech-TheLazyAutomator/videos)**
- [Proxmox Cloud-Init Guide - YT Jim's Garage](https://www.youtube.com/watch?v=Kv6-_--y5CM)
- [Proxmox Terraform Guide #1 - YT Jim's Garage](https://www.youtube.com/watch?v=ZGWn6xREdDE)
- [Proxmox Terraform Guide #2 - YT Learn Linux TV](https://www.youtube.com/watch?v=1kFBk0ePtxo)
- [Pi-Hole DNS Guide - YT WunderTech](https://www.youtube.com/watch?v=6sznCZ7ttbI)
- [Jim's Garage - YouTube Videos](https://www.youtube.com/@Jims-Garage/videos)
- [VirtualizationHowto - YouTube Videos](https://www.youtube.com/@VirtualizationHowto/videos)
- [ARR Stack Tutorial - YouTube Video](https://www.youtube.com/watch?v=GPouykKLqbE)

## To-Do List:

- [To-Do List](/docs/todo.md)

## Detailed Explanation:

- [Detailed Explanation](/docs/detailed_explanation.md)

## Links:

- [Homelab Architecture](/docs/homelab_architecture.md)
- [Homelab Architecture Diagram](/docs/homelab_architecture.drawio)
- [Homelab Services](/docs/homelab_services.md)
- [Proxmox Setup Manual](/docs/proxmox-setup.md)
- [GitLab Setup Manual](/docs/gitlab-setup.md)

---


# Production-Grade Kubernetes Homelab

A fully automated, enterprise-grade homelab infrastructure demonstrating modern DevOps, Cloud, and Platform Engineering practices.

## 🎯 Project Overview

This project showcases a complete cloud-native platform built on bare-metal infrastructure, implementing industry-standard tools and practices used in production environments. The homelab runs a multi-cluster Kubernetes architecture with full GitOps automation, comprehensive observability, and production-grade security.

<!-- **Live Demo:** [homelab.mathiaswouters.com](https://homelab.mathiaswouters.com) -->

## 🏗️ Architecture

<!-- ### Infrastructure
- **Hypervisor:** Proxmox VE on HP Z440 (12 cores, 96GB RAM)
- **Storage:** 4TB LVM thin pool for distributed storage
- **Network:** Segregated VLANs with Pi-hole DNS and ad-blocking
- **Edge Cluster:** 3x Raspberry Pi running K3s -->

### Kubernetes Clusters
- **Management Cluster:** Hosts platform services (ArgoCD, GitLab Runners, Harbor, Monitoring)
- **Production Cluster:** HA cluster (3 control planes, 3 workers) for application workloads
- **Edge Cluster:** Lightweight K3s for edge computing scenarios

Kubernetes flavour on Proxmox VMs = **...**

Kubernetes flavour on Pi-cluster = **k3s**

### Key Components

**Infrastructure as Code:**
- Terraform for VM provisioning and infrastructure management
- Ansible for configuration management and K8s bootstrapping
- GitLab CI/CD for automated deployments

**GitOps & CI/CD:**
- ArgoCD for declarative GitOps workflows
- GitLab with self-hosted runners
- Automated build, scan, and deploy pipelines

**Container Platform:**
- Cilium CNI with eBPF-based networking and Hubble observability
- MetalLB for LoadBalancer services
- Longhorn for distributed block storage
- Harbor registry with vulnerability scanning

**Observability:**
- Prometheus + Grafana for metrics and visualization
- Loki + Promtail for centralized log aggregation
- Hubble for network observability
- Custom dashboards for cluster health and application metrics

**Security:**
- HashiCorp Vault for secrets management
- cert-manager with Let's Encrypt for automated TLS
- Network policies with Cilium
- Image scanning with Trivy in Harbor
- Cloudflare Tunnel for secure external access

**Networking:**
- Traefik as ingress controller and reverse proxy
- Pi-hole for DNS and ad-blocking
- External-DNS for automatic DNS record management

## 🚀 Demo Applications

### Cloud-Native Vulnerability Scanner Platform
A multi-tier application demonstrating microservices architecture:
- React frontend with real-time updates
- Go/Python API backend
- PostgreSQL database with HA setup
- Container image scanning with Trivy
- Full CI/CD pipeline from commit to production

**Access:**

## 📊 Monitoring & Observability

- **Grafana Dashboards:**
  - Cluster resource utilization
  - Application performance metrics
  - Network flow visualization (Hubble)
  - Storage metrics (Longhorn)
  
- **ArgoCD:**
  - GitOps deployment status
  - Application health and sync state

## 🛠️ Technologies Used

| Category | Technologies |
|----------|-------------|
| **Infrastructure** | Proxmox, Terraform, Ansible |
| **Kubernetes** | K3s, Kubeadm, Cilium, MetalLB |
| **GitOps & CI/CD** | ArgoCD, GitLab, GitLab Runners |
| **Storage** | Longhorn, MinIO |
| **Registry** | Harbor, GitLab Container Registry |
| **Observability** | Prometheus, Grafana, Loki, Promtail, Hubble |
| **Security** | HashiCorp Vault, cert-manager, Trivy |
| **Networking** | Traefik, Pi-hole, External-DNS, Cloudflare |
| **Languages** | Go, Python, Bash, HCL, YAML |

## 📁 Repository Structure

```
.
├── terraform/           # Infrastructure as Code
│   ├── proxmox/        # VM provisioning
│   └── cloudflare/     # DNS management
├── ansible/            # Configuration management
│   ├── playbooks/      # Automation playbooks
│   └── roles/          # Reusable roles
├── kubernetes/         # K8s manifests (subset for bootstrap)
│   ├── platform/       # Platform services
│   └── apps/           # Demo applications
├── docs/               # Detailed documentation
└── scripts/            # Utility scripts
```

**Note:** Full GitOps manifests and CI/CD pipelines are maintained in private GitLab instance.

## 🎓 Skills Demonstrated

- **Cloud & Platform Engineering:** Multi-cluster Kubernetes management, infrastructure automation
- **DevOps:** GitOps workflows, CI/CD pipelines, infrastructure as code
- **Site Reliability Engineering:** Observability, monitoring, alerting, disaster recovery
- **Security:** Secrets management, network policies, vulnerability scanning, zero-trust networking
- **Networking:** CNI configuration, load balancing, ingress control, DNS management
- **Storage:** Distributed storage, backup strategies, disaster recovery

## 🔄 Disaster Recovery

The entire infrastructure can be rebuilt from scratch using the code in this repository:
1. Bootstrap core VMs (GitLab, Vault, Bastion) via Terraform + Ansible
2. Deploy Management cluster
3. Install ArgoCD
4. GitOps takes over - everything else deploys automatically from Git

**Recovery Time Objective (RTO):** ~2 hours for full infrastructure rebuild

## 📝 Blog Posts & Documentation

I've documented my journey building this homelab:
- [Building a Production-Grade Kubernetes Homelab](https://mathiaswouters.com/blog/kubernetes-homelab)
- [GitOps with ArgoCD: Lessons Learned](https://mathiaswouters.com/blog/gitops-argocd)
- [Cilium eBPF Networking Deep Dive](https://mathiaswouters.com/blog/cilium-ebpf)

Full technical documentation available in [`docs/`](./docs/) directory.

## 🎯 Project Goals

This homelab was built to:
- Gain hands-on experience with production-grade Kubernetes and cloud-native tools
- Demonstrate practical DevOps and Platform Engineering skills
- Create a portfolio project showcasing modern infrastructure practices
- Provide a learning platform for emerging technologies
