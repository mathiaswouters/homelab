# Homelab Detailed Explanation & Implementation Guide

## Table of Contents
- [Architecture Overview](#architecture-overview)
- [Hardware Setup](#hardware-setup)
- [Network Design](#network-design)
- [Bootstrap Strategy](#bootstrap-strategy)
- [Cluster Architecture](#cluster-architecture)
- [Service Deployment Order](#service-deployment-order)
- [Storage Strategy](#storage-strategy)
- [GitOps Workflow](#gitops-workflow)
- [Security Implementation](#security-implementation)
- [Monitoring & Observability](#monitoring--observability)
- [Disaster Recovery](#disaster-recovery)

---

## Architecture Overview

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        Proxmox Host                         │
│                   HP Z440 (12 cores, 96GB RAM)              │
│                                                             |
│  ┌──────────────────┐  ┌──────────────────────────────┐     │
│  │  Infrastructure  │  │     Kubernetes Clusters      │     │
│  │      VMs         │  │                              │     │
│  │                  │  │  ┌────────────────────────┐  │     │
│  │ • GitLab (8GB)   │  │  │  Management Cluster    │  │     │
│  │ • Vault (2GB)    │  │  │  • 1 Control Plane     │  │     │
│  │ • Bastion (2GB)  │  │  │  • 2 Workers (8GB ea)  │  │     │
│  │ • MinIO (4GB)    │  │  │                        │  │     │
│  │                  │  │  │  Platform Services:    │  │     │
│  └──────────────────┘  │  │  • ArgoCD              │  │     │
│                        │  │  • Harbor              │  │     │
│                        │  │  • Monitoring          │  │     │
│                        │  │  • GitLab Runners      │  │     │
│                        │  └────────────────────────┘  │     │
│                        │                              │     │
│                        │  ┌────────────────────────┐  │     │
│                        │  │  Production Cluster    │  │     │
│                        │  │  • 3 Control Planes    │  │     │
│                        │  │  • 3 Workers (12GB ea) │  │     │
│                        │  │                        │  │     │
│                        │  │  Application Workloads │  │     │
│                        │  └────────────────────────┘  │     │
│                        └──────────────────────────────┘     │
└─────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────┐
│      External Infrastructure         │
│                                      │
│  • 3x Raspberry Pi (Edge Cluster)    │
│  • Cloudflare (DNS + Tunnels)        │
│  • Domain: mathiaswouters.com        │
└──────────────────────────────────────┘
```

### Why This Architecture?

**Separated Management & Production Clusters:**
- **Industry Standard:** Mimics how enterprises use AKS/EKS with separate platform clusters
- **Security Isolation:** Platform tools separated from application workloads
- **Blast Radius:** Issues in production apps don't affect CI/CD or monitoring
- **Resource Management:** Different scaling and HA requirements

**Services Outside K8s (VMs):**
- **GitLab:** Resource-intensive, database-heavy (better on VM)
- **Vault:** Bootstrap problem (can't store secrets for the thing that stores secrets)
- **Bastion:** Security boundary, always accessible even if K8s is down

---

## Hardware Setup

### Proxmox Host: HP Z440
- **CPU:** 12 cores (Xeon E5 series)
- **RAM:** 96GB DDR4 ECC
- **Storage:**
  - **Boot/OS:** Built-in storage
  - **VM Storage:** 4TB LVM thin pool (2x 2TB disks)
  - **Longhorn:** Separate virtual disks per worker node

### Storage Layout
```
Proxmox Storage:
├── local (OS/ISOs)
├── local-lvm (VM root disks)
└── longhorn-pool (4TB LVM thin)
    └── Dedicated disks for Longhorn per worker
```

### Network Equipment
- Pi-hole running in LXC container (DNS + Ad-blocking)
- Home router with VLAN support (optional but recommended)

### Raspberry Pi Cluster
- 3x Raspberry Pi 4 (4GB or 8GB RAM recommended)
- microSD cards or USB SSDs for better performance
- PoE HATs or individual power supplies

---

## Network Design

### Network Topology

```
Home Network: 192.168.1.0/24
├── Gateway: 192.168.1.1
├── Pi-hole: 192.168.1.2
├── Proxmox: 192.168.1.10
│
├── Infrastructure VMs
│   ├── GitLab: 192.168.1.25
│   ├── Vault: 192.168.1.26
│   ├── Bastion: 192.168.1.20
│   └── MinIO: 192.168.1.27
│
├── Management Cluster
│   ├── mgmt-cp-01: 192.168.1.30
│   ├── mgmt-worker-01: 192.168.1.31
│   └── mgmt-worker-02: 192.168.1.32
│
├── Production Cluster
│   ├── prod-cp-01: 192.168.1.40
│   ├── prod-cp-02: 192.168.1.41
│   ├── prod-cp-03: 192.168.1.42
│   ├── prod-worker-01: 192.168.1.43
│   ├── prod-worker-02: 192.168.1.44
│   └── prod-worker-03: 192.168.1.45
│
├── MetalLB IP Pool: 192.168.1.100-192.168.1.150
└── Raspberry Pi Cluster: 192.168.1.60-62
```

### DNS Strategy

**Pi-hole as Primary DNS:**
- All devices point to Pi-hole (192.168.1.2)
- Pi-hole forwards to upstream DNS (1.1.1.1, 8.8.8.8)
- Local DNS records for internal services

**External-DNS Integration:**
- K8s operator automatically updates Pi-hole with service records
- Creates A/CNAME records for ingress resources
- Example: Deploy app → automatic DNS entry

**Domain Structure:**
```
mathiaswouters.com
├── www.mathiaswouters.com → Portfolio (Cloudflare Pages)
├── gitlab.mathiaswouters.com → GitLab (Cloudflare Tunnel)
├── argocd.mathiaswouters.com → ArgoCD UI
├── grafana.mathiaswouters.com → Grafana
├── harbor.mathiaswouters.com → Harbor Registry
├── vault.mathiaswouters.com → Vault UI
└── *.k8s.mathiaswouters.com → K8s applications
```

### Cloudflare Integration

**Why Cloudflare Tunnel?**
- ✅ No port forwarding required
- ✅ No exposing home IP address
- ✅ DDoS protection
- ✅ Automatic HTTPS
- ✅ Zero Trust access controls

**Setup:**
```bash
# Install cloudflared in a VM or K8s
cloudflared tunnel create homelab
cloudflared tunnel route dns homelab gitlab.mathiaswouters.com
cloudflared tunnel run homelab
```

---

## Bootstrap Strategy

### The Chicken-and-Egg Problem

You need GitLab to run CI/CD, but you need CI/CD to deploy GitLab. Solution: Bootstrap from your Mac.

### Bootstrap Phases

#### Phase 0: Preparation (Mac)

**Install Required Tools:**
```bash
# macOS
brew install terraform ansible kubectl helm git

# Verify installations
terraform version
ansible --version
kubectl version --client
```

**Clone Repository:**
```bash
mkdir -p ~/homelab
cd ~/homelab
git init
git remote add origin git@github.com:yourusername/homelab.git
```

#### Phase 1: Manual Deployment (From Mac)

**What Gets Deployed Manually:**
1. Infrastructure VMs (GitLab, Vault, Bastion, MinIO)
2. Management Cluster VMs
3. Management Cluster K8s installation
4. Cilium CNI
5. ArgoCD

**Commands:**
```bash
# 1. Deploy Infrastructure VMs
cd terraform/infrastructure-vms
terraform init
terraform plan
terraform apply

# 2. Configure VMs with Ansible
cd ../../ansible
ansible-playbook -i inventory/bootstrap.yml playbooks/configure-vms.yml

# 3. Install GitLab
ansible-playbook -i inventory/bootstrap.yml playbooks/gitlab-install.yml

# 4. Deploy Management Cluster VMs
cd ../terraform/management-cluster
terraform init
terraform apply

# 5. Bootstrap K8s on Management Cluster
cd ../../ansible
ansible-playbook -i inventory/mgmt-cluster.yml playbooks/k8s-bootstrap.yml

# 6. Install Cilium
kubectl apply -f ../kubernetes/bootstrap/cilium/

# 7. Install ArgoCD
kubectl apply -k ../kubernetes/bootstrap/argocd/
```

#### Phase 2: GitOps Takes Over

**Push Code to GitLab:**
```bash
# Configure GitLab remote
git remote add gitlab git@gitlab.mathiaswouters.com:homelab/infrastructure.git
git push gitlab main

# Create additional repos
git@gitlab.mathiaswouters.com:homelab/kubernetes.git
git@gitlab.mathiaswouters.com:homelab/applications.git
```

**ArgoCD App-of-Apps Pattern:**
```yaml
# Creates parent app that deploys all other apps
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: platform-services
  namespace: argocd
spec:
  project: default
  source:
    repoURL: git@gitlab.mathiaswouters.com:homelab/kubernetes.git
    path: platform/
    targetRevision: main
  destination:
    server: https://kubernetes.default.svc
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

**From This Point Forward:**
- All changes via Git commits
- ArgoCD automatically syncs
- GitLab CI runs Terraform/Ansible for infrastructure changes

---

## Cluster Architecture

### Management Cluster Specs

**Purpose:** Run platform services that manage and monitor other clusters

**Size:**
- 1 Control Plane: 4GB RAM, 2 vCPU
- 2 Workers: 8GB RAM, 4 vCPU each
- Total: 20GB RAM

**What Runs Here:**
- ArgoCD (manages all clusters)
- Harbor (container registry with vulnerability scanning)
- GitLab Runners (K8s executors)
- Prometheus + Grafana + Loki (central monitoring)
- cert-manager
- External-DNS
- Platform tools and operators

**K8s Distribution:** K3s (lightweight) or RKE2 (more features, closer to upstream K8s)

### Production Cluster Specs

**Purpose:** Run application workloads with high availability

**Size:**
- 3 Control Planes: 4GB RAM, 2 vCPU each (HA setup)
- 3 Workers: 12GB RAM, 4 vCPU each
- Total: 48GB RAM

**What Runs Here:**
- Application workloads
- Staging namespace
- Production namespace
- Monitoring agents (Prometheus exporters, Promtail)

**High Availability:**
- 3 control planes (can tolerate 1 failure)
- 3 workers (can tolerate 1 failure with proper pod distribution)
- PodDisruptionBudgets for critical apps
- Anti-affinity rules to spread pods across nodes

**K8s Distribution:** RKE2 or Kubeadm (more production-like than K3s)

### Edge Cluster (Raspberry Pi)

**Purpose:** Demonstrate edge computing and multi-cluster management

**Size:**
- 3 Raspberry Pi 4 (8GB recommended)
- K3s (perfect for ARM/low-resource)

**What Runs Here:**
- Lightweight monitoring agents
- Edge workloads (IoT simulators, data collectors)
- Demo of edge-to-cloud architecture

**Managed By:** ArgoCD running in Management Cluster

---

## Service Deployment Order

### Critical: Order Matters!

Some services depend on others. Deploy in this sequence:

#### Layer 1: Networking (First!)
```
1. Cilium CNI
   ↓
2. MetalLB (needs CNI to be ready)
   ↓
3. Traefik Ingress Controller
```

**Why This Order:**
- Cilium provides pod networking (nothing works without it)
- MetalLB needs CNI to assign IPs to LoadBalancer services
- Traefik needs MetalLB to get an external IP

#### Layer 2: Storage & Security
```
4. Longhorn (distributed storage)
   ↓
5. cert-manager (TLS certificates)
   ↓
6. Sealed Secrets or Vault integration
```

**Why This Order:**
- Many services need persistent storage
- TLS should be ready before exposing services
- Secrets management needed before storing credentials

#### Layer 3: Platform Services
```
7. Harbor (container registry)
   ↓
8. External-DNS
   ↓
9. GitLab Runners (in K8s)
```

#### Layer 4: Observability
```
10. Prometheus + Grafana
    ↓
11. Loki + Promtail
    ↓
12. Hubble (Cilium observability)
```

**These can run in parallel once storage/networking is ready**

#### Layer 5: Applications
```
13. Your demo applications
```

### ArgoCD Application Dependencies

```yaml
# Example: Traefik depends on MetalLB
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: traefik
spec:
  # ...
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
  # Wait for MetalLB to be ready
  info:
    - name: depends-on
      value: metallb
```

---

## Storage Strategy

### Longhorn Configuration

**Why Longhorn:**
- ✅ Cloud-native distributed block storage
- ✅ Built for Kubernetes
- ✅ Automatic replication
- ✅ Snapshots and backups
- ✅ Web UI for management

**Architecture:**
```
Each Worker Node:
├── OS Disk (50GB)
│   └── Root filesystem, container images
└── Longhorn Disk (200-400GB from 4TB pool)
    └── Persistent volumes for pods
```

**Terraform Configuration:**
```hcl
resource "proxmox_vm_qemu" "prod_worker" {
  count = 3
  
  # OS disk
  disk {
    type    = "scsi"
    storage = "local-lvm"
    size    = "50G"
  }
  
  # Longhorn disk
  disk {
    type    = "scsi"
    storage = "longhorn-pool"  # 4TB LVM thin
    size    = "300G"
  }
}
```

**Longhorn Settings:**
```yaml
# Deploy via Helm
helm install longhorn longhorn/longhorn \
  --namespace longhorn-system \
  --create-namespace \
  --set defaultSettings.replicaCount=2 \
  --set defaultSettings.defaultDataPath=/mnt/longhorn
```

**Prepare Nodes with Ansible:**
```yaml
# Format and mount Longhorn disks
- name: Format Longhorn disk
  filesystem:
    fstype: ext4
    dev: /dev/sdb
    
- name: Mount Longhorn disk
  mount:
    path: /mnt/longhorn
    src: /dev/sdb
    fstype: ext4
    state: mounted
```

### Storage Classes

```yaml
# Fast storage (SSD-backed)
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: longhorn-fast
provisioner: driver.longhorn.io
parameters:
  numberOfReplicas: "2"
  staleReplicaTimeout: "30"
reclaimPolicy: Retain

---
# Standard storage
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: longhorn
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: driver.longhorn.io
parameters:
  numberOfReplicas: "2"
reclaimPolicy: Delete
```

### Backup Strategy

**Longhorn Backups to MinIO:**
```yaml
# Configure backup target
apiVersion: longhorn.io/v1beta2
kind: Setting
metadata:
  name: backup-target
  namespace: longhorn-system
spec:
  value: s3://longhorn-backups@minio/
  
---
# Backup credentials
apiVersion: v1
kind: Secret
metadata:
  name: minio-secret
  namespace: longhorn-system
type: Opaque
data:
  AWS_ACCESS_KEY_ID: <base64>
  AWS_SECRET_ACCESS_KEY: <base64>
  AWS_ENDPOINTS: <base64>  # http://minio.example.com
```

**Scheduled Backups:**
```yaml
apiVersion: longhorn.io/v1beta2
kind: RecurringJob
metadata:
  name: backup-daily
  namespace: longhorn-system
spec:
  cron: "0 2 * * *"  # 2 AM daily
  task: backup
  groups:
    - default
  retain: 7
  concurrency: 2
```

---

## GitOps Workflow

### Repository Structure

```
GitLab Organization: homelab/

Repository 1: infrastructure
├── terraform/
│   ├── infrastructure-vms/
│   │   ├── main.tf
│   │   ├── gitlab.tf
│   │   ├── vault.tf
│   │   └── variables.tf
│   ├── management-cluster/
│   │   ├── main.tf
│   │   ├── control-plane.tf
│   │   └── workers.tf
│   ├── production-cluster/
│   │   └── ...
│   └── modules/
│       └── proxmox-vm/
├── ansible/
│   ├── inventory/
│   │   ├── mgmt-cluster.yml
│   │   └── prod-cluster.yml
│   ├── playbooks/
│   │   ├── k8s-bootstrap.yml
│   │   ├── gitlab-install.yml
│   │   └── longhorn-prep.yml
│   └── roles/
│       ├── k8s-common/
│       └── cilium/
└── .gitlab-ci.yml

Repository 2: kubernetes
├── clusters/
│   ├── management/
│   │   ├── flux-system/  # or argocd-system
│   │   └── apps.yml
│   └── production/
│       └── apps.yml
├── platform/
│   ├── argocd/
│   ├── harbor/
│   │   ├── namespace.yml
│   │   ├── helmrelease.yml
│   │   └── ingress.yml
│   ├── monitoring/
│   │   ├── prometheus/
│   │   ├── grafana/
│   │   └── loki/
│   ├── networking/
│   │   ├── cilium/
│   │   ├── metallb/
│   │   └── traefik/
│   └── storage/
│       └── longhorn/
├── apps/
│   ├── staging/
│   └── production/
└── README.md

Repository 3: applications (demo apps)
├── vulnerability-scanner/
│   ├── frontend/
│   ├── backend/
│   ├── kubernetes/
│   └── .gitlab-ci.yml
└── portfolio-site/
```

### GitOps Flow

**For Infrastructure Changes (VMs, Network):**
```
1. Edit Terraform code locally
2. git commit && git push
3. GitLab CI runs:
   ├── terraform validate
   ├── terraform plan (on MR)
   └── terraform apply (on merge to main, manual approval)
4. Ansible playbook runs if needed
```

**For Kubernetes Resources:**
```
1. Edit YAML in kubernetes repo
2. git commit && git push
3. ArgoCD detects change
4. ArgoCD syncs to cluster automatically
5. View in ArgoCD UI
```

**For Applications:**
```
1. Code change in application repo
2. git commit && git push
3. GitLab CI pipeline:
   ├── Build Docker image
   ├── Scan with Trivy
   ├── Push to Harbor
   ├── Update image tag in kubernetes repo
4. ArgoCD detects new image tag
5. ArgoCD deploys to staging
6. Manual approval
7. ArgoCD deploys to production
```

### ArgoCD App-of-Apps Pattern

**Root Application:**
```yaml
# apps/root.yml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: root
  namespace: argocd
spec:
  project: default
  source:
    repoURL: git@gitlab.mathiaswouters.com:homelab/kubernetes.git
    targetRevision: main
    path: clusters/management
  destination:
    server: https://kubernetes.default.svc
    namespace: argocd
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

**Platform Services Application:**
```yaml
# clusters/management/apps.yml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: platform-services
  namespace: argocd
spec:
  project: default
  source:
    repoURL: git@gitlab.mathiaswouters.com:homelab/kubernetes.git
    targetRevision: main
    path: platform
  destination:
    server: https://kubernetes.default.svc
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

### GitLab CI Pipeline Example

```yaml
# .gitlab-ci.yml for infrastructure repo
stages:
  - validate
  - plan
  - apply

variables:
  TF_ROOT: ${CI_PROJECT_DIR}/terraform/production-cluster
  TF_STATE_NAME: production-cluster

terraform-validate:
  stage: validate
  image: hashicorp/terraform:latest
  script:
    - cd ${TF_ROOT}
    - terraform init -backend-config="address=${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/terraform/state/${TF_STATE_NAME}"
    - terraform validate
  only:
    - merge_requests
    - main

terraform-plan:
  stage: plan
  image: hashicorp/terraform:latest
  script:
    - cd ${TF_ROOT}
    - terraform init
    - terraform plan -out=plan.tfplan
  artifacts:
    paths:
      - ${TF_ROOT}/plan.tfplan
  only:
    - merge_requests

terraform-apply:
  stage: apply
  image: hashicorp/terraform:latest
  script:
    - cd ${TF_ROOT}
    - terraform init
    - terraform apply -auto-approve
  when: manual
  only:
    - main
```

---

## Security Implementation

### HashiCorp Vault Integration

**Why Run Vault on VM:**
- Bootstrap problem: Can't store K8s secrets in K8s
- Security isolation
- Vault needs to be available when K8s starts

**Vault Setup:**
```bash
# Initialize Vault (run once)
vault operator init -key-shares=5 -key-threshold=3

# Unseal Vault (after every restart)
vault operator unseal <key1>
vault operator unseal <key2>
vault operator unseal <key3>

# Enable Kubernetes auth
vault auth enable kubernetes
vault write auth/kubernetes/config \
    kubernetes_host="https://prod-cp-01:6443"
```

**Kubernetes Integration:**
```yaml
# Vault Agent Injector
apiVersion: v1
kind: ServiceAccount
metadata:
  name: vault-auth
  namespace: default
---
apiVersion: v1
kind: Secret
metadata:
  name: vault-auth-secret
  annotations:
    kubernetes.io/service-account.name: vault-auth
type: kubernetes.io/service-account-token
```

**Using Vault Secrets in Pods:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app
  annotations:
    vault.hashicorp.com/agent-inject: "true"
    vault.hashicorp.com/role: "app"
    vault.hashicorp.com/agent-inject-secret-db: "secret/data/db-creds"
spec:
  serviceAccountName: vault-auth
  containers:
  - name: app
    image: myapp:latest
    # Secrets injected at /vault/secrets/db
```

### TLS Certificate Management

**cert-manager with Let's Encrypt:**
```yaml
# ClusterIssuer for Let's Encrypt
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: your-email@mathiaswouters.com
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - dns01:
        cloudflare:
          email: your-email@mathiaswouters.com
          apiTokenSecretRef:
            name: cloudflare-api-token
            key: api-token
```

**Automatic Certificate for Ingress:**
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argocd
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
spec:
  tls:
  - hosts:
    - argocd.mathiaswouters.com
    secretName: argocd-tls
  rules:
  - host: argocd.mathiaswouters.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: argocd-server
            port:
              number: 80
```

### Network Policies with Cilium

**Default Deny All:**
```yaml
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: default-deny
  namespace: production
spec:
  endpointSelector: {}
  ingress:
  - {}
  egress:
  - {}
```

**Allow Specific Traffic:**
```yaml
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: allow-frontend-to-backend
  namespace: production
spec:
  endpointSelector:
    matchLabels:
      app: backend
  ingress:
  - fromEndpoints:
    - matchLabels:
        app: frontend
    toPorts:
    - ports:
      - port: "8080"
        protocol: TCP
```

### Image Scanning with Harbor & Trivy

**Harbor Configuration:**
- Enable Trivy scanner
- Set severity threshold (Critical, High)
- Prevent vulnerable images from being pulled

**GitLab CI Integration:**
```yaml
scan-image:
  stage: security
  image: aquasec/trivy:latest
  script:
    - trivy image --severity HIGH,CRITICAL ${CI_REGISTRY_IMAGE}:${CI_COMMIT_SHA}
  allow_failure: false
```

### RBAC (Role-Based Access Control)

**Namespace-level Access:**
```yaml
# Developer role - can manage apps in staging
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: developer
  namespace: staging
rules:
- apiGroups: ["", "apps", "batch"]
  resources: ["pods", "deployments", "jobs", "services"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: developer-binding
  namespace: staging
subjects:
- kind: User
  name: mathias
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: developer
  apiGroup: rbac.authorization.k8s.io
```

---

## Monitoring & Observability

### Prometheus Stack

**Deployed via Helm:**
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --set grafana.adminPassword=<secure-password>
```

**What Gets Monitored:**
- Node metrics (CPU, memory, disk, network)
- Pod metrics (resource usage, restart counts)
- K8s API server metrics
- Longhorn storage metrics
- Cilium network metrics
- Application metrics (custom exporters)

**ServiceMonitor Example:**
```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: longhorn
  namespace: monitoring
spec:
  selector:
    matchLabels:
      app: longhorn-manager
  endpoints:
  - port: manager
    path: /metrics
```

### Grafana Dashboards

**Import Community Dashboards:**
- Kubernetes Cluster Monitoring (ID: 7249)
- Node Exporter Full (ID: 1860)
- Cilium Metrics (ID: 16611)
- Longhorn Dashboard (ID: 13032)

**Custom Dashboard for Your App:**
```json
{
  "dashboard": {
    "title": "Vulnerability Scanner Metrics",
    "panels": [
      {
        "title": "Scan Rate",
        "targets": [
          {
            "expr": "rate(scans_total[5m])"
          }
        ]
      }
    ]
  }
}
```

### Loki for Logs

**Architecture:**
```
Promtail (DaemonSet) → Loki → Grafana
```

**Promtail Config:**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: promtail-config
  namespace: monitoring
data:
  promtail.yaml: |
    server:
      http_listen_port: 9080
    clients:
      - url: http://loki:3100/loki/api/v1/push
    scrape_configs:
      - job_name: kubernetes-pods
        kubernetes_sd_configs:
          - role: pod
        relabel_configs:
          - source_labels: [__meta_kubernetes_pod_name]
            target_label: pod
          - source_labels: [__meta_kubernetes_namespace]
            target_label: namespace
```

**Query Logs in Grafana:**
```logql
# All logs from production namespace
{namespace="production"}

# Error logs from specific app
{namespace="production", app="backend"} |= "error"

# Count errors per minute
rate({namespace="production"} |= "error" [1m])
```

### Hubble (Cilium Network Observability)

**Enable Hubble:**
```bash
cilium hubble enable --ui
```

**Access Hubble UI:**
```bash
cilium hubble ui
# Or via port-forward
kubectl port-forward -n kube-system svc/hubble-ui 12000:80
```

**Hubble CLI:**
```bash
# Watch network flows
hubble observe

# Filter by namespace
hubble observe --namespace production

# Filter by pod
hubble observe --from-pod production/frontend
```

### Alerting with Alertmanager

**Alert Rules:**
```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: homelab-alerts
  namespace: monitoring
spec:
  groups:
  - name: nodes
    interval: 30s
    rules:
    - alert: NodeDown
      expr: up{job="node-exporter"} == 0
      for: 5m
      labels:
        severity: critical
      annotations:
        summary: "Node {{ $labels.instance }} is down"
        
    - alert: HighMemoryUsage
      expr: (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) > 0.9
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "High memory usage on {{ $labels.instance }}"
        
    - alert: PodCrashLooping
      expr: rate(kube_pod_container_status_restarts_total[15m]) > 0
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "Pod {{ $labels.namespace }}/{{ $labels.pod }} is crash looping"
```

**Alertmanager Config:**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: alertmanager-config
  namespace: monitoring
data:
  alertmanager.yml: |
    global:
      resolve_timeout: 5m
    route:
      group_by: ['alertname', 'cluster']
      group_wait: 10s
      group_interval: 10s
      repeat_interval: 12h
      receiver: 'email'
    receivers:
    - name: 'email'
      email_configs:
      - to: 'alerts@mathiaswouters.com'
        from: 'alertmanager@mathiaswouters.com'
        smarthost: 'smtp.gmail.com:587'
        auth_username: 'your-email@gmail.com'
        auth_password: '<app-password>'
```

---

## Disaster Recovery

### Backup Strategy

**What to Backup:**
1. **Vault Data** - All secrets (CRITICAL)
2. **GitLab Data** - Repositories, CI/CD configs, users
3. **Longhorn Volumes** - Persistent data
4. **K8s etcd** - Cluster state (control plane data)
5. **Configuration** - Terraform state, Ansible vars

**Backup Locations:**
- Local: MinIO (S3-compatible object storage)
- Offsite: Backblaze B2, AWS S3, or external drive

### Vault Backup

**Automated Backup Script:**
```bash
#!/bin/bash
# backup-vault.sh
DATE=$(date +%Y%m%d-%H%M%S)
BACKUP_DIR="/backups/vault"

# Take Raft snapshot
vault operator raft snapshot save ${BACKUP_DIR}/vault-${DATE}.snap

# Encrypt backup
gpg --encrypt --recipient your-key ${BACKUP_DIR}/vault-${DATE}.snap

# Upload to MinIO
mc cp ${BACKUP_DIR}/vault-${DATE}.snap.gpg minio/backups/vault/

# Keep only last 30 days
find ${BACKUP_DIR} -name "vault-*.snap.gpg" -mtime +30 -delete
```

**Restore:**
```bash
# Download backup
mc cp minio/backups/vault/vault-20240115-020000.snap.gpg ./

# Decrypt
gpg --decrypt vault-20240115-020000.snap.gpg > vault.snap

# Restore
vault operator raft snapshot restore vault.snap
```

### GitLab Backup

**Automated GitLab Backup:**
```bash
# In GitLab VM
gitlab-backup create

# Copy to MinIO
gitlab-rake gitlab:backup:create BACKUP=<timestamp>
```

**Restore:**
```bash
# Stop services
gitlab-ctl stop puma
gitlab-ctl stop sidekiq

# Restore
gitlab-backup restore BACKUP=<timestamp>

# Restart
gitlab-ctl restart
```

### Longhorn Backup

**Automated via RecurringJob (configured earlier)**

**Manual Backup:**
```bash
# Create backup of specific volume
kubectl create -f - <<EOF
apiVersion: longhorn.io/v1beta2
kind: Backup
metadata:
  name: pvc-backup-$(date +%s)
  namespace: longhorn-system
spec:
  snapshotName: snapshot-$(date +%s)
  labels:
    backup-type: manual
EOF
```

**Restore:**
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: restored-pvc
  namespace: production
spec:
  storageClassName: longhorn
  dataSource:
    name: backup-pvc-20240115
    kind: Backup
    apiGroup: longhorn.io
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
```

### etcd Backup (K8s State)

**Automated Backup:**
```bash
#!/bin/bash
# backup-etcd.sh
ETCDCTL_API=3 etcdctl snapshot save /backups/etcd/etcd-$(date +%Y%m%d).db \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key

# Upload to MinIO
mc cp /backups/etcd/etcd-$(date +%Y%m%d).db minio/backups/etcd/
```

**Restore:**
```bash
# Stop K8s services
systemctl stop kubelet

# Restore snapshot
ETCDCTL_API=3 etcdctl snapshot restore etcd-20240115.db \
  --data-dir=/var/lib/etcd-restored

# Update etcd config to use new data-dir
# Restart services
systemctl start kubelet
```

### Complete Lab Rebuild

**Disaster Scenario: Complete hardware failure**

**Recovery Steps (from Mac):**

```bash
# 1. Reinstall Proxmox on new hardware (manual)

# 2. Restore infrastructure
cd ~/homelab/terraform/infrastructure-vms
terraform init
terraform apply

# 3. Restore Vault
ansible-playbook playbooks/vault-restore.yml

# 4. Restore GitLab
ansible-playbook playbooks/gitlab-restore.yml

# 5. Deploy clusters
cd ../management-cluster
terraform apply
cd ../production-cluster
terraform apply

# 6. Bootstrap K8s
cd ../../ansible
ansible-playbook playbooks/k8s-bootstrap.yml -i inventory/all.yml

# 7. Install ArgoCD
kubectl apply -k ../kubernetes/bootstrap/argocd/

# 8. ArgoCD syncs everything else from GitLab
# Wait for sync...

# 9. Restore Longhorn volumes
kubectl apply -f restore-pvcs.yml

# 10. Verify
kubectl get pods --all-namespaces
```

**Total Recovery Time:** ~2-3 hours

### Testing Disaster Recovery

**Monthly DR Test:**
1. Create test VM or use staging cluster
2. Run restore procedures
3. Verify all services come up
4. Document any issues
5. Update runbooks

**Quarterly Full Test:**
1. Destroy production cluster
2. Rebuild from backups
3. Verify all applications work
4. Measure RTO (Recovery Time Objective)

---

## Performance Tuning

### Proxmox Optimization

**CPU Pinning for K8s Nodes:**
```bash
# In Proxmox VM config
qm set <vmid> --cores 4 --vcpus 4
```

**Huge Pages:**
```bash
# On Proxmox host
echo "vm.nr_hugepages = 1024" >> /etc/sysctl.conf
sysctl -p
```

### Kubernetes Optimization

**Node Resources:**
```yaml
# Reserve resources for system daemons
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
systemReserved:
  cpu: 500m
  memory: 1Gi
kubeReserved:
  cpu: 500m
  memory: 1Gi
```

**Pod Resource Limits:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app
spec:
  containers:
  - name: app
    resources:
      requests:
        memory: "256Mi"
        cpu: "250m"
      limits:
        memory: "512Mi"
        cpu: "500m"
```

**Horizontal Pod Autoscaling:**
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: app
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

### Cilium Optimization

**Enable eBPF Host Routing:**
```yaml
# Faster networking
config:
  bpf-lb-mode: "dsr"
  tunnel: "disabled"
  enable-ipv4-masquerade: false
  enable-host-port: true
```

---

## Troubleshooting Guide

### Common Issues

**Issue: Pods stuck in Pending**
```bash
# Check node resources
kubectl describe nodes

# Check PVC status
kubectl get pvc --all-namespaces

# Check events
kubectl get events --sort-by='.lastTimestamp'
```

**Issue: Longhorn volumes not attaching**
```bash
# Check Longhorn manager logs
kubectl logs -n longhorn-system -l app=longhorn-manager

# Check disk status
kubectl get nodes.longhorn.io -n longhorn-system -o yaml

# Verify disks are mounted
ansible -i inventory/prod.yml workers -m shell -a "df -h /mnt/longhorn"
```

**Issue: GitLab CI runners not picking up jobs**
```bash
# Check runner registration
kubectl get pods -n gitlab-runner

# Check runner logs
kubectl logs -n gitlab-runner <runner-pod>

# Re-register runner
gitlab-runner register \
  --url https://gitlab.mathiaswouters.com \
  --token <token>
```

**Issue: Certificate not issued**
```bash
# Check cert-manager logs
kubectl logs -n cert-manager deployment/cert-manager

# Check certificate status
kubectl describe certificate <cert-name>

# Check challenge
kubectl get challenges --all-namespaces
```

**Issue: ArgoCD sync fails**
```bash
# Check application status
kubectl get application -n argocd

# Describe application
kubectl describe application <app-name> -n argocd

# Check sync logs
argocd app logs <app-name>

# Manual sync
argocd app sync <app-name> --force
```

### Debugging Commands

```bash
# Pod debugging
kubectl debug -it <pod-name> --image=busybox

# Network debugging
kubectl run netshoot --rm -it --image=nicolaka/netshoot -- /bin/bash

# Check DNS
kubectl run dnsutils --rm -it --image=gcr.io/kubernetes-e2e-test-images/dnsutils:1.3 -- nslookup kubernetes.default

# Check Cilium connectivity
cilium connectivity test

# View Hubble flows
hubble observe --namespace production
```

---

## Future Enhancements

### Phase 2 (After Initial Build)

**Service Mesh:**
- Istio or Linkerd for advanced traffic management
- mTLS between services
- Circuit breaking, retries, timeouts

**Chaos Engineering:**
- Chaos Mesh for fault injection
- Test cluster resilience
- Automated chaos experiments

**Machine Learning Workloads:**
- KubeFlow for ML pipelines
- GPU passthrough to VMs
- ML model serving

**Advanced Monitoring:**
- Thanos for long-term Prometheus storage
- Distributed tracing with Jaeger
- APM with Elastic APM or Datadog

**Security Enhancements:**
- Falco for runtime security
- OPA/Kyverno for policy enforcement
- Network segmentation with Calico

### Phase 3 (Advanced)

**Multi-Region Setup:**
- Second Proxmox node (or cloud)
- K8s federation
- Cross-region replication

**Cost Optimization:**
- Resource utilization tracking
- Automated scale-down
- Spot instance simulation

**Advanced CI/CD:**
- Progressive delivery with Flagger
- Canary deployments
- Blue/green deployments

---

## Documentation & Portfolio

### What to Document

**Technical Blog Posts:**
1. "Building a Production-Grade Kubernetes Homelab"
2. "GitOps with ArgoCD: Lessons Learned"
3. "Cilium eBPF Networking Deep Dive"
4. "Disaster Recovery Testing in Kubernetes"

**Architecture Diagrams:**
- Network topology
- Cluster architecture
- CI/CD pipeline flow
- Monitoring architecture
- GitOps workflow

**Runbooks:**
- Common operational tasks
- Troubleshooting procedures
- Disaster recovery steps
- Onboarding new services

### Portfolio Presentation

**For Interviews:**
- Live demo of GitOps deployment
- Show Grafana dashboards
- Walk through CI/CD pipeline
- Demonstrate disaster recovery
- Explain architectural decisions

**GitHub README:**
- Architecture overview
- Technologies used
- Key features
- Live links (if publicly accessible)
- Screenshots/diagrams

---

## Timeline & Milestones

**Week 1-2: Foundation**
- [x] Proxmox setup
- [x] Pi-hole LXC
- [x] Cloud-init template
- [x] Terraform for VMs
- [ ] GitLab VM deployed
- [ ] Vault VM deployed
- [ ] Management cluster VMs

**Week 3-4: Core Services**
- [ ] Management cluster K8s
- [ ] ArgoCD deployed
- [ ] Cilium CNI
- [ ] MetalLB
- [ ] Longhorn
- [ ] cert-manager

**Week 5-6: Platform Services**
- [ ] Harbor registry
- [ ] Traefik ingress
- [ ] Prometheus + Grafana
- [ ] Loki + Promtail
- [ ] External-DNS

**Week 7-8: Production**
- [ ] Production cluster
- [ ] Demo application
- [ ] CI/CD pipeline
- [ ] Monitoring dashboards
- [ ] Documentation

**Week 9-12: Polish & Advanced**
- [ ] Raspberry Pi cluster
- [ ] Service mesh (optional)
- [ ] Advanced security
- [ ] Blog posts
- [ ] Portfolio updates

