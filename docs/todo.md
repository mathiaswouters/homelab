# Homelab Implementation TODO List

**Project Goal:** Build a production-grade Kubernetes homelab demonstrating Cloud/DevOps/Platform Engineering skills

**Target Completion:** 12 weeks (3 months)

**Status Legend:**
- ⬜ Not Started
- 🔄 In Progress
- ✅ Completed
- ⏸️ Blocked/Paused
- ⚠️ Needs Attention

---

## Phase 0: Preparation & Setup (Week 1)

### Local Development Environment
- ⬜ Install Terraform on Mac (`brew install terraform`)
- ⬜ Install Ansible on Mac (`brew install ansible`)
- ⬜ Install kubectl on Mac (`brew install kubectl`)
- ⬜ Install Helm on Mac (`brew install helm`)
- ⬜ Install Git and configure SSH keys
- ⬜ Configure Git global settings (name, email)

### Repository Setup
- ⬜ Create GitHub repo: `homelab-infrastructure`
- ⬜ Initialize Git locally (`git init`)
- ⬜ Create directory structure:
  ```
  mkdir -p terraform/{infrastructure-vms,management-cluster,production-cluster,modules}
  mkdir -p ansible/{playbooks,roles,inventory}
  mkdir -p kubernetes/{bootstrap,platform,apps}
  mkdir -p docs scripts
  ```
- ⬜ Create `.gitignore` file
- ⬜ Create initial README.md
- ⬜ Push to GitHub

### Proxmox Configuration
- ✅ Proxmox installed on HP Z440
- ✅ Pi-hole LXC created
- ✅ Pi-hole configured as DNS
- ✅ Cloud-init Ubuntu template created
- ⬜ Create 4TB LVM thin pool for Longhorn
- ⬜ Configure Proxmox API user for Terraform
- ⬜ Generate API token for Terraform
- ⬜ Test Proxmox API connectivity

### Domain & DNS Setup
- ⬜ Verify mathiaswouters.com domain ownership
- ⬜ Create Cloudflare account (if not exists)
- ⬜ Transfer/point domain to Cloudflare
- ⬜ Generate Cloudflare API token for cert-manager
- ⬜ Generate Cloudflare API token for External-DNS
- ⬜ Plan DNS subdomain structure (gitlab, argocd, grafana, etc.)

---

## Phase 1: Infrastructure VMs (Week 1-2)

### Terraform Infrastructure Code
- ⬜ Create Terraform provider configuration for Proxmox
- ⬜ Create reusable VM module (`modules/proxmox-vm`)
- ⬜ Write Terraform code for GitLab VM (8GB RAM, 4 vCPU)
- ⬜ Write Terraform code for Vault VM (2GB RAM, 2 vCPU)
- ⬜ Write Terraform code for Bastion VM (2GB RAM, 2 vCPU)
- ⬜ Write Terraform code for MinIO VM (4GB RAM, 4 vCPU) - Optional
- ⬜ Configure Terraform backend (local initially)
- ⬜ Test Terraform plan
- ⬜ Apply Terraform to create VMs

### Ansible Configuration
- ⬜ Create Ansible inventory file (`inventory/infrastructure.yml`)
- ⬜ Create common role for all VMs:
  - ⬜ Update packages
  - ⬜ Configure firewall
  - ⬜ Set up users
  - ⬜ Configure SSH hardening
- ⬜ Test Ansible connectivity to all VMs
- ⬜ Run common playbook

