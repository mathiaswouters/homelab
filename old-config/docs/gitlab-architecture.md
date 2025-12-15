# Homelab GitLab Repository Structure - Complete Reference

## Table of Contents
1. [Overview](#overview)
2. [GitLab Group Structure](#gitlab-group-structure)
3. [Repository Details by Category](#repository-details-by-category)
4. [CI/CD Integration Patterns](#cicd-integration-patterns)
5. [ArgoCD Integration](#argocd-integration)
6. [Deployment Workflows](#deployment-workflows)
7. [Security & Testing](#security--testing)
8. [Quick Reference Matrix](#quick-reference-matrix)

---

## Overview

This document maps your complete homelab infrastructure to a GitLab repository structure that follows enterprise best practices. The structure supports:

- ✅ Hybrid CI/CD (GitLab + ArgoCD + Jenkins)
- ✅ Multiple IaC tools (Terraform, Ansible, Chef)
- ✅ Comprehensive security scanning
- ✅ Separation of concerns (platform vs. applications)
- ✅ Scalability for learning and production use

### Architecture Principles

**Infrastructure Layer** (GitLab CI/CD):
- VM provisioning (Proxmox)
- Kubernetes cluster deployment
- Node configuration
- Base infrastructure services

**Application Layer** (ArgoCD):
- All Kubernetes workloads
- Service configurations
- Application deployments

**Testing & Security** (Integrated in both):
- Automated testing (Terratest, Molecule)
- Security scanning (Trivy, Checkov, etc.)
- Compliance checking

---

## GitLab Group Structure

```
homelab/
│
├── platform/ ─────────────────────────── Reusable Components (Library)
│   ├── terraform-modules/
│   ├── ansible-roles/
│   ├── chef-cookbooks/
│   ├── helm-charts/
│   ├── ci-templates/
│   └── opa-policies/
│
├── infrastructure/ ───────────────────── Infrastructure Deployments
│   ├── proxmox-vms/
│   ├── kubernetes-cluster/
│   ├── networking/
│   ├── dns/
│   ├── vpn/
│   └── backup-infrastructure/
│
├── kubernetes/ ───────────────────────── K8s Orchestration & Bootstrap
│   ├── argocd-bootstrap/
│   ├── argocd-apps/
│   ├── platform-services/
│   └── system-manifests/
│
├── core-services/ ────────────────────── Essential Platform Services
│   ├── networking/
│   │   ├── cilium/
│   │   ├── metallb/
│   │   ├── traefik/
│   │   ├── cert-manager/
│   │   ├── external-dns/
│   │   └── istio/
│   ├── storage/
│   │   ├── longhorn/
│   │   └── minio/
│   ├── secrets/
│   │   ├── vault/
│   │   ├── external-secrets-operator/
│   │   └── sealed-secrets/
│   └── registry/
│       ├── harbor/
│       └── jfrog-artifactory/
│
├── observability/ ────────────────────── Monitoring, Logging & SIEM
│   ├── monitoring/
│   │   ├── prometheus-stack/
│   │   ├── loki-stack/
│   │   └── netbox/
│   ├── siem/
│   │   └── wazuh/
│   └── dashboards/
│       └── grafana-dashboards/
│
├── security/ ─────────────────────────── Security Tools & Policies
│   ├── scanning/
│   │   ├── trivy/
│   │   ├── clair/
│   │   ├── grype/
│   │   ├── snyk/
│   │   └── dependency-track/
│   ├── runtime-security/
│   │   ├── falco/
│   │   ├── tetragon/
│   │   └── kubearmor/
│   ├── network-security/
│   │   ├── suricata/
│   │   ├── crowdsec/
│   │   └── modsecurity/
│   ├── policy-enforcement/
│   │   ├── opa/
│   │   ├── kyverno/
│   │   ├── kubescape/
│   │   └── polaris/
│   ├── access-control/
│   │   ├── teleport/
│   │   └── boundary/
│   └── pki/
│       ├── smallstep/
│       └── step-ca/
│
├── cicd/ ─────────────────────────────── CI/CD Infrastructure
│   ├── gitlab-runners/
│   ├── jenkins/
│   └── pipeline-libraries/
│
├── applications/ ─────────────────────── End-User Applications
│   ├── media/
│   │   ├── jellyfin/
│   │   ├── arr-stack/
│   │   ├── qbittorrent/
│   │   ├── tdarr/
│   │   ├── audiobookshelf/
│   │   └── calibre-web/
│   ├── productivity/
│   │   ├── nextcloud/
│   │   ├── n8n/
│   │   ├── vaultwarden/
│   │   └── homepage-dashboard/
│   ├── smart-home/
│   │   ├── home-assistant/
│   │   └── node-red/
│   ├── photos/
│   │   ├── immich/
│   │   └── photoprism/
│   ├── ai/
│   │   ├── ollama/
│   │   └── open-webui/
│   ├── utilities/
│   │   ├── shlink/
│   │   ├── littlelink/
│   │   └── pihole/
│   └── code-quality/
│       └── sonarqube/
│
├── backup/ ───────────────────────────── Backup & Disaster Recovery
│   ├── proxmox-backup-server/
│   ├── velero/
│   └── backup-scripts/
│
└── operations/ ───────────────────────── Operational Tools
    ├── scripts/
    ├── documentation/
    ├── testing/
    │   ├── terratest/
    │   ├── molecule/
    │   └── checkov/
    └── automation/
```

---

## Repository Details by Category

### 1. Platform Repositories (Reusable Components)

#### `platform/terraform-modules`
**Purpose:** Centralized Terraform modules for infrastructure provisioning

```
terraform-modules/
├── modules/
│   ├── proxmox-vm/              # Generic VM provisioning
│   ├── proxmox-k8s-node/        # K8s node-specific VM
│   ├── proxmox-lxc/             # LXC containers
│   ├── proxmox-storage/         # Storage configuration
│   └── networking/              # Network configuration
├── examples/
├── tests/                       # Terratest tests
├── .gitlab-ci.yml
└── README.md
```

**CI/CD:**
```yaml
stages:
  - validate
  - test
  - publish

validate:
  script:
    - terraform fmt -check
    - terraform validate
    - checkov -d .

test:
  script:
    - cd tests && go test -v
```

---

#### `platform/ansible-roles`
**Purpose:** Reusable Ansible roles for configuration management

```
ansible-roles/
├── roles/
│   ├── common/                  # Base configuration (users, SSH, etc.)
│   ├── docker/                  # Docker installation
│   ├── k8s-node/                # Kubernetes node setup
│   ├── monitoring-agent/        # Prometheus node exporter, etc.
│   ├── security-hardening/      # CIS benchmarks, fail2ban
│   ├── backup-agent/            # Backup client configuration
│   └── cilium-cni/              # Cilium CNI setup
├── molecule/                    # Molecule tests
├── .gitlab-ci.yml
└── README.md
```

**CI/CD:**
```yaml
stages:
  - lint
  - test

lint:
  script:
    - ansible-lint roles/

test:
  script:
    - molecule test
```

---

#### `platform/chef-cookbooks`
**Purpose:** Chef cookbooks (learning environment)

```
chef-cookbooks/
├── cookbooks/
│   ├── base-setup/
│   ├── web-server/
│   └── database/
├── .gitlab-ci.yml
└── README.md
```

---

#### `platform/helm-charts`
**Purpose:** Custom Helm charts library

```
helm-charts/
├── charts/
│   ├── generic-app/             # Reusable app template
│   ├── statefulset-app/         # For databases, etc.
│   ├── cronjob-app/             # Scheduled jobs
│   └── media-app/               # Media server template
├── .gitlab-ci.yml              # Package & push to Harbor
└── README.md
```

**CI/CD:**
```yaml
package:
  script:
    - helm package charts/*
    - helm push *.tgz oci://harbor.homelab.local/charts
```

---

#### `platform/ci-templates`
**Purpose:** Reusable GitLab CI/CD templates

```
ci-templates/
├── templates/
│   ├── terraform.yml            # Terraform workflow
│   ├── ansible.yml              # Ansible workflow
│   ├── helm.yml                 # Helm workflow
│   ├── security-scan.yml        # Security scanning
│   ├── docker-build.yml         # Container builds
│   └── argocd-sync.yml          # ArgoCD integration
├── scripts/
└── README.md
```

**Usage in other repos:**
```yaml
include:
  - project: 'homelab/platform/ci-templates'
    file: 'templates/terraform.yml'
```

---

#### `platform/opa-policies`
**Purpose:** Open Policy Agent policies

```
opa-policies/
├── policies/
│   ├── kubernetes/              # K8s admission policies
│   ├── terraform/               # Terraform policies
│   └── docker/                  # Container policies
├── tests/
├── .gitlab-ci.yml
└── README.md
```

---

### 2. Infrastructure Repositories

#### `infrastructure/proxmox-vms`
**Purpose:** General VM infrastructure (non-K8s VMs)

```
proxmox-vms/
├── terraform/
│   ├── environments/
│   │   ├── pihole/
│   │   ├── gitlab-runner/
│   │   ├── jenkins/
│   │   ├── netbox/
│   │   └── backup-server/
│   └── main.tf
├── ansible/
│   ├── requirements.yml         # References platform/ansible-roles
│   └── playbooks/
│       ├── configure-pihole.yml
│       └── configure-jenkins.yml
├── .gitlab-ci.yml
└── README.md
```

**Workflow:** Terraform → Provision VMs → Ansible → Configure VMs

---

#### `infrastructure/kubernetes-cluster`
**Purpose:** Kubernetes cluster deployment (control plane + worker nodes)

```
kubernetes-cluster/
├── terraform/
│   ├── control-plane/
│   ├── worker-nodes/
│   └── variables.tf
├── ansible/
│   ├── requirements.yml
│   └── playbooks/
│       ├── bootstrap-cluster.yml
│       ├── install-cilium.yml
│       └── configure-nodes.yml
├── .gitlab-ci.yml
└── README.md
```

**Deployment Order:**
1. Terraform provisions VMs
2. Ansible configures nodes
3. Ansible bootstraps K8s cluster with kubeadm
4. Ansible installs Cilium CNI
5. Outputs kubeconfig for ArgoCD

---

#### `infrastructure/networking`
**Purpose:** Network infrastructure (VLANs, firewall rules, SDN)

```
networking/
├── terraform/
│   ├── vlans/
│   ├── firewall-rules/
│   └── dns-zones/
├── .gitlab-ci.yml
└── README.md
```

---

#### `infrastructure/dns`
**Purpose:** Pi-Hole DNS configuration

```
dns/
├── terraform/                   # Deploy Pi-Hole VM
├── ansible/
│   └── playbooks/
│       └── configure-pihole.yml
├── configs/
│   ├── adlists.txt
│   └── custom-dns.conf
├── .gitlab-ci.yml
└── README.md
```

---

#### `infrastructure/vpn`
**Purpose:** VPN infrastructure (Tailscale/Twingate/WireGuard)

```
vpn/
├── terraform/
├── ansible/
│   └── playbooks/
│       ├── tailscale-setup.yml
│       └── wireguard-setup.yml
├── configs/
├── .gitlab-ci.yml
└── README.md
```

---

#### `infrastructure/backup-infrastructure`
**Purpose:** Proxmox Backup Server deployment

```
backup-infrastructure/
├── terraform/
├── ansible/
│   └── playbooks/
│       └── configure-pbs.yml
├── .gitlab-ci.yml
└── README.md
```

---

### 3. Kubernetes Repositories

#### `kubernetes/argocd-bootstrap`
**Purpose:** Bootstrap ArgoCD itself

```
argocd-bootstrap/
├── terraform/
│   └── main.tf                  # Deploy ArgoCD via Helm
├── argocd/
│   ├── root-app.yaml           # App-of-apps root
│   └── projects/               # ArgoCD Projects
│       ├── core-services.yaml
│       ├── observability.yaml
│       ├── security.yaml
│       └── applications.yaml
├── .gitlab-ci.yml
└── README.md
```

**This is deployed ONCE via GitLab CI/CD, then ArgoCD takes over**

---

#### `kubernetes/argocd-apps`
**Purpose:** App-of-apps pattern (central registry of all ArgoCD Applications)

```
argocd-apps/
├── core-services/
│   ├── networking.yaml
│   ├── storage.yaml
│   ├── secrets.yaml
│   └── registry.yaml
├── observability/
│   ├── monitoring.yaml
│   └── siem.yaml
├── security/
│   ├── scanning.yaml
│   ├── runtime-security.yaml
│   └── policy-enforcement.yaml
├── applications/
│   ├── media.yaml
│   ├── productivity.yaml
│   └── smart-home.yaml
├── .gitlab-ci.yml              # Validates and applies
└── README.md
```

**Each YAML references the actual service repos**

---

#### `kubernetes/platform-services`
**Purpose:** Core K8s platform services bundle (deploy order)

```
platform-services/
├── 00-cilium/
├── 01-metallb/
├── 02-cert-manager/
├── 03-external-dns/
├── 04-traefik/
├── 05-longhorn/
├── 06-vault/
└── README.md                   # Deployment order & dependencies
```

---

#### `kubernetes/system-manifests`
**Purpose:** Cluster-wide configurations

```
system-manifests/
├── rbac/
│   ├── roles.yaml
│   └── rolebindings.yaml
├── network-policies/
├── resource-quotas/
├── pod-security-policies/
├── .gitlab-ci.yml
└── README.md
```

---

### 4. Core Services Repositories

#### `core-services/networking/cilium`
**Purpose:** Cilium CNI deployment & configuration

```
cilium/
├── argocd/
│   └── application.yaml
├── helm/
│   └── values.yaml
├── hubble/                      # Observability
│   └── values.yaml
├── .gitlab-ci.yml
└── README.md
```

**Pattern:** This applies to ALL service repos below

---

#### `core-services/networking/metallb`
```
metallb/
├── argocd/
│   └── application.yaml
├── helm/
│   └── values.yaml
├── config/
│   └── ipaddresspool.yaml
└── .gitlab-ci.yml
```

---

#### `core-services/networking/traefik`
```
traefik/
├── argocd/
│   └── application.yaml
├── helm/
│   └── values.yaml
├── middleware/
│   ├── auth.yaml
│   └── rate-limit.yaml
├── ingressroutes/
└── .gitlab-ci.yml
```

---

#### `core-services/networking/cert-manager`
```
cert-manager/
├── argocd/
│   └── application.yaml
├── helm/
│   └── values.yaml
├── issuers/
│   ├── letsencrypt-staging.yaml
│   └── letsencrypt-prod.yaml
└── .gitlab-ci.yml
```

---

#### `core-services/networking/external-dns`
```
external-dns/
├── argocd/
│   └── application.yaml
├── helm/
│   └── values.yaml
└── .gitlab-ci.yml
```

---

#### `core-services/networking/istio`
```
istio/
├── argocd/
│   └── application.yaml
├── base/
│   └── values.yaml
├── gateways/
├── virtual-services/
└── .gitlab-ci.yml
```

---

#### `core-services/storage/longhorn`
```
longhorn/
├── argocd/
│   └── application.yaml
├── helm/
│   └── values.yaml
├── storageclasses/
└── .gitlab-ci.yml
```

---

#### `core-services/storage/minio`
```
minio/
├── argocd/
│   └── application.yaml
├── helm/
│   └── values.yaml
├── buckets/
│   └── init-buckets.yaml
└── .gitlab-ci.yml
```

---

#### `core-services/secrets/vault`
```
vault/
├── argocd/
│   └── application.yaml
├── helm/
│   └── values.yaml
├── policies/
├── auth-methods/
├── secrets-engines/
└── .gitlab-ci.yml
```

---

#### `core-services/secrets/external-secrets-operator`
```
external-secrets-operator/
├── argocd/
│   └── application.yaml
├── helm/
│   └── values.yaml
├── secret-stores/
│   └── vault-backend.yaml
└── .gitlab-ci.yml
```

---

#### `core-services/secrets/sealed-secrets`
```
sealed-secrets/
├── argocd/
│   └── application.yaml
├── helm/
│   └── values.yaml
└── .gitlab-ci.yml
```

---

#### `core-services/registry/harbor`
```
harbor/
├── argocd/
│   └── application.yaml
├── helm/
│   └── values.yaml
├── projects/
├── robot-accounts/
└── .gitlab-ci.yml
```

---

#### `core-services/registry/jfrog-artifactory`
```
jfrog-artifactory/
├── argocd/
│   └── application.yaml
├── helm/
│   └── values.yaml
├── repositories/
└── .gitlab-ci.yml
```

---

### 5. Observability Repositories

#### `observability/monitoring/prometheus-stack`
```
prometheus-stack/
├── argocd/
│   └── application.yaml
├── prometheus/
│   ├── values.yaml
│   ├── alerts/
│   │   ├── node-alerts.yaml
│   │   ├── k8s-alerts.yaml
│   │   └── app-alerts.yaml
│   └── recording-rules/
├── grafana/
│   ├── values.yaml
│   └── dashboards/
│       ├── kubernetes.json
│       ├── proxmox.json
│       └── media-stack.json
├── alertmanager/
│   └── values.yaml
└── .gitlab-ci.yml
```

---

#### `observability/monitoring/loki-stack`
```
loki-stack/
├── argocd/
│   └── application.yaml
├── loki/
│   └── values.yaml
├── promtail/
│   └── values.yaml
├── grafana-dashboards/
└── .gitlab-ci.yml
```

---

#### `observability/monitoring/netbox`
```
netbox/
├── terraform/                   # Deploy VM
├── ansible/
│   └── playbooks/
│       └── install-netbox.yml
├── .gitlab-ci.yml
└── README.md
```

---

#### `observability/siem/wazuh`
```
wazuh/
├── argocd/
│   └── application.yaml
├── helm/
│   └── values.yaml
├── rules/
├── decoders/
└── .gitlab-ci.yml
```

---

### 6. Security Repositories

#### `security/scanning/trivy`
```
trivy/
├── argocd/
│   └── application.yaml        # Trivy Operator
├── helm/
│   └── values.yaml
├── policies/
└── .gitlab-ci.yml
```

---

#### `security/scanning/clair`
```
clair/
├── argocd/
│   └── application.yaml
├── config/
└── .gitlab-ci.yml
```

---

#### `security/scanning/grype`
```
grype/
├── config/
│   └── .grype.yaml
└── README.md                   # CLI tool, not deployed
```

---

#### `security/scanning/snyk`
```
snyk/
├── config/
└── .gitlab-ci.yml              # CI/CD integration
```

---

#### `security/scanning/dependency-track`
```
dependency-track/
├── argocd/
│   └── application.yaml
├── helm/
│   └── values.yaml
└── .gitlab-ci.yml
```

---

#### `security/runtime-security/falco`
```
falco/
├── argocd/
│   └── application.yaml
├── helm/
│   └── values.yaml
├── rules/
│   ├── custom-rules.yaml
│   └── homelab-rules.yaml
└── .gitlab-ci.yml
```

---

#### `security/runtime-security/tetragon`
```
tetragon/
├── argocd/
│   └── application.yaml
├── helm/
│   └── values.yaml
├── policies/
└── .gitlab-ci.yml
```

---

#### `security/runtime-security/kubearmor`
```
kubearmor/
├── argocd/
│   └── application.yaml
├── helm/
│   └── values.yaml
├── policies/
└── .gitlab-ci.yml
```

---

#### `security/network-security/suricata`
```
suricata/
├── terraform/                   # Deploy VM
├── ansible/
│   └── playbooks/
│       └── install-suricata.yml
├── rules/
└── .gitlab-ci.yml
```

---

#### `security/network-security/crowdsec`
```
crowdsec/
├── argocd/
│   └── application.yaml
├── helm/
│   └── values.yaml
├── scenarios/
└── .gitlab-ci.yml
```

---

#### `security/network-security/modsecurity`
```
modsecurity/
├── config/
│   └── modsecurity.conf
└── rules/
```

---

#### `security/policy-enforcement/opa`
```
opa/
├── argocd/
│   └── application.yaml
├── helm/
│   └── values.yaml
├── policies/                    # References platform/opa-policies
└── .gitlab-ci.yml
```

---

#### `security/policy-enforcement/kyverno`
```
kyverno/
├── argocd/
│   └── application.yaml
├── helm/
│   └── values.yaml
├── policies/
│   ├── require-labels.yaml
│   ├── restrict-registries.yaml
│   └── disallow-privileged.yaml
└── .gitlab-ci.yml
```

---

#### `security/policy-enforcement/kubescape`
```
kubescape/
├── argocd/
│   └── application.yaml
├── helm/
│   └── values.yaml
└── .gitlab-ci.yml
```

---

#### `security/policy-enforcement/polaris`
```
polaris/
├── argocd/
│   └── application.yaml
├── helm/
│   └── values.yaml
└── .gitlab-ci.yml
```

---

#### `security/access-control/teleport`
```
teleport/
├── argocd/
│   └── application.yaml
├── helm/
│   └── values.yaml
├── roles/
└── .gitlab-ci.yml
```

---

#### `security/access-control/boundary`
```
boundary/
├── terraform/
├── config/
└── .gitlab-ci.yml
```

---

#### `security/pki/smallstep`
```
smallstep/
├── argocd/
│   └── application.yaml
├── helm/
│   └── values.yaml
└── .gitlab-ci.yml
```

---

#### `security/pki/step-ca`
```
step-ca/
├── argocd/
│   └── application.yaml
├── config/
└── .gitlab-ci.yml
```

---

### 7. CI/CD Repositories

#### `cicd/gitlab-runners`
```
gitlab-runners/
├── terraform/                   # Deploy runner VMs
├── ansible/
│   └── playbooks/
│       └── install-runner.yml
├── k8s/
│   └── helm/                   # K8s-based runners
│       └── values.yaml
├── .gitlab-ci.yml
└── README.md
```

---

#### `cicd/jenkins`
```
jenkins/
├── terraform/                   # Deploy Jenkins VM
├── ansible/
│   └── playbooks/
│       └── configure-jenkins.yml
├── jobs/
│   └── job-dsl/                # Jenkins Job DSL
├── .gitlab-ci.yml
└── README.md
```

---

#### `cicd/pipeline-libraries`
```
pipeline-libraries/
├── vars/                        # Jenkins shared libraries
├── resources/
└── README.md
```

---

### 8. Application Repositories

#### Media Applications

**`applications/media/jellyfin`**
```
jellyfin/
├── argocd/
│   └── application.yaml
├── helm/
│   └── values.yaml
├── config/
└── .gitlab-ci.yml
```

**`applications/media/arr-stack`**
```
arr-stack/
├── argocd/
│   └── application.yaml
├── apps/
│   ├── sonarr/
│   ├── radarr/
│   ├── prowlarr/
│   ├── bazarr/
│   └── readarr/
└── .gitlab-ci.yml
```

**`applications/media/qbittorrent`**
```
qbittorrent/
├── argocd/
│   └── application.yaml
├── helm/
│   └── values.yaml
└── .gitlab-ci.yml
```

**`applications/media/tdarr`**
```
tdarr/
├── argocd/
│   └── application.yaml
├── helm/
│   └── values.yaml
└── .gitlab-ci.yml
```

**`applications/media/audiobookshelf`**
```
audiobookshelf/
├── argocd/
│   └── application.yaml
├── helm/
│   └── values.yaml
└── .gitlab-ci.yml
```

**`applications/media/calibre-web`**
```
calibre-web/
├── argocd/
│   └── application.yaml
├── helm/
│   └── values.yaml
└── .gitlab-ci.yml
```

---

#### Productivity Applications

**`applications/productivity/nextcloud`**
```
nextcloud/
├── argocd/
│   └── application.yaml
├── helm/
│   └── values.yaml
├── apps/
│   └── enabled-apps.txt
└── .gitlab-ci.yml
```

**`applications/productivity/n8n`**
```
n8n/
├── argocd/
│   └── application.yaml
├── helm/
│   └── values.yaml
├── workflows/
└── .gitlab-ci.yml
```

**`applications/productivity/vaultwarden`**
```
vaultwarden/
├── argocd/
│   └── application.yaml
├── helm/
│   └── values.yaml
└── .gitlab-ci.yml
```

**`applications/productivity/homepage-dashboard`**
```
homepage-dashboard/
├── argocd/
│   └── application.yaml
├── helm/
│   └── values.yaml
├── config/
│   ├── services.yaml
│   ├── widgets.yaml
│   └── bookmarks.yaml
└── .gitlab-ci.yml
```

---

#### Smart Home Applications

**`applications/smart-home/home-assistant`**
```
home-assistant/
├── argocd/
│   └── application.yaml
├── helm/
│   └── values.yaml
├── config/
│   ├── configuration.yaml
│   ├── automations.yaml
│   └── scripts.yaml
└── .gitlab-ci.yml
```

**`applications/smart-home/node-red`**
```
node-red/
├── argocd/
│   └── application.yaml
├── helm/
│   └── values.yaml
├── flows/
└── .gitlab-ci.yml
```

---

#### Photo Applications

**`applications/photos/immich`**
```
immich/
├── argocd/
│   └── application.yaml
├── helm/
│   └── values.yaml
└── .gitlab-ci.yml
```

**`applications/photos/photoprism`**
```
photoprism/
├── argocd/
│   └── application.yaml
├── helm/
│   └── values.yaml
└── .gitlab-ci.yml
```

---

#### AI Applications

**`applications/ai/ollama`**
```
ollama/
├── argocd/
│   └── application.yaml
├── helm/
│   └── values.yaml
├── models/
│   └── model-list.txt
└── .gitlab-ci.yml
```

**`applications/ai/open-webui`**
```
open-webui/
├── argocd/
│   └── application.yaml
├── helm/
│   └── values.yaml
└── .gitlab-ci.yml
```

---

#### Utility Applications

**`applications/utilities/shlink`**
```
shlink/
├── argocd/
│   └── application.yaml
├── helm/
│   └── values.yaml
└── .gitlab-ci.yml
```

**`applications/utilities/littlelink`**
```
littlelink/
├── argocd/
│   └── application.yaml
├── helm/
│   └── values.yaml
└── .gitlab-ci.yml
```

**`applications/utilities/pihole`**
```
pihole/
├── argocd/
│   └── application.yaml
├── helm/
│   └── values.yaml
├── adlists/
└── .gitlab-ci.yml
```

---

#### Code Quality

**`applications/code-quality/sonarqube`**
```
sonarqube/
├── argocd/
│   └── application.yaml
├── helm/
│   └── values.yaml
├── quality-profiles/
└── .gitlab-ci.yml
```

---

### 9. Backup Repositories

#### `backup/proxmox-backup-server`
```
proxmox-backup-server/
├── terraform/
├── ansible/
│   └── playbooks/
│       └── configure-pbs.yml
├── backup-jobs/
└── .gitlab-ci.yml
```

---

#### `backup/velero`
```
velero/
├── argocd/
│   └── application.yaml
├── helm/
│   └── values.yaml
├── schedules/
│   ├── daily-backup.yaml
│   └── weekly-backup.yaml
└── .gitlab-ci.yml
```

---

#### `backup/backup-scripts`
```
backup-scripts/
├── scripts/
│   ├── backup-gitlab.sh
│   ├── backup-harbor.sh
│   └── backup-vault.sh
├── cron/
└── .gitlab-ci.yml
```

---

### 10. Operations Repositories

#### `operations/scripts`
```
scripts/
├── infrastructure/
│   ├── vm-cleanup.sh
│   └── snapshot-manager.sh
├── kubernetes/
│   ├── drain-node.sh
│   └── cert-renewal.sh
├── monitoring/
│   └── health-check.sh
└── README.md
```

---

#### `operations/documentation`
```
documentation/
├── architecture/
│   ├── network-diagram.md
│   ├── kubernetes-architecture.md
│   └── security-architecture.md
├── runbooks/
│   ├── incident-response.md
│   ├── backup-restore.md
│   └── disaster-recovery.md
├── procedures/
│   ├── onboarding.md
│   ├── deployment-guide.md
│   └── troubleshooting.md
└── adr/                        # Architecture Decision Records
    ├── 001-use-argocd.md
    └── 002-choose-cilium.md
```

---

#### `operations/testing/terratest`
```
terratest/
├── tests/
│   ├── proxmox_vm_test.go
│   └── kubernetes_cluster_test.go
├── go.mod
└── README.md
```

---

#### `operations/testing/molecule`
```
molecule/
├── scenarios/
│   ├── default/
│   └── security-hardening/
└── README.md
```

---

#### `operations/testing/checkov`
```
checkov/
├── policies/
│   └── custom-checks.py
├── config/
│   └── .checkov.yaml
└── README.md
```

---

#### `operations/automation`
```
automation/
├── cronjobs/
│   ├── cert-renewal.yaml
│   └── backup-cleanup.yaml
├── scripts/
│   ├── scale-workers.sh
│   └── update-dns.sh
└── .gitlab-ci.yml
```

---

## CI/CD Integration Patterns

### Pattern 1: Infrastructure Deployment (GitLab CI/CD)

Used for: VMs, Kubernetes cluster, base infrastructure

```yaml
# Example: infrastructure/kubernetes-cluster/.gitlab-ci.yml

include:
  - project: 'homelab/platform/ci-templates'
    file: 
      - 'templates/terraform.yml'
      - 'templates/ansible.yml'
      - 'templates/security-scan.yml'

stages:
  - validate
  - security
  - plan
  - apply
  - configure
  - test

variables:
  TF_ROOT: ${CI_PROJECT_DIR}/terraform
  ANSIBLE_ROOT: ${CI_PROJECT_DIR}/ansible

# Validation
terraform:validate:
  extends: .terraform:validate
  stage: validate

ansible:lint:
  extends: .ansible:lint
  stage: validate

# Security scanning
checkov:scan:
  extends: .security:checkov
  stage: security

trivy:scan:
  extends: .security:trivy
  stage: security

# Terraform workflow
terraform:plan:
  extends: .terraform:plan
  stage: plan
  artifacts:
    paths:
      - ${TF_ROOT}/plan.tfplan

terraform:apply:
  extends: .terraform:apply
  stage: apply
  when: manual
  only:
    - main
  needs:
    - terraform:plan
  
# Ansible configuration
ansible:configure:
  extends: .ansible:playbook
  stage: configure
  needs:
    - terraform:apply
  script:
    - cd ${ANSIBLE_ROOT}
    - ansible-galaxy install -r requirements.yml
    - ansible-playbook -i inventory/dynamic.py playbooks/bootstrap-cluster.yml

# Testing
terratest:
  stage: test
  image: golang:1.21
  script:
    - cd tests
    - go test -v -timeout 30m
  only:
    - merge_requests
```

---

### Pattern 2: Kubernetes Service Deployment (ArgoCD)

Used for: All Kubernetes workloads

```yaml
# Example: core-services/networking/traefik/.gitlab-ci.yml

include:
  - project: 'homelab/platform/ci-templates'
    file: 
      - 'templates/helm.yml'
      - 'templates/argocd-sync.yml'
      - 'templates/security-scan.yml'

stages:
  - validate
  - security
  - register
  - sync

variables:
  HELM_ROOT: ${CI_PROJECT_DIR}/helm
  ARGOCD_APP: ${CI_PROJECT_DIR}/argocd/application.yaml

# Validation
helm:lint:
  extends: .helm:lint
  stage: validate

helm:template:
  extends: .helm:template
  stage: validate
  artifacts:
    paths:
      - manifests/

# Security scanning
trivy:config:
  extends: .security:trivy-config
  stage: security
  needs:
    - helm:template

kubescape:scan:
  stage: security
  image: quay.io/kubescape/kubescape:latest
  script:
    - kubescape scan manifests/ --format junit --output results.xml
  artifacts:
    reports:
      junit: results.xml

# Register with ArgoCD
argocd:register:
  extends: .argocd:register
  stage: register
  only:
    - main

# Optional: Force sync (manual)
argocd:sync:
  extends: .argocd:sync
  stage: sync
  when: manual
  only:
    - main
```

---

### Pattern 3: Application Deployment (ArgoCD with CI/CD build)

Used for: Custom applications with Docker builds

```yaml
# Example: applications/productivity/homepage-dashboard/.gitlab-ci.yml

include:
  - project: 'homelab/platform/ci-templates'
    file: 
      - 'templates/docker-build.yml'
      - 'templates/security-scan.yml'
      - 'templates/argocd-sync.yml'

stages:
  - build
  - security
  - push
  - deploy

variables:
  IMAGE_NAME: harbor.homelab.local/applications/homepage-dashboard
  IMAGE_TAG: ${CI_COMMIT_SHORT_SHA}

# Build container
docker:build:
  extends: .docker:build
  stage: build

# Security scanning
trivy:image:
  extends: .security:trivy-image
  stage: security
  variables:
    IMAGE: ${IMAGE_NAME}:${IMAGE_TAG}

grype:scan:
  stage: security
  image: anchore/grype:latest
  script:
    - grype ${IMAGE_NAME}:${IMAGE_TAG} --fail-on high
  allow_failure: true

# Push to Harbor
docker:push:
  extends: .docker:push
  stage: push
  only:
    - main

# Update image tag in ArgoCD
argocd:update-image:
  stage: deploy
  image: alpine/git
  script:
    - cd helm
    - sed -i "s/tag:.*/tag: ${IMAGE_TAG}/" values.yaml
    - git config user.email "gitlab-ci@homelab.local"
    - git config user.name "GitLab CI"
    - git add values.yaml
    - git commit -m "Update image to ${IMAGE_TAG}"
    - git push origin HEAD:main
  only:
    - main
```

---

## ArgoCD Integration

### App-of-Apps Structure

**Root Application** (`kubernetes/argocd-bootstrap/argocd/root-app.yaml`):
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: root
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://gitlab.homelab.local/homelab/kubernetes/argocd-apps.git
    targetRevision: main
    path: .
  destination:
    server: https://kubernetes.default.svc
    namespace: argocd
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

---

**Core Services App** (`kubernetes/argocd-apps/core-services/networking.yaml`):
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: core-networking
  namespace: argocd
spec:
  project: core-services
  source:
    repoURL: https://gitlab.homelab.local/homelab/core-services/networking
    targetRevision: main
    path: .
  destination:
    server: https://kubernetes.default.svc
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

---

**Individual Service** (`core-services/networking/traefik/argocd/application.yaml`):
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: traefik
  namespace: argocd
spec:
  project: core-services
  source:
    repoURL: https://gitlab.homelab.local/homelab/core-services/networking/traefik.git
    targetRevision: main
    path: helm
  destination:
    server: https://kubernetes.default.svc
    namespace: traefik
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
  syncWaves:
    - wave: 2  # Deploy after MetalLB (wave 1)
```

---

### ArgoCD Projects

Define logical groupings with RBAC:

```yaml
# kubernetes/argocd-bootstrap/argocd/projects/core-services.yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: core-services
  namespace: argocd
spec:
  description: Core platform services
  sourceRepos:
    - 'https://gitlab.homelab.local/homelab/core-services/*'
  destinations:
    - namespace: '*'
      server: https://kubernetes.default.svc
  clusterResourceWhitelist:
    - group: '*'
      kind: '*'
```

---

### Sync Waves for Deployment Order

Use annotations to control deployment order:

```yaml
# core-services/networking/metallb/argocd/application.yaml
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "1"

# core-services/networking/traefik/argocd/application.yaml
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "2"

# applications/media/jellyfin/argocd/application.yaml
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "10"
```

**Deployment waves:**
- Wave 0: CNI (Cilium) - deployed via Ansible
- Wave 1: MetalLB, Cert-Manager
- Wave 2: Traefik, External-DNS
- Wave 3: Longhorn, MinIO
- Wave 4: Vault, Sealed Secrets
- Wave 5: Harbor, Artifactory
- Wave 6-9: Monitoring, Security, SIEM
- Wave 10+: Applications

---

## Deployment Workflows

### Workflow 1: Deploy New VM-Based Service

Example: Deploy NetBox

1. **Create infrastructure code:**
   ```bash
   cd infrastructure/proxmox-vms/terraform/environments/
   mkdir netbox
   # Add main.tf using platform/terraform-modules
   ```

2. **Create Ansible playbook:**
   ```bash
   cd infrastructure/proxmox-vms/ansible/playbooks/
   # Create configure-netbox.yml using platform/ansible-roles
   ```

3. **Update GitLab CI/CD:**
   ```yaml
   # Add netbox job to .gitlab-ci.yml
   ```

4. **Commit and push:**
   ```bash
   git add .
   git commit -m "Add NetBox infrastructure"
   git push origin main
   ```

5. **GitLab CI/CD triggers:**
   - Terraform validates → plans → applies (manual)
   - Ansible configures NetBox

---

### Workflow 2: Deploy New Kubernetes Service

Example: Deploy Falco

1. **Create service repository:**
   ```bash
   # In GitLab: Create security/runtime-security/falco
   cd security/runtime-security/falco
   ```

2. **Add Helm values:**
   ```yaml
   # helm/values.yaml
   ```

3. **Create ArgoCD Application:**
   ```yaml
   # argocd/application.yaml
   ```

4. **Register with ArgoCD:**
   ```bash
   cd kubernetes/argocd-apps/security/
   # Add falco.yaml pointing to the service repo
   ```

5. **Commit and push:**
   ```bash
   git add .
   git commit -m "Add Falco runtime security"
   git push origin main
   ```

6. **ArgoCD automatically:**
   - Detects new application
   - Syncs and deploys Falco

---

### Workflow 3: Update Existing Service

Example: Update Traefik configuration

1. **Update Helm values:**
   ```bash
   cd core-services/networking/traefik
   # Edit helm/values.yaml
   ```

2. **Commit and push:**
   ```bash
   git add helm/values.yaml
   git commit -m "Update Traefik: Enable access logs"
   git push origin main
   ```

3. **GitLab CI/CD:**
   - Lints Helm chart
   - Runs security scans
   - Passes

4. **ArgoCD:**
   - Detects drift
   - Auto-syncs changes (if enabled)
   - Traefik rolling update

---

### Workflow 4: Deploy New Application

Example: Deploy Immich

1. **Create application repository:**
   ```bash
   # Create applications/photos/immich
   ```

2. **Build Docker image (if custom):**
   ```dockerfile
   # Dockerfile (optional)
   ```

3. **Create Helm chart or manifests:**
   ```yaml
   # helm/values.yaml or manifests/
   ```

4. **Create ArgoCD Application:**
   ```yaml
   # argocd/application.yaml
   ```

5. **Register with ArgoCD:**
   ```bash
   cd kubernetes/argocd-apps/applications/
   # Add photos.yaml
   ```

6. **Set up CI/CD:**
   ```yaml
   # .gitlab-ci.yml
   # Build → Scan → Push → Deploy
   ```

7. **Commit and deploy:**
   ```bash
   git push origin main
   ```

---

## Security & Testing

### Security Scanning Integration

**GitLab CI/CD Template** (`platform/ci-templates/templates/security-scan.yml`):

```yaml
.security:checkov:
  stage: security
  image: bridgecrew/checkov:latest
  script:
    - checkov -d . --framework terraform ansible kubernetes helm
  allow_failure: true

.security:trivy-config:
  stage: security
  image: aquasec/trivy:latest
  script:
    - trivy config .
  allow_failure: true

.security:trivy-image:
  stage: security
  image: aquasec/trivy:latest
  script:
    - trivy image --severity HIGH,CRITICAL ${IMAGE}

.security:grype:
  stage: security
  image: anchore/grype:latest
  script:
    - grype dir:. --fail-on high

.security:snyk:
  stage: security
  image: snyk/snyk:docker
  script:
    - snyk test --severity-threshold=high
  allow_failure: true

.security:kics:
  stage: security
  image: checkmarx/kics:latest
  script:
    - kics scan -p . -o results.json
  artifacts:
    reports:
      junit: results.json
```

---

### Testing Framework Integration

**Terratest Example** (`operations/testing/terratest/tests/proxmox_vm_test.go`):

```go
package test

import (
    "testing"
    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/stretchr/testify/assert"
)

func TestProxmoxVM(t *testing.T) {
    terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
        TerraformDir: "../infrastructure/proxmox-vms/terraform/",
    })

    defer terraform.Destroy(t, terraformOptions)
    terraform.InitAndApply(t, terraformOptions)

    vmID := terraform.Output(t, terraformOptions, "vm_id")
    assert.NotEmpty(t, vmID)
}
```

---

**Molecule Example** (`operations/testing/molecule/scenarios/default/molecule.yml`):

```yaml
dependency:
  name: galaxy
  options:
    role-file: requirements.yml

driver:
  name: docker

platforms:
  - name: test-instance
    image: ubuntu:22.04
    privileged: true

provisioner:
  name: ansible
  playbooks:
    converge: converge.yml
    verify: verify.yml

verifier:
  name: ansible
```

---

### Continuous Security Monitoring

**Runtime Security Stack:**

1. **Falco** - Runtime threat detection
2. **Trivy Operator** - Continuous vulnerability scanning
3. **Kyverno** - Policy enforcement
4. **Wazuh** - SIEM correlation

**Integration in ArgoCD:**
```yaml
# All pods get scanned automatically by Trivy Operator
# Kyverno enforces policies at admission time
# Falco monitors runtime behavior
# Wazuh aggregates all security events
```

---

## Quick Reference Matrix

### Repository → Tool Mapping

| Repository Type | Primary Tool | CI/CD Tool | Deployment Target |
|----------------|--------------|------------|------------------|
| `platform/*` | N/A | GitLab CI | Reusable library |
| `infrastructure/proxmox-vms` | Terraform + Ansible | GitLab CI | Proxmox VMs |
| `infrastructure/kubernetes-cluster` | Terraform + Ansible | GitLab CI | Proxmox VMs → K8s |
| `kubernetes/argocd-bootstrap` | Helm | GitLab CI (once) | Kubernetes |
| `kubernetes/argocd-apps` | YAML | GitLab CI | ArgoCD (registry) |
| `core-services/*` | Helm | ArgoCD | Kubernetes |
| `observability/*` | Helm | ArgoCD | Kubernetes |
| `security/*` | Helm/Manifests | ArgoCD | Kubernetes/VMs |
| `cicd/*` | Terraform + Ansible | GitLab CI | VMs/Kubernetes |
| `applications/*` | Helm/Docker | GitLab CI + ArgoCD | Kubernetes |
| `backup/*` | Terraform + Ansible | GitLab CI | VMs/Kubernetes |
| `operations/*` | Scripts/Docs | N/A | Reference |

---

### Service → Repository Mapping

| Service | Repository | Deployment Method |
|---------|-----------|------------------|
| Proxmox | N/A | Manual installation |
| Pi-Hole | `infrastructure/dns` | Terraform + Ansible → VM |
| Terraform | `platform/terraform-modules` | Library |
| Ansible | `platform/ansible-roles` | Library |
| Chef | `platform/chef-cookbooks` | Library |
| GitLab | External | SaaS or separate install |
| GitLab Runners | `cicd/gitlab-runners` | Terraform + Ansible → VMs/K8s |
| Jenkins | `cicd/jenkins` | Terraform + Ansible → VM |
| ArgoCD | `kubernetes/argocd-bootstrap` | Helm via GitLab CI |
| Traefik | `core-services/networking/traefik` | ArgoCD |
| Cert-Manager | `core-services/networking/cert-manager` | ArgoCD |
| MetalLB | `core-services/networking/metallb` | ArgoCD |
| Cilium | `infrastructure/kubernetes-cluster` | Ansible during bootstrap |
| Istio | `core-services/networking/istio` | ArgoCD |
| Longhorn | `core-services/storage/longhorn` | ArgoCD |
| External-DNS | `core-services/networking/external-dns` | ArgoCD |
| Harbor | `core-services/registry/harbor` | ArgoCD |
| JFrog Artifactory | `core-services/registry/jfrog-artifactory` | ArgoCD |
| Vault | `core-services/secrets/vault` | ArgoCD |
| Prometheus + Grafana | `observability/monitoring/prometheus-stack` | ArgoCD |
| Loki + Promtail | `observability/monitoring/loki-stack` | ArgoCD |
| Tailscale | `infrastructure/vpn` | Terraform + Ansible → VM |
| NetBox | `observability/monitoring/netbox` | Terraform + Ansible → VM |
| MinIO | `core-services/storage/minio` | ArgoCD |
| Proxmox Backup Server | `backup/proxmox-backup-server` | Terraform + Ansible → VM |
| Velero | `backup/velero` | ArgoCD |
| Wazuh | `observability/siem/wazuh` | ArgoCD |
| OPA | `security/policy-enforcement/opa` | ArgoCD |
| Kyverno | `security/policy-enforcement/kyverno` | ArgoCD |
| Trivy | `security/scanning/trivy` | ArgoCD (Operator) |
| Clair | `security/scanning/clair` | ArgoCD |
| Grype | `security/scanning/grype` | CI/CD tool only |
| Snyk | `security/scanning/snyk` | CI/CD tool only |
| Falco | `security/runtime-security/falco` | ArgoCD |
| Tetragon | `security/runtime-security/tetragon` | ArgoCD |
| KubeArmor | `security/runtime-security/kubearmor` | ArgoCD |
| Suricata | `security/network-security/suricata` | Terraform + Ansible → VM |
| CrowdSec | `security/network-security/crowdsec` | ArgoCD |
| Smallstep | `security/pki/smallstep` | ArgoCD |
| External Secrets Operator | `core-services/secrets/external-secrets-operator` | ArgoCD |
| Sealed Secrets | `core-services/secrets/sealed-secrets` | ArgoCD |
| Kubescape | `security/policy-enforcement/kubescape` | ArgoCD |
| Polaris | `security/policy-enforcement/polaris` | ArgoCD |
| Teleport | `security/access-control/teleport` | ArgoCD |
| Boundary | `security/access-control/boundary` | Terraform + Ansible → VM |
| Dependency-Track | `security/scanning/dependency-track` | ArgoCD |
| SonarQube | `applications/code-quality/sonarqube` | ArgoCD |
| Homepage | `applications/productivity/homepage-dashboard` | ArgoCD |
| n8n | `applications/productivity/n8n` | ArgoCD |
| Ollama | `applications/ai/ollama` | ArgoCD |
| Open WebUI | `applications/ai/open-webui` | ArgoCD |
| Nextcloud | `applications/productivity/nextcloud` | ArgoCD |
| qBittorrent | `applications/media/qbittorrent` | ArgoCD |
| ARR Stack | `applications/media/arr-stack` | ArgoCD |
| Jellyfin | `applications/media/jellyfin` | ArgoCD |
| Tdarr | `applications/media/tdarr` | ArgoCD |
| Home Assistant | `applications/smart-home/home-assistant` | ArgoCD |
| Node-RED | `applications/smart-home/node-red` | ArgoCD |
| Shlink | `applications/utilities/shlink` | ArgoCD |
| Littlelink | `applications/utilities/littlelink` | ArgoCD |
| Vaultwarden | `applications/productivity/vaultwarden` | ArgoCD |
| Immich | `applications/photos/immich` | ArgoCD |
| Photoprism | `applications/photos/photoprism` | ArgoCD |
| Audiobookshelf | `applications/media/audiobookshelf` | ArgoCD |
| Calibre-Web | `applications/media/calibre-web` | ArgoCD |

---

### Deployment Order (Bootstrap Sequence)

#### Phase 1: Foundation (Manual/GitLab CI)
1. Proxmox hypervisor (manual)
2. GitLab (external or manual)
3. Pi-Hole DNS (`infrastructure/dns`)
4. GitLab Runners (`cicd/gitlab-runners`)

#### Phase 2: Kubernetes Cluster (GitLab CI)
1. K8s VMs (`infrastructure/kubernetes-cluster`)
2. Cilium CNI (via Ansible)
3. kubeconfig extraction

#### Phase 3: ArgoCD Bootstrap (GitLab CI - Once)
1. ArgoCD installation (`kubernetes/argocd-bootstrap`)
2. Root app-of-apps deployment
3. ArgoCD Projects creation

#### Phase 4: Core Services (ArgoCD - Wave 1-5)
**Wave 1:**
- MetalLB
- Cert-Manager

**Wave 2:**
- Traefik
- External-DNS

**Wave 3:**
- Longhorn
- MinIO

**Wave 4:**
- Vault
- External Secrets Operator
- Sealed Secrets

**Wave 5:**
- Harbor
- JFrog Artifactory

#### Phase 5: Observability & Security (ArgoCD - Wave 6-9)
**Wave 6:**
- Prometheus Stack
- Loki Stack

**Wave 7:**
- Wazuh SIEM
- Falco
- Tetragon

**Wave 8:**
- Kyverno
- OPA
- Kubescape

**Wave 9:**
- Trivy Operator
- CrowdSec
- Dependency-Track

#### Phase 6: Applications (ArgoCD - Wave 10+)
- All user applications deploy in parallel

---

## Best Practices Summary

### ✅ DO

1. **Use semantic versioning** for platform modules/roles
2. **Pin versions** in production (modules, charts, images)
3. **Test in merge requests** before merging to main
4. **Document architecture decisions** in `operations/documentation/adr/`
5. **Use ArgoCD sync waves** for deployment dependencies
6. **Implement automated security scanning** in all pipelines
7. **Keep secrets in Vault**, never in Git
8. **Use External Secrets Operator** to sync secrets to K8s
9. **Enable ArgoCD auto-sync** for non-critical services
10. **Maintain runbooks** for common operations
11. **Use GitLab CI templates** to avoid duplication
12. **Tag releases** for platform components
13. **Monitor ArgoCD sync status** via Prometheus
14. **Implement backup strategies** for stateful services
15. **Use resource quotas and limits**

### ❌ DON'T

1. **Don't commit secrets** to Git (use Sealed Secrets/Vault)
2. **Don't use `latest` tags** in production
3. **Don't skip security scans** in CI/CD
4. **Don't deploy directly to production** without testing
5. **Don't create monolithic repositories**
6. **Don't hardcode environment-specific values**
7. **Don't ignore GitOps principles** (Git as source of truth)
8. **Don't skip documentation**
9. **Don't deploy without RBAC** properly configured
10. **Don't ignore failed health checks**

---

## Migration Strategy

### For Existing Infrastructure

If you already have services running:

1. **Audit current state:**
   ```bash
   # Document what's running where
   # Create inventory
   ```

2. **Start with platform repos:**
   - Extract common Terraform modules
   - Extract common Ansible roles
   - Create CI templates

3. **Migrate one service at a time:**
   - Choose a non-critical service
   - Create repo structure
   - Add to ArgoCD
   - Validate
   - Repeat

4. **Bootstrap new services using this structure**

### For Greenfield Setup

Follow the deployment order:
1. Platform repositories (week 1)
2. Infrastructure repositories (week 2)
3. Kubernetes cluster (week 3)
4. ArgoCD + Core services (week 4-5)
5. Observability + Security (week 6-7)
6. Applications (week 8+)

---

## Conclusion

This structure provides:

✅ **Scalability:** Add new services without restructuring  
✅ **Maintainability:** Clear ownership and separation  
✅ **Reusability:** DRY principles with platform repos  
✅ **Security:** Automated scanning and policy enforcement  
✅ **GitOps:** Full audit trail and declarative state  
✅ **Flexibility:** Mix GitLab CI/CD and ArgoCD appropriately  
✅ **Learning:** Isolated environments for Chef, Jenkins, etc.  

**This is production-ready and mirrors real-world enterprise patterns.**

---

## Next Steps

1. **Create GitLab groups and projects** following this structure
2. **Set up platform repos first** (terraform-modules, ansible-roles, ci-templates)
3. **Deploy infrastructure** (VMs, K8s cluster)
4. **Bootstrap ArgoCD**
5. **Incrementally deploy services** following sync waves
6. **Document as you go** in `operations/documentation`

Good luck with your homelab journey! 🚀

---

## Appendix A: Example CI/CD Templates

### Complete Terraform Template

**File:** `platform/ci-templates/templates/terraform.yml`

```yaml
.terraform:base:
  image:
    name: hashicorp/terraform:latest
    entrypoint: [""]
  variables:
    TF_ROOT: ${CI_PROJECT_DIR}/terraform
    TF_STATE_NAME: default
  before_script:
    - cd ${TF_ROOT}
    - terraform --version
    - terraform init

.terraform:validate:
  extends: .terraform:base
  script:
    - terraform fmt -check -recursive
    - terraform validate

.terraform:plan:
  extends: .terraform:base
  script:
    - terraform plan -out=plan.tfplan
  artifacts:
    name: plan
    paths:
      - ${TF_ROOT}/plan.tfplan
    expire_in: 1 week

.terraform:apply:
  extends: .terraform:base
  script:
    - terraform apply -auto-approve plan.tfplan
  dependencies:
    - terraform:plan

.terraform:destroy:
  extends: .terraform:base
  script:
    - terraform destroy -auto-approve
  when: manual
```

---

### Complete Ansible Template

**File:** `platform/ci-templates/templates/ansible.yml`

```yaml
.ansible:base:
  image: cytopia/ansible:latest
  variables:
    ANSIBLE_ROOT: ${CI_PROJECT_DIR}/ansible
    ANSIBLE_FORCE_COLOR: "true"
    ANSIBLE_HOST_KEY_CHECKING: "false"
  before_script:
    - cd ${ANSIBLE_ROOT}
    - ansible --version

.ansible:lint:
  extends: .ansible:base
  script:
    - ansible-lint .

.ansible:syntax:
  extends: .ansible:base
  script:
    - ansible-playbook --syntax-check playbooks/*.yml

.ansible:playbook:
  extends: .ansible:base
  script:
    - ansible-galaxy install -r requirements.yml --force
    - ansible-playbook -i ${INVENTORY} ${PLAYBOOK}

.ansible:dry-run:
  extends: .ansible:base
  script:
    - ansible-playbook -i ${INVENTORY} ${PLAYBOOK} --check --diff
```

---

### Complete Helm Template

**File:** `platform/ci-templates/templates/helm.yml`

```yaml
.helm:base:
  image: alpine/helm:latest
  variables:
    HELM_ROOT: ${CI_PROJECT_DIR}/helm
  before_script:
    - helm version

.helm:lint:
  extends: .helm:base
  script:
    - cd ${HELM_ROOT}
    - helm lint .

.helm:template:
  extends: .helm:base
  script:
    - cd ${HELM_ROOT}
    - helm template . --output-dir ${CI_PROJECT_DIR}/manifests
  artifacts:
    paths:
      - manifests/
    expire_in: 1 week

.helm:package:
  extends: .helm:base
  script:
    - cd ${HELM_ROOT}
    - helm package .
    - helm push *.tgz oci://${HARBOR_URL}/charts
  only:
    - tags

.helm:upgrade:
  extends: .helm:base
  script:
    - helm upgrade --install ${RELEASE_NAME} ${CHART} \
        --namespace ${NAMESPACE} \
        --create-namespace \
        --values ${VALUES_FILE}
  when: manual
```

---

### Complete ArgoCD Template

**File:** `platform/ci-templates/templates/argocd-sync.yml`

```yaml
.argocd:base:
  image: argoproj/argocd:latest
  variables:
    ARGOCD_SERVER: argocd.homelab.local
    ARGOCD_APP_NAME: ${CI_PROJECT_NAME}
  before_script:
    - argocd version --client
    - argocd login ${ARGOCD_SERVER} 
        --username admin 
        --password ${ARGOCD_PASSWORD} 
        --grpc-web

.argocd:register:
  extends: .argocd:base
  script:
    - kubectl apply -f argocd/application.yaml
    - echo "Application ${ARGOCD_APP_NAME} registered with ArgoCD"

.argocd:sync:
  extends: .argocd:base
  script:
    - argocd app sync ${ARGOCD_APP_NAME}
    - argocd app wait ${ARGOCD_APP_NAME} --timeout 600

.argocd:diff:
  extends: .argocd:base
  script:
    - argocd app diff ${ARGOCD_APP_NAME}
  allow_failure: true

.argocd:rollback:
  extends: .argocd:base
  script:
    - argocd app rollback ${ARGOCD_APP_NAME}
  when: manual
```

---

### Complete Security Scan Template (Extended)

**File:** `platform/ci-templates/templates/security-scan.yml`

```yaml
# Terraform/IaC Scanning
.security:checkov:
  stage: security
  image: bridgecrew/checkov:latest
  script:
    - checkov -d . 
        --framework terraform ansible kubernetes helm 
        --output junitxml 
        --output-file-path ${CI_PROJECT_DIR}
  artifacts:
    reports:
      junit: results_junitxml.xml
    paths:
      - results_junitxml.xml
  allow_failure: true

.security:tfsec:
  stage: security
  image: aquasec/tfsec:latest
  script:
    - tfsec . --format junit > tfsec-report.xml
  artifacts:
    reports:
      junit: tfsec-report.xml
  allow_failure: true

.security:terrascan:
  stage: security
  image: tenable/terrascan:latest
  script:
    - terrascan scan -i terraform -d .
  allow_failure: true

# Container Image Scanning
.security:trivy-image:
  stage: security
  image: aquasec/trivy:latest
  script:
    - trivy image 
        --severity HIGH,CRITICAL 
        --exit-code 1 
        --format json 
        --output trivy-report.json 
        ${IMAGE}
  artifacts:
    reports:
      container_scanning: trivy-report.json
    paths:
      - trivy-report.json

.security:trivy-config:
  stage: security
  image: aquasec/trivy:latest
  script:
    - trivy config . 
        --severity HIGH,CRITICAL 
        --exit-code 0
  allow_failure: true

.security:grype:
  stage: security
  image: anchore/grype:latest
  script:
    - grype ${IMAGE} 
        --fail-on high 
        --output json 
        --file grype-report.json
  artifacts:
    paths:
      - grype-report.json
  allow_failure: true

.security:clair:
  stage: security
  image: arminc/clair-scanner:latest
  script:
    - clair-scanner 
        --ip $(hostname -i) 
        --report clair-report.json 
        ${IMAGE}
  artifacts:
    paths:
      - clair-report.json
  allow_failure: true

# Code Scanning
.security:snyk:
  stage: security
  image: snyk/snyk:docker
  script:
    - snyk test 
        --severity-threshold=high 
        --json-file-output=snyk-report.json
  artifacts:
    paths:
      - snyk-report.json
  allow_failure: true

.security:sonarqube:
  stage: security
  image: sonarsource/sonar-scanner-cli:latest
  script:
    - sonar-scanner 
        -Dsonar.projectKey=${CI_PROJECT_NAME} 
        -Dsonar.sources=. 
        -Dsonar.host.url=${SONARQUBE_URL} 
        -Dsonar.login=${SONARQUBE_TOKEN}
  allow_failure: true

# Kubernetes Manifest Scanning
.security:kubescape:
  stage: security
  image: quay.io/kubescape/kubescape:latest
  script:
    - kubescape scan 
        --format junit 
        --output results.xml 
        manifests/
  artifacts:
    reports:
      junit: results.xml
  allow_failure: true

.security:kube-score:
  stage: security
  image: zegl/kube-score:latest
  script:
    - kube-score score manifests/*.yaml
  allow_failure: true

.security:polaris:
  stage: security
  image: quay.io/fairwinds/polaris:latest
  script:
    - polaris audit 
        --audit-path manifests/ 
        --format pretty
  allow_failure: true

# SBOM Generation
.security:syft:
  stage: security
  image: anchore/syft:latest
  script:
    - syft ${IMAGE} 
        --output cyclonedx-json 
        --file sbom.json
  artifacts:
    paths:
      - sbom.json

# Secrets Scanning
.security:gitleaks:
  stage: security
  image: zricethezav/gitleaks:latest
  script:
    - gitleaks detect 
        --source . 
        --verbose 
        --report-format json 
        --report-path gitleaks-report.json
  artifacts:
    paths:
      - gitleaks-report.json
  allow_failure: true

.security:trufflehog:
  stage: security
  image: trufflesecurity/trufflehog:latest
  script:
    - trufflehog filesystem . 
        --json 
        > trufflehog-report.json
  artifacts:
    paths:
      - trufflehog-report.json
  allow_failure: true
```

---

### Complete Docker Build Template

**File:** `platform/ci-templates/templates/docker-build.yml`

```yaml
.docker:base:
  image: docker:latest
  services:
    - docker:dind
  variables:
    DOCKER_DRIVER: overlay2
    DOCKER_TLS_CERTDIR: "/certs"
    IMAGE_NAME: harbor.homelab.local/${CI_PROJECT_NAMESPACE}/${CI_PROJECT_NAME}
    IMAGE_TAG: ${CI_COMMIT_SHORT_SHA}
  before_script:
    - docker login -u ${HARBOR_USER} -p ${HARBOR_PASSWORD} harbor.homelab.local

.docker:build:
  extends: .docker:base
  script:
    - docker build 
        --build-arg CI_COMMIT_SHA=${CI_COMMIT_SHA} 
        --build-arg CI_COMMIT_REF_NAME=${CI_COMMIT_REF_NAME} 
        --tag ${IMAGE_NAME}:${IMAGE_TAG} 
        --tag ${IMAGE_NAME}:latest 
        .
    - docker images

.docker:push:
  extends: .docker:base
  script:
    - docker push ${IMAGE_NAME}:${IMAGE_TAG}
    - docker push ${IMAGE_NAME}:latest

.docker:build-multiarch:
  extends: .docker:base
  before_script:
    - docker login -u ${HARBOR_USER} -p ${HARBOR_PASSWORD} harbor.homelab.local
    - docker buildx create --use
  script:
    - docker buildx build 
        --platform linux/amd64,linux/arm64 
        --tag ${IMAGE_NAME}:${IMAGE_TAG} 
        --tag ${IMAGE_NAME}:latest 
        --push 
        .
```

---

## Appendix B: Example Repository Structures

### Example: Complete Infrastructure Repository

**Repository:** `infrastructure/kubernetes-cluster`

```
kubernetes-cluster/
├── .gitlab-ci.yml
├── README.md
├── terraform/
│   ├── backend.tf
│   ├── main.tf
│   ├── variables.tf
│   ├── terraform.tfvars
│   ├── outputs.tf
│   ├── control-plane/
│   │   ├── main.tf
│   │   └── variables.tf
│   └── worker-nodes/
│       ├── main.tf
│       └── variables.tf
├── ansible/
│   ├── ansible.cfg
│   ├── requirements.yml
│   ├── inventory/
│   │   ├── hosts.yml
│   │   └── group_vars/
│   │       ├── all.yml
│   │       ├── control_plane.yml
│   │       └── workers.yml
│   └── playbooks/
│       ├── 01-prepare-nodes.yml
│       ├── 02-bootstrap-cluster.yml
│       ├── 03-install-cilium.yml
│       ├── 04-configure-kubectl.yml
│       └── roles/
│           └── (references platform/ansible-roles via requirements.yml)
├── scripts/
│   ├── generate-join-token.sh
│   └── backup-etcd.sh
└── docs/
    ├── architecture.md
    └── troubleshooting.md
```

**`.gitlab-ci.yml`:**
```yaml
include:
  - project: 'homelab/platform/ci-templates'
    file: 
      - 'templates/terraform.yml'
      - 'templates/ansible.yml'
      - 'templates/security-scan.yml'

stages:
  - validate
  - security
  - plan
  - apply
  - configure
  - test

variables:
  TF_ROOT: ${CI_PROJECT_DIR}/terraform
  ANSIBLE_ROOT: ${CI_PROJECT_DIR}/ansible

# Validation stage
terraform:validate:
  extends: .terraform:validate
  stage: validate

terraform:fmt:
  extends: .terraform:validate
  stage: validate
  script:
    - cd ${TF_ROOT}
    - terraform fmt -check -recursive

ansible:lint:
  extends: .ansible:lint
  stage: validate

ansible:syntax:
  extends: .ansible:syntax
  stage: validate

# Security stage
checkov:terraform:
  extends: .security:checkov
  stage: security
  variables:
    CHECKOV_DIR: ${TF_ROOT}

tfsec:scan:
  extends: .security:tfsec
  stage: security

# Planning stage
terraform:plan:control-plane:
  extends: .terraform:plan
  stage: plan
  variables:
    TF_ROOT: ${CI_PROJECT_DIR}/terraform/control-plane

terraform:plan:workers:
  extends: .terraform:plan
  stage: plan
  variables:
    TF_ROOT: ${CI_PROJECT_DIR}/terraform/worker-nodes

# Apply stage (manual)
terraform:apply:control-plane:
  extends: .terraform:apply
  stage: apply
  when: manual
  only:
    - main
  variables:
    TF_ROOT: ${CI_PROJECT_DIR}/terraform/control-plane
  needs:
    - terraform:plan:control-plane

terraform:apply:workers:
  extends: .terraform:apply
  stage: apply
  when: manual
  only:
    - main
  variables:
    TF_ROOT: ${CI_PROJECT_DIR}/terraform/worker-nodes
  needs:
    - terraform:plan:workers
    - terraform:apply:control-plane

# Configuration stage
ansible:prepare-nodes:
  extends: .ansible:playbook
  stage: configure
  variables:
    INVENTORY: inventory/hosts.yml
    PLAYBOOK: playbooks/01-prepare-nodes.yml
  needs:
    - terraform:apply:control-plane
    - terraform:apply:workers

ansible:bootstrap-cluster:
  extends: .ansible:playbook
  stage: configure
  variables:
    INVENTORY: inventory/hosts.yml
    PLAYBOOK: playbooks/02-bootstrap-cluster.yml
  needs:
    - ansible:prepare-nodes

ansible:install-cilium:
  extends: .ansible:playbook
  stage: configure
  variables:
    INVENTORY: inventory/hosts.yml
    PLAYBOOK: playbooks/03-install-cilium.yml
  needs:
    - ansible:bootstrap-cluster

ansible:configure-kubectl:
  extends: .ansible:playbook
  stage: configure
  variables:
    INVENTORY: inventory/hosts.yml
    PLAYBOOK: playbooks/04-configure-kubectl.yml
  needs:
    - ansible:install-cilium
  artifacts:
    paths:
      - kubeconfig
    expire_in: 30 days

# Testing stage
test:cluster-health:
  stage: test
  image: bitnami/kubectl:latest
  script:
    - export KUBECONFIG=${CI_PROJECT_DIR}/kubeconfig
    - kubectl cluster-info
    - kubectl get nodes
    - kubectl get pods -A
    - kubectl wait --for=condition=Ready nodes --all --timeout=300s
  needs:
    - ansible:configure-kubectl
```

---

### Example: Complete Service Repository

**Repository:** `core-services/networking/traefik`

```
traefik/
├── .gitlab-ci.yml
├── README.md
├── argocd/
│   └── application.yaml
├── helm/
│   ├── Chart.yaml (optional, if custom chart)
│   └── values.yaml
├── middleware/
│   ├── auth.yaml
│   ├── rate-limit.yaml
│   ├── compress.yaml
│   └── security-headers.yaml
├── ingressroutes/
│   ├── dashboard.yaml
│   └── examples/
│       └── whoami.yaml
├── certificates/
│   └── default-cert.yaml
└── docs/
    ├── configuration.md
    └── troubleshooting.md
```

**`argocd/application.yaml`:**
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: traefik
  namespace: argocd
  annotations:
    argocd.argoproj.io/sync-wave: "2"
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: core-services
  source:
    repoURL: https://gitlab.homelab.local/homelab/core-services/networking/traefik.git
    targetRevision: main
    path: helm
    helm:
      valueFiles:
        - values.yaml
  destination:
    server: https://kubernetes.default.svc
    namespace: traefik
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
    retry:
      limit: 5
      backoff:
        duration: 5s
        factor: 2
        maxDuration: 3m
  ignoreDifferences:
    - group: apps
      kind: Deployment
      jsonPointers:
        - /spec/replicas
```

**`helm/values.yaml`:**
```yaml
# Reference official Traefik chart
# This repo contains custom values only
deployment:
  replicas: 3

service:
  type: LoadBalancer
  annotations:
    metallb.universe.tf/address-pool: default

ingressRoute:
  dashboard:
    enabled: true
    matchRule: Host(`traefik.homelab.local`)
    entryPoints:
      - websecure
    middlewares:
      - name: auth

additionalArguments:
  - "--api.dashboard=true"
  - "--metrics.prometheus=true"
  - "--accesslog=true"
  - "--log.level=INFO"

ports:
  web:
    port: 80
    exposedPort: 80
  websecure:
    port: 443
    exposedPort: 443
    tls:
      enabled: true
      certResolver: letsencrypt

certResolvers:
  letsencrypt:
    acme:
      email: admin@homelab.local
      storage: /data/acme.json
      tlsChallenge: true

resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 500m
    memory: 512Mi

podSecurityContext:
  fsGroup: 65532
  runAsNonRoot: true
  runAsUser: 65532
```

**`.gitlab-ci.yml`:**
```yaml
include:
  - project: 'homelab/platform/ci-templates'
    file: 
      - 'templates/helm.yml'
      - 'templates/argocd-sync.yml'
      - 'templates/security-scan.yml'

stages:
  - validate
  - security
  - register
  - sync

variables:
  HELM_ROOT: ${CI_PROJECT_DIR}/helm
  ARGOCD_APP_NAME: traefik

# Validation
helm:lint:
  extends: .helm:lint
  stage: validate

helm:template:
  extends: .helm:template
  stage: validate

yaml:validate:
  stage: validate
  image: cytopia/yamllint
  script:
    - yamllint -c .yamllint.yml .

# Security scanning
kubescape:scan:
  extends: .security:kubescape
  stage: security
  needs:
    - helm:template

trivy:config:
  extends: .security:trivy-config
  stage: security

polaris:scan:
  extends: .security:polaris
  stage: security
  needs:
    - helm:template

# Register with ArgoCD
argocd:register:
  extends: .argocd:register
  stage: register
  only:
    - main

# Manual sync (if needed)
argocd:sync:
  extends: .argocd:sync
  stage: sync
  when: manual
  only:
    - main

# Show diff before sync
argocd:diff:
  extends: .argocd:diff
  stage: sync
  only:
    - merge_requests
```

---

### Example: Complete Application Repository

**Repository:** `applications/media/jellyfin`

```
jellyfin/
├── .gitlab-ci.yml
├── README.md
├── Dockerfile (if custom)
├── argocd/
│   └── application.yaml
├── helm/
│   ├── Chart.yaml
│   ├── values.yaml
│   └── templates/
│       ├── deployment.yaml
│       ├── service.yaml
│       ├── ingress.yaml
│       ├── pvc.yaml
│       └── configmap.yaml
├── config/
│   └── (app-specific configs)
└── docs/
    ├── setup.md
    └── backup.md
```

**`argocd/application.yaml`:**
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: jellyfin
  namespace: argocd
  annotations:
    argocd.argoproj.io/sync-wave: "10"
spec:
  project: applications
  source:
    repoURL: https://gitlab.homelab.local/homelab/applications/media/jellyfin.git
    targetRevision: main
    path: helm
  destination:
    server: https://kubernetes.default.svc
    namespace: media
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

**`helm/values.yaml`:**
```yaml
replicaCount: 1

image:
  repository: harbor.homelab.local/applications/jellyfin
  tag: latest
  pullPolicy: Always

service:
  type: ClusterIP
  port: 8096

ingress:
  enabled: true
  className: traefik
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
    traefik.ingress.kubernetes.io/router.middlewares: default-compress@kubernetescrd
  hosts:
    - host: jellyfin.homelab.local
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: jellyfin-tls
      hosts:
        - jellyfin.homelab.local

persistence:
  config:
    enabled: true
    storageClass: longhorn
    size: 10Gi
  media:
    enabled: true
    existingClaim: nfs-media-pvc
    mountPath: /media

resources:
  requests:
    cpu: 500m
    memory: 1Gi
  limits:
    cpu: 2000m
    memory: 4Gi

env:
  - name: TZ
    value: "Europe/Brussels"
  - name: JELLYFIN_PublishedServerUrl
    value: "https://jellyfin.homelab.local"
```

**`.gitlab-ci.yml` (with Docker build):**
```yaml
include:
  - project: 'homelab/platform/ci-templates'
    file: 
      - 'templates/docker-build.yml'
      - 'templates/security-scan.yml'
      - 'templates/argocd-sync.yml'

stages:
  - build
  - security
  - push
  - deploy

variables:
  IMAGE_NAME: harbor.homelab.local/applications/jellyfin
  IMAGE_TAG: ${CI_COMMIT_SHORT_SHA}

# Build
docker:build:
  extends: .docker:build
  stage: build

# Security scanning
trivy:image:
  extends: .security:trivy-image
  stage: security
  variables:
    IMAGE: ${IMAGE_NAME}:${IMAGE_TAG}
  needs:
    - docker:build

grype:image:
  extends: .security:grype
  stage: security
  variables:
    IMAGE: ${IMAGE_NAME}:${IMAGE_TAG}
  needs:
    - docker:build

syft:sbom:
  extends: .security:syft
  stage: security
  variables:
    IMAGE: ${IMAGE_NAME}:${IMAGE_TAG}
  needs:
    - docker:build

# Push
docker:push:
  extends: .docker:push
  stage: push
  only:
    - main
  needs:
    - trivy:image
    - grype:image

# Deploy (update image tag in values.yaml)
update:image-tag:
  stage: deploy
  image: alpine/git
  script:
    - apk add --no-cache yq
    - cd helm
    - yq eval ".image.tag = \"${IMAGE_TAG}\"" -i values.yaml
    - git config user.email "gitlab-ci@homelab.local"
    - git config user.name "GitLab CI"
    - git add values.yaml
    - git commit -m "Update image tag to ${IMAGE_TAG} [skip ci]"
    - git push https://oauth2:${CI_JOB_TOKEN}@gitlab.homelab.local/${CI_PROJECT_PATH}.git HEAD:main
  only:
    - main
  needs:
    - docker:push
```

---

## Appendix C: Monitoring & Alerts

### Monitoring ArgoCD with Prometheus

**PrometheusRule for ArgoCD:**

```yaml
# observability/monitoring/prometheus-stack/alerts/argocd-alerts.yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: argocd-alerts
  namespace: monitoring
spec:
  groups:
    - name: argocd
      interval: 30s
      rules:
        - alert: ArgoCDAppOutOfSync
          expr: argocd_app_info{sync_status="OutOfSync"} == 1
          for: 10m
          labels:
            severity: warning
          annotations:
            summary: "ArgoCD Application {{ $labels.name }} is out of sync"
            description: "Application {{ $labels.name }} in project {{ $labels.project }} has been out of sync for more than 10 minutes."

        - alert: ArgoCDAppUnhealthy
          expr: argocd_app_info{health_status!="Healthy"} == 1
          for: 5m
          labels:
            severity: critical
          annotations:
            summary: "ArgoCD Application {{ $labels.name }} is unhealthy"
            description: "Application {{ $labels.name }} health status is {{ $labels.health_status }}."

        - alert: ArgoCDSyncFailed
          expr: argocd_app_sync_total{phase="Failed"} > 0
          for: 1m
          labels:
            severity: critical
          annotations:
            summary: "ArgoCD sync failed for {{ $labels.name }}"
            description: "Application {{ $labels.name }} sync failed."

        - alert: ArgoCDHighSyncDuration
          expr: argocd_app_sync_total{phase="Succeeded"} > 300
          for: 1m
          labels:
            severity: warning
          annotations:
            summary: "ArgoCD sync took too long for {{ $labels.name }}"
            description: "Application {{ $labels.name }} sync took more than 5 minutes."
```

---

### Grafana Dashboard for Infrastructure

**Dashboard JSON snippet:**

```json
{
  "dashboard": {
    "title": "Homelab Infrastructure Overview",
    "panels": [
      {
        "title": "Proxmox VMs",
        "targets": [
          {
            "expr": "count(proxmox_vm_status)"
          }
        ]
      },
      {
        "title": "Kubernetes Nodes",
        "targets": [
          {
            "expr": "count(kube_node_info)"
          }
        ]
      },
      {
        "title": "ArgoCD Applications",
        "targets": [
          {
            "expr": "count(argocd_app_info)"
          }
        ]
      },
      {
        "title": "Sync Status",
        "targets": [
          {
            "expr": "count(argocd_app_info) by (sync_status)"
          }
        ]
      }
    ]
  }
}
```

---

## Appendix D: Useful Scripts

### Script: Bulk Create GitLab Projects

**File:** `operations/scripts/create-gitlab-structure.sh`

```bash
#!/bin/bash

GITLAB_URL="https://gitlab.homelab.local"
GITLAB_TOKEN="your-access-token"
GROUP_ID="homelab"

# Function to create group
create_group() {
    local parent_id=$1
    local group_name=$2
    
    curl --request POST \
        --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" \
        --header "Content-Type: application/json" \
        --data "{\"name\": \"${group_name}\", \"path\": \"${group_name}\", \"parent_id\": ${parent_id}}" \
        "${GITLAB_URL}/api/v4/groups"
}

# Function to create project
create_project() {
    local namespace_id=$1
    local project_name=$2
    
    curl --request POST \
        --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" \
        --header "Content-Type: application/json" \
        --data "{\"name\": \"${project_name}\", \"namespace_id\": ${namespace_id}}" \
        "${GITLAB_URL}/api/v4/projects"
}

# Create top-level groups
platform_id=$(create_group $GROUP_ID "platform" | jq -r '.id')
infrastructure_id=$(create_group $GROUP_ID "infrastructure" | jq -r '.id')
kubernetes_id=$(create_group $GROUP_ID "kubernetes" | jq -r '.id')
# ... and so on

# Create projects within groups
create_project $platform_id "terraform-modules"
create_project $platform_id "ansible-roles"
# ... and so on

echo "GitLab structure created successfully!"
```

---

### Script: Backup All GitLab Repositories

**File:** `backup/backup-scripts/scripts/backup-gitlab.sh`

```bash
#!/bin/bash

set -e

BACKUP_DIR="/backup/gitlab"
GITLAB_URL="https://gitlab.homelab.local"
GITLAB_TOKEN="your-access-token"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p "${BACKUP_DIR}/${DATE}"

# Get all projects
projects=$(curl --silent --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" \
    "${GITLAB_URL}/api/v4/projects?per_page=100" | jq -r '.[].ssh_url_to_repo')

# Clone each project
for repo in $projects; do
    project_name=$(basename "$repo" .git)
    echo "Backing up ${project_name}..."
    git clone --mirror "$repo" "${BACKUP_DIR}/${DATE}/${project_name}.git"
done

# Create tarball
cd "${BACKUP_DIR}"
tar -czf "gitlab-backup-${DATE}.tar.gz" "${DATE}"
rm -rf "${DATE}"

# Clean up old backups (keep last 7 days)
find "${BACKUP_DIR}" -name "gitlab-backup-*.tar.gz" -mtime +7 -delete

echo "Backup completed: gitlab-backup-${DATE}.tar.gz"
```

---

### Script: Health Check All Services

**File:** `operations/scripts/health-check.sh`

```bash
#!/bin/bash

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=== Homelab Health Check ==="
echo ""

# Check Proxmox
echo -n "Proxmox API: "
if curl -s -k https://proxmox.homelab.local:8006/api2/json/version > /dev/null; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
fi

# Check Pi-Hole
echo -n "Pi-Hole: "
if curl -s http://pihole.homelab.local/admin/api.php > /dev/null; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
fi

# Check Kubernetes cluster
echo -n "Kubernetes API: "
if kubectl cluster-info > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
fi

# Check Kubernetes nodes
echo ""
echo "Kubernetes Nodes:"
kubectl get nodes --no-headers | while read -r line; do
    node=$(echo "$line" | awk '{print $1}')
    status=$(echo "$line" | awk '{print $2}')
    
    if [ "$status" = "Ready" ]; then
        echo -e "  ${GREEN}✓${NC} $node"
    else
        echo -e "  ${RED}✗${NC} $node ($status)"
    fi
done

# Check ArgoCD applications
echo ""
echo "ArgoCD Applications:"
argocd app list --output name | while read -r app; do
    health=$(argocd app get "$app" -o json | jq -r '.status.health.status')
    sync=$(argocd app get "$app" -o json | jq -r '.status.sync.status')
    
    if [ "$health" = "Healthy" ] && [ "$sync" = "Synced" ]; then
        echo -e "  ${GREEN}✓${NC} $app"
    elif [ "$health" = "Progressing" ]; then
        echo -e "  ${YELLOW}⟳${NC} $app (Progressing)"
    else
        echo -e "  ${RED}✗${NC} $app (Health: $health, Sync: $sync)"
    fi
done

# Check critical services
echo ""
echo "Critical Services:"
services=("traefik" "cert-manager" "longhorn" "prometheus" "grafana")

for svc in "${services[@]}"; do
    echo -n "  $svc: "
    if kubectl get pods -A | grep -q "$svc.*Running"; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗${NC}"
    fi
done

echo ""
echo "=== Health Check Complete ==="
```

---

### Script: ArgoCD Bulk Sync

**File:** `operations/scripts/argocd-bulk-sync.sh`

```bash
#!/bin/bash

set -e

ARGOCD_SERVER="argocd.homelab.local"
PROJECT="${1:-all}"

echo "Syncing ArgoCD applications..."

if [ "$PROJECT" = "all" ]; then
    apps=$(argocd app list -o name)
else
    apps=$(argocd app list -o name | grep "$PROJECT")
fi

for app in $apps; do
    echo "Syncing: $app"
    argocd app sync "$app" --prune --async
done

echo ""
echo "All applications queued for sync. Monitor with:"
echo "  argocd app list"
echo "  argocd app wait <app-name>"
```

---

### Script: Rotate Secrets

**File:** `operations/automation/scripts/rotate-secrets.sh`

```bash
#!/bin/bash

set -e

VAULT_ADDR="https://vault.homelab.local"
VAULT_TOKEN="your-vault-token"

rotate_secret() {
    local path=$1
    local key=$2
    
    echo "Rotating secret: $path/$key"
    
    # Generate new secret (example: random string)
    new_secret=$(openssl rand -base64 32)
    
    # Write to Vault
    vault kv put "$path" "$key=$new_secret"
    
    # Trigger External Secrets Operator refresh
    kubectl annotate externalsecret "$key" \
        force-sync=$(date +%s) \
        --overwrite
}

# Example: Rotate database passwords
rotate_secret "secret/data/databases/postgres" "password"
rotate_secret "secret/data/databases/mysql" "password"

echo "Secret rotation complete"
```

---

## Appendix E: Disaster Recovery

### Disaster Recovery Runbook

**File:** `operations/documentation/runbooks/disaster-recovery.md`

```markdown
# Disaster Recovery Runbook

## Recovery Time Objective (RTO)
- **Critical Services**: 4 hours
- **Non-Critical Services**: 24 hours

## Recovery Point Objective (RPO)
- **Databases**: 1 hour (continuous replication)
- **Configuration**: Real-time (Git)
- **Media**: 24 hours (daily backups)

---

## Scenario 1: Complete Cluster Failure

### Prerequisites
- Access to backup storage
- Latest GitLab repository backups
- Proxmox access
- kubeconfig backups

### Steps

1. **Restore Proxmox Infrastructure**
   ```bash
   cd infrastructure/proxmox-vms
   terraform init
   terraform apply
   ```

2. **Restore Kubernetes Cluster**
   ```bash
   cd infrastructure/kubernetes-cluster
   terraform apply
   cd ansible
   ansible-playbook playbooks/02-bootstrap-cluster.yml
   ansible-playbook playbooks/03-install-cilium.yml
   ```

3. **Restore etcd from Backup**
   ```bash
   ETCDCTL_API=3 etcdctl snapshot restore /backup/etcd/snapshot.db \
     --data-dir=/var/lib/etcd-restore
   ```

4. **Bootstrap ArgoCD**
   ```bash
   cd kubernetes/argocd-bootstrap
   terraform apply
   ```

5. **Restore ArgoCD Applications**
   ```bash
   kubectl apply -f kubernetes/argocd-apps/
   ```

6. **Wait for All Applications to Sync**
   ```bash
   argocd app wait --all --timeout 1800
   ```

7. **Restore Application Data from Velero**
   ```bash
   velero restore create --from-backup daily-backup-20231029
   ```

8. **Verify All Services**
   ```bash
   ./operations/scripts/health-check.sh
   ```

**Estimated Time**: 3-4 hours

---

## Scenario 2: Single Node Failure

### Steps

1. **Identify Failed Node**
   ```bash
   kubectl get nodes
   ```

2. **Drain Node**
   ```bash
   kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data
   ```

3. **Recreate Node VM**
   ```bash
   cd infrastructure/kubernetes-cluster/terraform/worker-nodes
   terraform taint proxmox_vm_qemu.worker[<index>]
   terraform apply
   ```

4. **Reconfigure Node**
   ```bash
   cd ansible
   ansible-playbook -i inventory/hosts.yml \
     playbooks/01-prepare-nodes.yml \
     --limit <node-name>
   ```

5. **Join to Cluster**
   ```bash
   kubeadm join ...
   ```

6. **Verify Node Ready**
   ```bash
   kubectl get nodes
   kubectl wait --for=condition=Ready node/<node-name> --timeout=300s
   ```

**Estimated Time**: 30-60 minutes

---

## Scenario 3: ArgoCD Failure

### Steps

1. **Reinstall ArgoCD**
   ```bash
   cd kubernetes/argocd-bootstrap/terraform
   terraform destroy -target=helm_release.argocd
   terraform apply
   ```

2. **Restore Applications**
   ```bash
   kubectl apply -f kubernetes/argocd-apps/
   ```

3. **Force Sync All**
   ```bash
   argocd app sync --all
   ```

**Estimated Time**: 15-30 minutes

---

## Scenario 4: Data Loss (Persistent Volumes)

### Steps

1. **Identify Affected PVCs**
   ```bash
   kubectl get pvc -A
   ```

2. **Restore from Velero**
   ```bash
   velero restore create --from-backup <backup-name> \
     --include-namespaces <namespace> \
     --include-resources persistentvolumeclaims,persistentvolumes
   ```

3. **Or Restore from Longhorn Backups**
   - Access Longhorn UI
   - Navigate to Backup
   - Select backup and restore

4. **Verify Data**
   - Check application logs
   - Verify data integrity

**Estimated Time**: Varies based on data size

---

## Backup Schedule

| Component | Frequency | Retention | Location |
|-----------|-----------|-----------|----------|
| etcd | Hourly | 7 days | Proxmox Backup Server |
| GitLab repos | Daily | 30 days | Proxmox Backup Server |
| Velero K8s | Daily | 14 days | MinIO |
| Longhorn volumes | Daily | 7 days | MinIO |
| Proxmox VMs | Weekly | 4 weeks | Proxmox Backup Server |
| Configuration | Real-time | Infinite | GitLab |

---

## Contact Information

- **On-Call**: your-phone-number
- **GitLab**: https://gitlab.homelab.local
- **Monitoring**: https://grafana.homelab.local
- **ArgoCD**: https://argocd.homelab.local
```

---

## Appendix F: Troubleshooting Guide

### Common Issues and Solutions

**File:** `operations/documentation/troubleshooting.md`

```markdown
# Troubleshooting Guide

## ArgoCD Issues

### Application Stuck in Progressing State

**Symptoms:** Application shows "Progressing" for extended period

**Diagnosis:**
```bash
argocd app get <app-name>
kubectl describe application <app-name> -n argocd
kubectl get events -n <namespace> --sort-by='.lastTimestamp'
```

**Solutions:**
1. Check pod logs:
   ```bash
   kubectl logs -n <namespace> <pod-name>
   ```

2. Check resource quotas:
   ```bash
   kubectl describe resourcequota -n <namespace>
   ```

3. Force refresh:
   ```bash
   argocd app diff <app-name>
   argocd app sync <app-name> --force
   ```

---

### ArgoCD Out of Sync but No Changes

**Symptoms:** Application shows OutOfSync but no actual changes

**Solutions:**
1. Check ignore differences:
   ```yaml
   ignoreDifferences:
     - group: apps
       kind: Deployment
       jsonPointers:
         - /spec/replicas
   ```

2. Enable self-heal:
   ```yaml
   syncPolicy:
     automated:
       selfHeal: true
   ```

3. Hard refresh:
   ```bash
   argocd app get <app-name> --hard-refresh
   ```

---

## Terraform Issues

### State Lock Error

**Symptoms:** "Error locking state" message

**Solutions:**
```bash
# List locks
terraform force-unlock <lock-id>

# If using GitLab as backend
# Delete lock via GitLab API or UI
```

---

### Provider Authentication Failed

**Symptoms:** "authentication failed" errors

**Solutions:**
```bash
# Check credentials
export PM_API_URL="https://proxmox.homelab.local:8006/api2/json"
export PM_API_TOKEN_ID="terraform@pam!token"
export PM_API_TOKEN_SECRET="secret"

# Test connection
curl -k -H "Authorization: PVEAPIToken=${PM_API_TOKEN_ID}=${PM_API_TOKEN_SECRET}" \
  ${PM_API_URL}/version
```

---

## Kubernetes Issues

### Pods Stuck in Pending

**Diagnosis:**
```bash
kubectl describe pod <pod-name> -n <namespace>
```

**Common Causes:**
1. **Insufficient resources:**
   ```bash
   kubectl describe nodes
   kubectl top nodes
   ```

2. **PVC not bound:**
   ```bash
   kubectl get pvc -n <namespace>
   kubectl describe pvc <pvc-name> -n <namespace>
   ```

3. **Node selector/affinity issues:**
   ```bash
   kubectl get pod <pod-name> -n <namespace> -o yaml | grep -A 5 nodeSelector
   ```

---

### ImagePullBackOff

**Diagnosis:**
```bash
kubectl describe pod <pod-name> -n <namespace>
```

**Solutions:**
1. **Check image exists:**
   ```bash
   docker pull <image>
   ```

2. **Check image pull secrets:**
   ```bash
   kubectl get secrets -n <namespace>
   kubectl create secret docker-registry harbor-creds \
     --docker-server=harbor.homelab.local \
     --docker-username=robot \
     --docker-password=token
   ```

3. **Update deployment:**
   ```yaml
   imagePullSecrets:
     - name: harbor-creds
   ```

---

### CrashLoopBackOff

**Diagnosis:**
```bash
kubectl logs <pod-name> -n <namespace> --previous
kubectl describe pod <pod-name> -n <namespace>
```

**Common Solutions:**
1. Check resource limits
2. Check volume mounts
3. Check environment variables
4. Check liveness/readiness probes

---

## Networking Issues

### Service Not Accessible

**Diagnosis:**
```bash
kubectl get svc -n <namespace>
kubectl get endpoints -n <namespace>
kubectl describe svc <service-name> -n <namespace>
```

**Solutions:**
1. **Check pod labels match service selector:**
   ```bash
   kubectl get pods -n <namespace> --show-labels
   ```

2. **Check network policies:**
   ```bash
   kubectl get networkpolicies -n <namespace>
   ```

3. **Test from another pod:**
   ```bash
   kubectl run -it --rm debug --image=nicolaka/netshoot --restart=Never -- bash
   curl http://<service-name>.<namespace>.svc.cluster.local
   ```

---

### Ingress Not Working

**Diagnosis:**
```bash
kubectl get ingress -n <namespace>
kubectl describe ingress <ingress-name> -n <namespace>
```

**Solutions:**
1. **Check Traefik logs:**
   ```bash
   kubectl logs -n traefik -l app.kubernetes.io/name=traefik
   ```

2. **Check certificate:**
   ```bash
   kubectl get certificate -n <namespace>
   kubectl describe certificate <cert-name> -n <namespace>
   ```

3. **Check DNS:**
   ```bash
   nslookup <hostname>
   ```

---

## Storage Issues

### PVC Not Binding

**Diagnosis:**
```bash
kubectl get pvc -n <namespace>
kubectl describe pvc <pvc-name> -n <namespace>
kubectl get storageclass
```

**Solutions:**
1. **Check storage class exists:**
   ```bash
   kubectl get storageclass longhorn
   ```

2. **Check Longhorn health:**
   ```bash
   kubectl get pods -n longhorn-system
   ```

3. **Manually provision PV (if needed):**
   ```yaml
   apiVersion: v1
   kind: PersistentVolume
   metadata:
     name: manual-pv
   spec:
     capacity:
       storage: 10Gi
     accessModes:
       - ReadWriteOnce
     persistentVolumeReclaimPolicy: Retain
     storageClassName: longhorn
     ...
   ```

---

## Certificate Issues

### Certificate Not Issuing

**Diagnosis:**
```bash
kubectl get certificate -A
kubectl describe certificate <cert-name> -n <namespace>
kubectl get certificaterequest -n <namespace>
kubectl describe certificaterequest <req-name> -n <namespace>
```

**Solutions:**
1. **Check cert-manager logs:**
   ```bash
   kubectl logs -n cert-manager -l app=cert-manager
   ```

2. **Check issuer:**
   ```bash
   kubectl get clusterissuer
   kubectl describe clusterissuer letsencrypt-prod
   ```

3. **Check ACME challenge:**
   ```bash
   kubectl get challenges -A
   kubectl describe challenge <challenge-name> -n <namespace>
   ```

4. **Manual renewal:**
   ```bash
   kubectl delete certificate <cert-name> -n <namespace>
   kubectl delete secret <cert-secret> -n <namespace>
   # Certificate will be re-requested automatically
   ```

---

## Monitoring Issues

### Metrics Not Showing in Grafana

**Solutions:**
1. **Check Prometheus targets:**
   - Open Prometheus UI
   - Navigate to Status → Targets
   - Verify all targets are "UP"

2. **Check service monitor:**
   ```bash
   kubectl get servicemonitor -A
   kubectl describe servicemonitor <name> -n <namespace>
   ```

3. **Check metrics endpoint:**
   ```bash
   kubectl run -it --rm debug --image=curlimages/curl --restart=Never -- \
     curl http://<service>.<namespace>.svc.cluster.local:<port>/metrics
   ```

---

## Security Scanning Issues

### Trivy Scan Failing in CI/CD

**Solutions:**
1. **Increase timeout:**
   ```yaml
   .security:trivy:
     timeout: 30m
   ```

2. **Use local database:**
   ```yaml
   script:
     - trivy image --download-db-only
     - trivy image --skip-db-update ${IMAGE}
   ```

3. **Ignore unfixed vulnerabilities:**
   ```yaml
   script:
     - trivy image --ignore-unfixed ${IMAGE}
   ```

---

## Performance Issues

### High CPU/Memory Usage

**Diagnosis:**
```bash
kubectl top nodes
kubectl top pods -A --sort-by=cpu
kubectl top pods -A --sort-by=memory
```

**Solutions:**
1. **Set resource limits:**
   ```yaml
   resources:
     requests:
       cpu: 100m
       memory: 128Mi
     limits:
       cpu: 500m
       memory: 512Mi
   ```

2. **Scale deployment:**
   ```bash
   kubectl scale deployment <name> --replicas=3 -n <namespace>
   ```

3. **Add HPA:**
   ```yaml
   apiVersion: autoscaling/v2
   kind: HorizontalPodAutoscaler
   metadata:
     name: <name>
   spec:
     scaleTargetRef:
       apiVersion: apps/v1
       kind: Deployment
       name: <deployment>
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

---

## Quick Diagnostics Commands

```bash
# Cluster health
kubectl cluster-info
kubectl get nodes
kubectl get pods -A | grep -v Running

# Component health
kubectl get componentstatuses

# Events (last 1 hour)
kubectl get events -A --sort-by='.lastTimestamp' | tail -50

# Resource usage
kubectl top nodes
kubectl top pods -A --sort-by=cpu | head -20

# ArgoCD health
argocd app list
argocd app get <app-name>

# Certificate status
kubectl get certificate -A

# Ingress status
kubectl get ingress -A

# Storage status
kubectl get pvc -A
kubectl get pv

# Network policies
kubectl get networkpolicies -A
```

---

## Emergency Procedures

### 1. Rollback Deployment

```bash
# Via kubectl
kubectl rollout undo deployment/<name> -n <namespace>
kubectl rollout status deployment/<name> -n <namespace>

# Via ArgoCD
argocd app rollback <app-name> <revision>
argocd app sync <app-name>
```

### 2. Emergency Maintenance Mode

```bash
# Scale down all applications
for ns in $(kubectl get ns -o jsonpath='{.items[*].metadata.name}'); do
  kubectl scale deployment --all --replicas=0 -n $ns
done

# Or just scale specific namespaces
kubectl scale deployment --all --replicas=0 -n media
kubectl scale deployment --all --replicas=0 -n productivity
```

### 3. Force Delete Stuck Resources

```bash
# Force delete pod
kubectl delete pod <pod-name> -n <namespace> --grace-period=0 --force

# Remove finalizers
kubectl patch <resource> <name> -n <namespace> \
  -p '{"metadata":{"finalizers":[]}}' --type=merge

# Delete namespace stuck in Terminating
kubectl get namespace <namespace> -o json \
  | tr -d "\n" | sed "s/\"finalizers\": \[[^]]\+\]/\"finalizers\": []/" \
  | kubectl replace --raw /api/v1/namespaces/<namespace>/finalize -f -
```
```

---

## Appendix G: Learning Path & Next Steps

### Progressive Learning Path

```markdown
# Homelab Learning Journey

## Phase 1: Foundation (Weeks 1-2)
✅ Tasks:
- [ ] Set up Proxmox hypervisor
- [ ] Deploy Pi-Hole for DNS
- [ ] Create GitLab structure
- [ ] Set up GitLab runners
- [ ] Deploy first VM with Terraform
- [ ] Configure VM with Ansible

📚 Learning Focus:
- Proxmox basics
- Git workflows
- Terraform fundamentals
- Ansible basics

---

## Phase 2: Kubernetes Cluster (Weeks 3-4)
✅ Tasks:
- [ ] Deploy K8s cluster with Terraform + Ansible
- [ ] Install Cilium CNI
- [ ] Deploy MetalLB
- [ ] Deploy Cert-Manager
- [ ] Deploy Traefik
- [ ] Get first ingress working

📚 Learning Focus:
- Kubernetes architecture
- Networking (CNI, Services, Ingress)
- Certificate management
- Load balancing

---

## Phase 3: GitOps with ArgoCD (Week 5)
✅ Tasks:
- [ ] Bootstrap ArgoCD
- [ ] Create app-of-apps structure
- [ ] Deploy first application via ArgoCD
- [ ] Set up auto-sync
- [ ] Configure sync waves

📚 Learning Focus:
- GitOps principles
- ArgoCD workflows
- Declarative deployments

---

## Phase 4: Storage & Persistence (Week 6)
✅ Tasks:
- [ ] Deploy Longhorn
- [ ] Create StorageClasses
- [ ] Deploy stateful application (database)
- [ ] Set up MinIO
- [ ] Configure backups

📚 Learning Focus:
- Persistent volumes
- StatefulSets
- Backup strategies
- S3-compatible storage

---

## Phase 5: Observability (Week 7)
✅ Tasks:
- [ ] Deploy Prometheus + Grafana
- [ ] Configure ServiceMonitors
- [ ] Create custom dashboards
- [ ] Deploy Loki + Promtail
- [ ] Set up alerts

📚 Learning Focus:
- Metrics collection
- Log aggregation
- Alerting
- Dashboard creation

---

## Phase 6: Secrets Management (Week 8)
✅ Tasks:
- [ ] Deploy HashiCorp Vault
- [ ] Configure auth methods
- [ ] Deploy External Secrets Operator
- [ ] Migrate secrets from K8s to Vault
- [ ] Deploy Sealed Secrets

📚 Learning Focus:
- Secret management best practices
- Vault operations
- Secret rotation

---

## Phase 7: Security Baseline (Weeks 9-10)
✅ Tasks:
- [ ] Deploy Falco for runtime security
- [ ] Deploy Kyverno for policies
- [ ] Set up Trivy Operator
- [ ] Configure network policies
- [ ] Deploy Wazuh SIEM

📚 Learning Focus:
- Kubernetes security
- Policy enforcement
- Vulnerability scanning
- SIEM basics

---

## Phase 8: CI/CD Pipelines (Week 11)
✅ Tasks:
- [ ] Create CI/CD templates
- [ ] Set up security scanning in pipelines
- [ ] Configure automated testing
- [ ] Implement image building
- [ ] Set up automated deployments

📚 Learning Focus:
- GitLab CI/CD
- Security scanning tools
- Testing frameworks (Terratest, Molecule)

---

## Phase 9: Applications (Weeks 12-14)
✅ Tasks:
- [ ] Deploy media stack (Jellyfin, ARR)
- [ ] Deploy Nextcloud
- [ ] Deploy Home Assistant
- [ ] Deploy photo management (Immich)
- [ ] Deploy AI tools (Ollama)

📚 Learning Focus:
- Application deployment patterns
- Data persistence
- Integration between services

---

## Phase 10: Advanced Topics (Weeks 15+)
✅ Tasks:
- [ ] Deploy Istio service mesh
- [ ] Learn and deploy with Chef
- [ ] Set up Jenkins (compare with GitLab CI)
- [ ] Implement advanced security (Tetragon, KubeArmor)
- [ ] Set up Harbor registry
- [ ] Configure JFrog Artifactory

📚 Learning Focus:
- Service mesh concepts
- Alternative IaC tools (Chef)
- Alternative CI/CD (Jenkins)
- Advanced security
- Artifact management

---

## Phase 11: Enterprise Features (Ongoing)
✅ Tasks:
- [ ] Implement disaster recovery procedures
- [ ] Set up comprehensive backup strategy
- [ ] Deploy Velero for K8s backups
- [ ] Set up Proxmox Backup Server
- [ ] Document everything
- [ ] Create runbooks

📚 Learning Focus:
- Business continuity
- Disaster recovery
- Documentation best practices
- Operational excellence

---

## Certification Paths (Optional)

1. **Kubernetes:**
   - CKA (Certified Kubernetes Administrator)
   - CKAD (Certified Kubernetes Application Developer)
   - CKS (Certified Kubernetes Security Specialist)

2. **Cloud/DevOps:**
   - HashiCorp Certified: Terraform Associate
   - GitLab Certified Associate

3. **Security:**
   - CompTIA Security+
   - Certified Ethical Hacker (CEH)

---

## Resources

### Documentation
- Kubernetes: https://kubernetes.io/docs/
- ArgoCD: https://argo-cd.readthedocs.io/
- Terraform: https://www.terraform.io/docs/
- Ansible: https://docs.ansible.com/

### Books
- "Kubernetes Up & Running" by Kelsey Hightower
- "Terraform: Up & Running" by Yevgeniy Brikman
- "Ansible for DevOps" by Jeff Geerling
- "The Phoenix Project" (DevOps philosophy)

### YouTube Channels
- TechnoTim
- NetworkChuck
- Christian Lempa
- Jeff Geerling

### Communities
- r/homelab (Reddit)
- r/kubernetes (Reddit)
- r/selfhosted (Reddit)
- Kubernetes Slack
- HomelabOS Discord
```

---

## Final Notes

### Key Success Factors

1. **Start Small**: Don't try to deploy everything at once
2. **Document as You Go**: Future you will thank present you
3. **Test Before Production**: Use staging/dev environments
4. **Automate Everything**: If you do it twice, automate it
5. **Monitor Everything**: You can't fix what you can't see
6. **Backup Everything**: Test your backups regularly
7. **Security First**: Don't treat it as an afterthought
8. **Learn from Failures**: Every failure is a learning opportunity

### Maintenance Schedule

**Daily:**
- Review monitoring dashboards
- Check ArgoCD sync status
- Review security alerts

**Weekly:**
- Review backup logs
- Update outdated images
- Check for CVEs in running containers
- Review resource usage trends

**Monthly:**
- Update Kubernetes cluster
- Update core services
- Review and update documentation
- Test disaster recovery procedures
- Review and rotate secrets

**Quarterly:**
- Major version upgrades
- Security audit
- Review and update policies
- Capacity planning