### GitLab Installation
- ⬜ Create Ansible playbook: `playbooks/gitlab-install.yml`
- ⬜ Install GitLab via Ansible
- ⬜ Configure GitLab external URL (https://gitlab.mathiaswouters.com)
- ⬜ Set up HTTPS with Let's Encrypt or manual cert
- ⬜ Configure Cloudflare Tunnel for GitLab
- ⬜ Create initial admin user
- ⬜ Configure GitLab settings (signup disabled, etc.)
- ⬜ Enable Container Registry
- ⬜ Create GitLab groups: `homelab/`
- ⬜ Create GitLab projects:
  - ⬜ `homelab/infrastructure`
  - ⬜ `homelab/kubernetes`
  - ⬜ `homelab/applications`

### Vault Installation
- ⬜ Create Ansible playbook: `playbooks/vault-install.yml`
- ⬜ Install Vault via Ansible
- ⬜ Initialize Vault (`vault operator init`)
- ⬜ Save unseal keys securely (encrypted file + password manager)
- ⬜ Save root token securely
- ⬜ Unseal Vault
- ⬜ Configure Vault systemd service
- ⬜ Configure Cloudflare Tunnel for Vault UI
- ⬜ Test Vault UI access

### MinIO Installation (Optional)
- ⬜ Create Ansible playbook: `playbooks/minio-install.yml`
- ⬜ Install MinIO via Ansible
- ⬜ Configure MinIO buckets:
  - ⬜ `longhorn-backups`
  - ⬜ `vault-backups`
  - ⬜ `gitlab-backups`
  - ⬜ `terraform-state`
- ⬜ Create MinIO access keys
- ⬜ Store keys in Vault
- ⬜ Test MinIO access

### GitLab Migration
- ⬜ Push local Git repo to GitLab
- ⬜ Configure GitLab CI/CD variables (Proxmox API, etc.)
- ⬜ Create `.gitlab-ci.yml` for infrastructure repo
- ⬜ Test CI/CD pipeline (validate stage)
- ⬜ Configure Terraform backend to use GitLab

---

## Phase 2: Management Cluster (Week 2-3)

### Management Cluster VMs
- ⬜ Write Terraform code for management cluster:
  - ⬜ 1 control plane VM (4GB RAM, 2 vCPU)
  - ⬜ 2 worker VMs (8GB RAM, 4 vCPU each)
  - ⬜ Add Longhorn disks (100GB each from 4TB pool)
- ⬜ Apply Terraform to create VMs
- ⬜ Verify VMs are accessible

### Kubernetes Bootstrap
- ⬜ Create Ansible inventory: `inventory/mgmt-cluster.yml`
- ⬜ Create Ansible role: `roles/k8s-common`
  - ⬜ Disable swap
  - ⬜ Load kernel modules
  - ⬜ Configure sysctl parameters
  - ⬜ Install containerd
  - ⬜ Install kubeadm, kubelet, kubectl
- ⬜ Create Ansible playbook: `playbooks/k8s-bootstrap.yml`
- ⬜ Initialize control plane with kubeadm
- ⬜ Join worker nodes
- ⬜ Copy kubeconfig to Mac (`~/.kube/mgmt-config`)
- ⬜ Test kubectl access from Mac

### Cilium CNI
- ⬜ Download Cilium CLI on Mac
- ⬜ Create Helm values for Cilium: `kubernetes/bootstrap/cilium/values.yaml`
  - ⬜ Enable Hubble for observability
  - ⬜ Enable Hubble UI
  - ⬜ Configure eBPF host routing
- ⬜ Install Cilium via Helm
- ⬜ Verify Cilium status (`cilium status`)
- ⬜ Test pod networking
- ⬜ Access Hubble UI

### MetalLB
- ⬜ Create MetalLB manifests: `kubernetes/platform/metallb/`
- ⬜ Configure IP address pool (192.168.1.100-192.168.1.150)
- ⬜ Create L2Advertisement config
- ⬜ Apply MetalLB manifests
- ⬜ Test LoadBalancer service creation

### Longhorn Storage
- ⬜ Prepare worker nodes with Ansible:
  - ⬜ Format Longhorn disks (/dev/sdb)
  - ⬜ Mount at /mnt/longhorn
  - ⬜ Install open-iscsi
  - ⬜ Install nfs-common
- ⬜ Create Longhorn manifests: `kubernetes/platform/longhorn/`
- ⬜ Install Longhorn via Helm
- ⬜ Configure Longhorn settings:
  - ⬜ Set replica count to 2
  - ⬜ Configure backup target (MinIO)
  - ⬜ Create RecurringJob for daily backups
- ⬜ Create StorageClass for Longhorn (set as default)
- ⬜ Test PVC creation and mounting
- ⬜ Access Longhorn UI

### ArgoCD Installation
- ⬜ Create ArgoCD namespace
- ⬜ Create ArgoCD manifests: `kubernetes/bootstrap/argocd/`
- ⬜ Install ArgoCD via kubectl
- ⬜ Get initial admin password
- ⬜ Access ArgoCD UI (port-forward initially)
- ⬜ Configure Cloudflare Tunnel for ArgoCD UI
- ⬜ Change admin password
- ⬜ Configure ArgoCD to use GitLab repos
- ⬜ Add GitLab SSH key to ArgoCD
- ⬜ Create ArgoCD projects:
  - ⬜ `platform` (for platform services)
  - ⬜ `apps` (for applications)

---

## Phase 3: Platform Services via GitOps (Week 3-5)

### GitOps Repository Structure
- ⬜ Push infrastructure code to GitLab
- ⬜ Create kubernetes repo structure:
  ```
  kubernetes/
  ├── clusters/
  │   └── management/
  │       └── apps.yaml
  ├── platform/
  │   ├── argocd/
  │   ├── cert-manager/
  │   ├── traefik/
  │   ├── harbor/
  │   ├── monitoring/
  │   ├── external-dns/
  │   └── vault-integration/
  └── apps/
      ├── staging/
      └── production/
  ```
- ⬜ Create ArgoCD App-of-Apps configuration
- ⬜ Test ArgoCD auto-sync

### cert-manager
- ⬜ Create cert-manager manifests: `platform/cert-manager/`
- ⬜ Install cert-manager CRDs
- ⬜ Create ClusterIssuer for Let's Encrypt (staging)
- ⬜ Create ClusterIssuer for Let's Encrypt (production)
- ⬜ Store Cloudflare API token in Kubernetes Secret
- ⬜ Test certificate issuance for test domain
- ⬜ Verify certificate in Kubernetes
- ⬜ Create ArgoCD Application for cert-manager
- ⬜ Test GitOps sync

### Traefik Ingress
- ⬜ Create Traefik manifests: `platform/traefik/`
- ⬜ Configure Traefik Helm values:
  - ⬜ Enable dashboard
  - ⬜ Configure Let's Encrypt
  - ⬜ Set up access logs
- ⬜ Deploy Traefik via ArgoCD
- ⬜ Verify LoadBalancer IP assigned by MetalLB
- ⬜ Create Ingress for Traefik dashboard
- ⬜ Test Traefik dashboard access
- ⬜ Configure Cloudflare DNS for *.k8s.mathiaswouters.com

### External-DNS
- ⬜ Create External-DNS manifests: `platform/external-dns/`
- ⬜ Configure External-DNS to update Pi-hole
- ⬜ Or configure for Cloudflare integration
- ⬜ Deploy via ArgoCD
- ⬜ Test automatic DNS record creation
- ⬜ Verify DNS records in Pi-hole or Cloudflare

### Harbor Registry
- ⬜ Create Harbor manifests: `platform/harbor/`
- ⬜ Configure Harbor Helm values:
  - ⬜ Enable Trivy scanner
  - ⬜ Configure persistent storage (Longhorn)
  - ⬜ Set admin password (from Vault)
  - ⬜ Enable image replication
- ⬜ Deploy Harbor via ArgoCD
- ⬜ Create Ingress for Harbor UI
- ⬜ Access Harbor UI (harbor.mathiaswouters.com)
- ⬜ Configure Harbor projects:
  - ⬜ `platform` (for platform images)
  - ⬜ `apps` (for application images)
- ⬜ Create robot accounts for CI/CD
- ⬜ Configure vulnerability scanning policies
- ⬜ Test image push/pull

### Vault Kubernetes Integration
- ⬜ Enable Kubernetes auth in Vault
- ⬜ Configure Vault to communicate with K8s API
- ⬜ Create Vault policies for K8s
- ⬜ Install Vault Agent Injector in K8s
- ⬜ Create test secret in Vault
- ⬜ Create test pod that reads secret from Vault
- ⬜ Verify secret injection works

### Monitoring Stack (Prometheus + Grafana)
- ⬜ Create monitoring manifests: `platform/monitoring/`
- ⬜ Install kube-prometheus-stack via Helm:
  - ⬜ Configure Prometheus
  - ⬜ Configure Grafana (admin password from Vault)
  - ⬜ Configure Alertmanager
  - ⬜ Enable persistent storage for Prometheus
  - ⬜ Enable persistent storage for Grafana
- ⬜ Deploy via ArgoCD
- ⬜ Create Ingress for Grafana
- ⬜ Access Grafana UI (grafana.mathiaswouters.com)
- ⬜ Import community dashboards:
  - ⬜ Kubernetes Cluster Monitoring (7249)
  - ⬜ Node Exporter Full (1860)
  - ⬜ Cilium Metrics (16611)
  - ⬜ Longhorn Dashboard (13032)
- ⬜ Configure data sources
- ⬜ Test metrics collection

### Loki + Promtail (Logging)
- ⬜ Create Loki manifests: `platform/monitoring/loki/`
- ⬜ Install Loki via Helm
- ⬜ Configure persistent storage for Loki
- ⬜ Install Promtail as DaemonSet
- ⬜ Configure Promtail to scrape pod logs
- ⬜ Deploy via ArgoCD
- ⬜ Add Loki as data source in Grafana
- ⬜ Test log queries in Grafana

### Alertmanager Configuration
- ⬜ Configure email notifications (or Slack/Discord)
- ⬜ Create PrometheusRule for critical alerts:
  - ⬜ Node down
  - ⬜ High memory usage
  - ⬜ High CPU usage
  - ⬜ Pod crash looping
  - ⬜ PVC full
  - ⬜ Certificate expiring soon
- ⬜ Test alert delivery
- ⬜ Create runbooks for common alerts

### GitLab Runner in Kubernetes
- ⬜ Create GitLab Runner manifests: `platform/gitlab-runner/`
- ⬜ Configure GitLab Runner Helm values:
  - ⬜ Use Kubernetes executor
  - ⬜ Configure cache (PVC or S3)
  - ⬜ Set resource limits
- ⬜ Register runner with GitLab
- ⬜ Deploy via ArgoCD
- ⬜ Test runner by creating test pipeline
- ⬜ Verify pods are created for CI jobs

---

## Phase 4: Production Cluster (Week 5-7)

### Production Cluster Infrastructure
- ⬜ Write Terraform code for production cluster:
  - ⬜ 3 control plane VMs (4GB RAM, 2 vCPU each)
  - ⬜ 3 worker VMs (12GB RAM, 4 vCPU each)
  - ⬜ Add Longhorn disks (300GB each from 4TB pool)
- ⬜ Create Ansible inventory: `inventory/prod-cluster.yml`
- ⬜ Apply Terraform to create VMs

### Production Cluster Bootstrap
- ⬜ Run Ansible playbook to prepare nodes
- ⬜ Initialize HA control plane:
  - ⬜ Set up load balancer for API server (HAProxy or kube-vip)
  - ⬜ Initialize first control plane
  - ⬜ Join remaining control planes
  - ⬜ Join worker nodes
- ⬜ Copy kubeconfig to Mac (`~/.kube/prod-config`)
- ⬜ Install Cilium on production cluster
- ⬜ Verify cluster health

### Production Cluster Platform Services
- ⬜ Deploy MetalLB (different IP pool: 192.168.1.160-192.168.1.200)
- ⬜ Prepare and deploy Longhorn
- ⬜ Deploy Traefik ingress
- ⬜ Deploy cert-manager
- ⬜ Deploy monitoring agents (Prometheus exporters, Promtail)
- ⬜ Create namespaces:
  - ⬜ `staging`
  - ⬜ `production`
- ⬜ Configure RBAC for namespaces

### ArgoCD Multi-Cluster Management
- ⬜ Add production cluster to ArgoCD
- ⬜ Configure ArgoCD to manage production cluster
- ⬜ Create ArgoCD Applications for production cluster
- ⬜ Test deployment to production cluster from ArgoCD

### Network Policies
- ⬜ Create default deny-all policy for production namespace
- ⬜ Create allow policies for required traffic:
  - ⬜ Frontend to backend
  - ⬜ Backend to database
  - ⬜ All pods to DNS
  - ⬜ Ingress to frontend
- ⬜ Test network policies
- ⬜ Monitor denied traffic in Hubble

---

## Phase 5: Demo Application (Week 7-9)

### Application Development
- ⬜ Design application architecture (Vulnerability Scanner Platform):
  - ⬜ React frontend
  - ⬜ Go/Python backend API
  - ⬜ PostgreSQL database
  - ⬜ Trivy scanner service
- ⬜ Create application repository in GitLab
- ⬜ Develop frontend:
  - ⬜ Basic UI
  - ⬜ Image upload/URL input
  - ⬜ Results display
  - ⬜ Dashboard with metrics
- ⬜ Develop backend:
  - ⬜ REST API endpoints
  - ⬜ Image scanning logic
  - ⬜ Database integration
  - ⬜ Authentication (optional)
- ⬜ Create Dockerfiles for each component
- ⬜ Test locally with docker-compose

### Kubernetes Manifests
- ⬜ Create K8s manifests for application:
  - ⬜ Frontend Deployment + Service
  - ⬜ Backend Deployment + Service
  - ⬜ PostgreSQL StatefulSet + Service
  - ⬜ Scanner Job/CronJob
  - ⬜ ConfigMaps for configuration
  - ⬜ Secrets (stored in Vault)
  - ⬜ PVCs for database
  - ⬜ Ingress for frontend
- ⬜ Create Helm chart (optional but recommended)
- ⬜ Add to GitOps repo: `apps/staging/vulnerability-scanner/`

### CI/CD Pipeline
- ⬜ Create `.gitlab-ci.yml` for application:
  - ⬜ **Build stage:**
    - ⬜ Build Docker images
    - ⬜ Tag with commit SHA and branch name
  - ⬜ **Test stage:**
    - ⬜ Run unit tests
    - ⬜ Run integration tests
    - ⬜ Code quality checks (SonarQube optional)
  - ⬜ **Security stage:**
    - ⬜ Scan images with Trivy
    - ⬜ Check for high/critical vulnerabilities
    - ⬜ Fail pipeline if critical issues found
  - ⬜ **Push stage:**
    - ⬜ Push images to Harbor registry
    - ⬜ Tag as `latest` for main branch
  - ⬜ **Deploy stage:**
    - ⬜ Update image tags in kubernetes repo
    - ⬜ Commit and push to trigger ArgoCD sync
    - ⬜ Or use ArgoCD Image Updater
- ⬜ Test complete CI/CD flow

### Staging Deployment
- ⬜ Deploy application to staging namespace via ArgoCD
- ⬜ Verify all pods are running
- ⬜ Test application functionality
- ⬜ Check logs in Grafana/Loki
- ⬜ Monitor metrics in Grafana

### Production Deployment
- ⬜ Create production manifests (copy from staging)
- ⬜ Configure production-specific settings:
  - ⬜ Higher resource limits
  - ⬜ Multiple replicas (HA)
  - ⬜ PodDisruptionBudget
  - ⬜ HorizontalPodAutoscaler
  - ⬜ Resource quotas
- ⬜ Deploy to production namespace via ArgoCD
- ⬜ Configure manual approval in ArgoCD
- ⬜ Test production deployment
- ⬜ Configure monitoring alerts for application

### Application Observability
- ⬜ Instrument application with Prometheus metrics
- ⬜ Create custom Grafana dashboard for application:
  - ⬜ Request rate
  - ⬜ Error rate
  - ⬜ Response time
  - ⬜ Scans completed
  - ⬜ Vulnerabilities found (by severity)
- ⬜ Configure structured logging
- ⬜ Test log queries in Loki
- ⬜ Set up application-specific alerts

---

## Phase 6: Edge Cluster (Raspberry Pi) (Week 9-10)

### Raspberry Pi Setup
- ⬜ Install Ubuntu Server on all 3 Raspberry Pis
- ⬜ Configure static IP addresses
- ⬜ Configure SSH access
- ⬜ Update and upgrade packages
- ⬜ Configure hostnames (edge-01, edge-02, edge-03)

### K3s Installation
- ⬜ Create Ansible inventory: `inventory/edge-cluster.yml`
- ⬜ Create Ansible playbook: `playbooks/k3s-bootstrap.yml`
- ⬜ Install K3s on first Pi (server node)
- ⬜ Join remaining Pis as agents
- ⬜ Copy kubeconfig to Mac (`~/.kube/edge-config`)
- ⬜ Test kubectl access to edge cluster

### Edge Cluster Services
- ⬜ Install Traefik (comes with K3s)
- ⬜ Deploy MetalLB (if needed)
- ⬜ Deploy monitoring agents:
  - ⬜ Prometheus node exporter
  - ⬜ Promtail for logs
- ⬜ Configure Prometheus on management cluster to scrape edge cluster

### Multi-Cluster Management
- ⬜ Add edge cluster to ArgoCD
- ⬜ Create ArgoCD ApplicationSet for edge cluster
- ⬜ Deploy edge applications:
  - ⬜ Lightweight monitoring dashboard
  - ⬜ IoT data simulator (optional)
  - ⬜ Edge workload demo
- ⬜ Test multi-cluster deployment via ArgoCD

---

## Phase 7: Security Hardening (Week 10-11)

### Kubernetes Security
- ⬜ Enable Pod Security Standards:
  - ⬜ Set baseline policy for most namespaces
  - ⬜ Set restricted policy for production
- ⬜ Implement RBAC:
  - ⬜ Create developer role (limited access)
  - ⬜ Create admin role (full access)
  - ⬜ Create CI/CD service account
  - ⬜ Remove default service account permissions
- ⬜ Configure admission controllers:
  - ⬜ PodSecurityPolicy (deprecated) or Pod Security admission
  - ⬜ ResourceQuota
  - ⬜ LimitRanger
- ⬜ Implement OPA or Kyverno policies:
  - ⬜ Require resource limits
  - ⬜ Require non-root containers
  - ⬜ Require read-only root filesystem
  - ⬜ Block privileged containers
  - ⬜ Require specific image registries

### Network Security
- ⬜ Review and tighten network policies
- ⬜ Enable Cilium encryption (WireGuard or IPSec)
- ⬜ Configure firewall rules on Proxmox/VMs
- ⬜ Set up VLANs for cluster isolation (optional)
- ⬜ Implement zero-trust networking principles

### Secrets Management
- ⬜ Audit all secrets in Kubernetes
- ⬜ Migrate hard-coded secrets to Vault
- ⬜ Implement secret rotation for:
  - ⬜ Database passwords
  - ⬜ API tokens
  - ⬜ TLS certificates (automated via cert-manager)
- ⬜ Configure Vault auto-unseal (optional, advanced)

### Image Security
- ⬜ Configure Harbor to block images with critical vulnerabilities
- ⬜ Implement image signing with Cosign (optional)
- ⬜ Configure image pull policies (always pull from Harbor)
- ⬜ Regular vulnerability scanning in CI/CD

### Compliance & Auditing
- ⬜ Enable Kubernetes audit logging
- ⬜ Ship audit logs to Loki
- ⬜ Create dashboards for security events
- ⬜ Install Falco for runtime security monitoring (optional)
- ⬜ Run CIS Kubernetes Benchmark (kube-bench)
- ⬜ Fix identified issues

---

## Phase 8: Backup & Disaster Recovery (Week 11-12)

### Backup Strategy Implementation
- ⬜ Configure Vault backups:
  - ⬜ Create backup script
  - ⬜ Encrypt backups
  - ⬜ Store in MinIO
  - ⬜ Set up cron job (daily)
  - ⬜ Test restore procedure
- ⬜ Configure GitLab backups:
  - ⬜ Use gitlab-rake backup
  - ⬜ Store in MinIO
  - ⬜ Set up cron job (daily)
  - ⬜ Test restore procedure
- ⬜ Configure Longhorn backups:
  - ⬜ Verify RecurringJob is running
  - ⬜ Test manual backup
  - ⬜ Test restore from backup
- ⬜ Configure etcd backups:
  - ⬜ Create backup script
  - ⬜ Store in MinIO
  - ⬜ Set up cron job (daily)
  - ⬜ Test restore procedure
- ⬜ Off-site backup:
  - ⬜ Configure rclone to Backblaze B2 or AWS S3
  - ⬜ Sync MinIO buckets to cloud storage
  - ⬜ Set up weekly sync

### Disaster Recovery Testing
- ⬜ Document recovery procedures in runbooks
- ⬜ Test Scenario 1: Single node failure
  - ⬜ Shutdown one worker node
  - ⬜ Verify pods reschedule
  - ⬜ Verify services remain available
  - ⬜ Bring node back online
- ⬜ Test Scenario 2: Complete cluster rebuild
  - ⬜ Destroy management cluster (in test environment or carefully)
  - ⬜ Rebuild from Terraform/Ansible
  - ⬜ Restore Vault
  - ⬜ Restore GitLab
  - ⬜ Deploy ArgoCD
  - ⬜ Let GitOps rebuild everything else
  - ⬜ Verify applications work
  - ⬜ Document time taken (RTO)
- ⬜ Test Scenario 3: Data recovery
  - ⬜ Delete a PVC
  - ⬜ Restore from Longhorn backup
  - ⬜ Verify data integrity
- ⬜ Create disaster recovery plan document

---

## Phase 9: Documentation & Portfolio (Week 12+)

### Technical Documentation
- ⬜ Write architecture overview document
- ⬜ Create network topology diagram
- ⬜ Create Kubernetes architecture diagram
- ⬜ Create CI/CD pipeline diagram
- ⬜ Create GitOps workflow diagram
- ⬜ Write runbooks:
  - ⬜ Deploying a new application
  - ⬜ Scaling applications
  - ⬜ Troubleshooting pod issues
  - ⬜ Certificate renewal
  - ⬜ Adding a new node
  - ⬜ Disaster recovery procedures
  - ⬜ Common issues and solutions
- ⬜ Document all passwords/secrets locations
- ⬜ Create operational procedures document

### GitHub Repository
- ⬜ Clean up repository structure
- ⬜ Write comprehensive README.md
- ⬜ Add LICENSE file
- ⬜ Add CONTRIBUTING.md (if open source)
- ⬜ Add architecture diagrams to repo
- ⬜ Add screenshots of:
  - ⬜ ArgoCD UI showing applications
  - ⬜ Grafana dashboards
  - ⬜ Harbor registry
  - ⬜ Application UI
  - ⬜ Hubble network flows
- ⬜ Create demo video/GIF of GitOps deployment
- ⬜ Tag stable release (v1.0.0)

### Blog Posts
- ⬜ Write blog post 1: "Building a Production-Grade Kubernetes Homelab"
  - ⬜ Overview and architecture
  - ⬜ Hardware and tools used
  - ⬜ Key learnings
  - ⬜ Publish on mathiaswouters.com
- ⬜ Write blog post 2: "GitOps with ArgoCD: Lessons Learned"
  - ⬜ What is GitOps
  - ⬜ ArgoCD setup and configuration
  - ⬜ Best practices
  - ⬜ Publish on mathiaswouters.com
- ⬜ Write blog post 3: "Cilium eBPF Networking Deep Dive"
  - ⬜ Why Cilium over other CNIs
  - ⬜ eBPF benefits
  - ⬜ Hubble observability
  - ⬜ Publish on mathiaswouters.com
- ⬜ Write blog post 4: "Kubernetes Security Best Practices in a Homelab"
  - ⬜ Network policies
  - ⬜ Secrets management with Vault
  - ⬜ Image scanning
  - ⬜ RBAC implementation
  - ⬜ Publish on mathiaswouters.com

### Portfolio Website Updates
- ⬜ Add homelab project to portfolio
- ⬜ Create dedicated page for homelab:
  - ⬜ Project overview
  - ⬜ Architecture diagrams
  - ⬜ Technologies used
  - ⬜ Live demo links (if publicly accessible)
  - ⬜ GitHub repository link
  - ⬜ Blog posts links
- ⬜ Add to projects section on homepage
- ⬜ Update resume with homelab project

### Social Media & Networking
- ⬜ Share project on LinkedIn
- ⬜ Post in r/homelab
- ⬜ Post in r/kubernetes
- ⬜ Share on relevant Discord servers
- ⬜ Create Twitter/X thread about the build
- ⬜ Engage with comments and feedback

---

## Phase 10: Advanced Features (Optional - After Week 12)

### Service Mesh
- ⬜ Research: Istio vs Linkerd vs Cilium Service Mesh
- ⬜ Choose service mesh
- ⬜ Install service mesh
- ⬜ Configure mTLS between services
- ⬜ Implement traffic management (canary deployments)
- ⬜ Configure circuit breakers and retries
- ⬜ Add service mesh observability to Grafana

### Chaos Engineering
- ⬜ Install Chaos Mesh
- ⬜ Create chaos experiments:
  - ⬜ Pod failure experiment
  - ⬜ Network delay experiment
  - ⬜ Stress test experiment
- ⬜ Run experiments in staging
- ⬜ Document results and improvements

### Advanced Monitoring
- ⬜ Install Thanos for long-term Prometheus storage
- ⬜ Configure distributed tracing with Jaeger
- ⬜ Implement APM (Application Performance Monitoring)
- ⬜ Create SLI/SLO dashboards

### GitOps Enhancements
- ⬜ Implement progressive delivery with Flagger
- ⬜ Configure automated canary deployments
- ⬜ Set up blue/green deployments
- ⬜ Implement automated rollbacks on failure

### Multi-Region Setup
- ⬜ Set up second Proxmox node (or use cloud)
- ⬜ Configure cluster federation
- ⬜ Implement cross-region replication
- ⬜ Test disaster recovery across regions

---

## Ongoing Maintenance Tasks

### Daily
- ⬜ Check cluster health (`kubectl get nodes`)
- ⬜ Review Grafana dashboards for anomalies
- ⬜ Check ArgoCD sync status
- ⬜ Review alerts in Alertmanager

### Weekly
- ⬜ Review logs for errors
- ⬜ Check resource utilization (RAM, CPU, disk)
- ⬜ Update container images (renovate bot setup - optional)
- ⬜ Review Harbor vulnerability scans
- ⬜ Check backup success

### Monthly
- ⬜ Update Kubernetes cluster (minor version)
- ⬜ Update all Helm charts
- ⬜ Review and clean up unused images in Harbor
- ⬜ Review and optimize resource requests/limits
- ⬜ Test disaster recovery procedures
- ⬜ Audit RBAC permissions
- ⬜ Review and update documentation

### Quarterly
- ⬜ Major Kubernetes version upgrade
- ⬜ Hardware maintenance check
- ⬜ Full security audit
- ⬜ Update blog with new learnings
- ⬜ Evaluate new technologies to integrate

---

## Interview Preparation

### Technical Deep Dives
- ⬜ Prepare to explain architecture decisions
- ⬜ Practice walking through CI/CD pipeline
- ⬜ Be ready to discuss disaster recovery strategy
- ⬜ Prepare to explain GitOps benefits
- ⬜ Be ready to discuss security implementations
- ⬜ Practice troubleshooting scenarios

### Demo Preparation
- ⬜ Create demo script for live presentation
- ⬜ Record video walkthrough (5-10 minutes)
- ⬜ Prepare to show:
  - ⬜ Git commit triggering deployment
  - ⬜ ArgoCD auto-sync in action
  - ⬜ Application scaling
  - ⬜ Monitoring dashboards
  - ⬜ Log queries
  - ⬜ Network policies in action
  - ⬜ Disaster recovery (if time permits)

### Questions to Prepare For
- ⬜ Why did you choose [technology X] over [technology Y]?
- ⬜ How do you handle secrets management?
- ⬜ What's your disaster recovery strategy?
- ⬜ How do you ensure high availability?
- ⬜ Walk me through your CI/CD pipeline
- ⬜ How do you monitor your applications?
- ⬜ What challenges did you face and how did you solve them?
- ⬜ How would you scale this to production?

---

## Success Criteria

### Technical Goals
- ✅ Multi-cluster Kubernetes running smoothly
- ✅ GitOps fully implemented (all changes via Git)
- ✅ CI/CD pipeline fully automated
- ✅ Comprehensive monitoring and alerting
- ✅ Disaster recovery tested and documented
- ✅ Security best practices implemented
- ✅ Demo application running in production

### Portfolio Goals
- ✅ Professional GitHub repository
- ✅ Live demo accessible online
- ✅ Technical blog posts published
- ✅ Portfolio website updated
- ✅ Architecture diagrams created
- ✅ Comprehensive documentation

### Career Goals
- ✅ Ready to discuss project in interviews
- ✅ Demonstrates Cloud/DevOps/Platform Engineering skills
- ✅ Shows initiative and passion for technology
- ✅ Provides conversation starters for interviews
- ✅ Differentiates from other candidates

---

**Progress Tracking:**
- Total Tasks: ~300+
- Completed: 4
- In Progress: 0
- Remaining: ~296

**Current Phase:** Phase 0 - Preparation & Setup

**Next Milestone:** Complete Phase 1 (Infrastructure VMs) by end of Week 2

**Last Updated:** [Current Date]